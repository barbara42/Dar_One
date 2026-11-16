"""Reproduce the paper's Figure 4C from 16 DAR1 tiles and the Darwin reference."""

import os
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import xarray as xr

ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path(os.environ.get("DARONE_MITGCM_PATH", "/dar_one_docker/darwin3"))
RUNS = SOURCE / "verification" / "dar_one_config" / "run"
DATA = Path(os.environ.get("DARONE_DATA_DIR", ROOT / "data" / "darwin"))
REFERENCE = DATA / "surface_tracers.nc"
OUTPUT = Path(sys.argv[1]).resolve() if len(sys.argv) == 2 else Path.home() / "darone-fig4c"
SPECIES = (*range(21, 30), *range(35, 71))  # Exclude diazotrophs, as in the notebook.


def surface(dataset, variable, t, x=None, y=None):
    array = dataset[variable]
    indices = {dim: 0 for dim in array.dims if dim.startswith("Z")}
    indices["T"] = t
    if x is not None:
        indices.update(X=x, Y=y)
    return np.nan_to_num(array.isel(indices).transpose("Y", "X").values.astype(float),
                         nan=0.0, posinf=0.0, neginf=0.0)


def final_records(directory):
    files = sorted(directory.rglob("3d.*.nc"))
    records = []
    for file in files:
        with xr.open_dataset(file, decode_times=False) as ds:
            records.extend((file, t) for t in range(ds.sizes["T"]))
    if len(records) < 2:
        raise ValueError(f"Expected two annual records in {directory}, found {len(records)}")
    return records[-2:]


def main():
    field = np.full((160, 360), np.nan, dtype=np.float32)
    with xr.open_dataset(REFERENCE, decode_times=False) as ref:
        for ix in range(4):
            for iy in range(4):
                x, y = slice(ix * 90, (ix + 1) * 90), slice(iy * 40, (iy + 1) * 40)
                name = f"globe-ss-{x.start + 1}-{x.stop}-{y.start + 1}-{y.stop}"
                (p, tp), (q, tq) = final_records(RUNS / name / "run")
                numerator, denominator = np.zeros((40, 90)), np.zeros((40, 90))
                with xr.open_dataset(p, decode_times=False) as prev, xr.open_dataset(q, decode_times=False) as curr:
                    for species in SPECIES:
                        var = f"TRAC{species}"
                        reference = surface(ref, var, 0, x, y)
                        evolved = (surface(prev, var, tp) + surface(curr, var, tq)) / 2
                        numerator += 2 * np.minimum(reference, evolved)
                        denominator += reference + evolved
                valid = denominator > 0
                tile = np.full_like(numerator, np.nan)
                tile[valid] = 1 - numerator[valid] / denominator[valid]
                if not np.any(valid) or not np.all((tile[valid] >= 0) & (tile[valid] <= 1)):
                    raise ValueError(f"Invalid Bray-Curtis dissimilarity in {name}")
                field[y, x] = tile
                print(f"Analysed {name}", flush=True)

    OUTPUT.mkdir(parents=True, exist_ok=True)
    result = xr.DataArray(field, dims=("latitude", "longitude"),
                          coords={"latitude": np.arange(-80, 80), "longitude": np.arange(360)},
                          name="bray_curtis")
    result.to_netcdf(OUTPUT / "Fig_Bray_Curtis.nc")
    fig, ax = plt.subplots(figsize=(12, 6))
    image = ax.imshow(field, origin="lower", extent=(0, 360, -80, 80),
                      cmap="viridis", vmin=0, vmax=1, aspect="auto")
    fig.colorbar(image, ax=ax)
    ax.set(title="Bray-Curtis Dissimilarity between Steady-State and Global",
           xlabel="longitude", ylabel="latitude")
    fig.tight_layout()
    fig.savefig(OUTPUT / "Fig_Bray_Curtis.png", dpi=130)
    plt.close(fig)
    print(f"Saved Figure 4C to {OUTPUT}")


if __name__ == "__main__":
    main()
