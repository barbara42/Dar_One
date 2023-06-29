using Pkg

dependencies = [
    "OrderedCollections",
    "Suppressor",
    "ClimateModels",
    "NCDatasets"
]

Pkg.add(dependencies)
Pkg.precompile()