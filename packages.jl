using Pkg

dependencies = [
    "OrderedCollections",
    "Suppressor",
    "ClimateModels",
    "NCDatasets", 
    "Setfield"
]

Pkg.add(dependencies)
Pkg.precompile()