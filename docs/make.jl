include("../src/DarOneTools.jl")

using Documenter, .DarOneTools

push!(LOAD_PATH,"../src/")

makedocs(
    sitename="Dar_One",
    pages = [
        "Getting Started" => "getting_started.md",
        "Beginner Tutorials" => "beginner_tutorials.md",
        "Case Studies" => "case_studies.md",
        "Modify Parameters" => "index.md",
        "All Documentation" => "all_docs.md",
        "Darwin Background" => "darwin_background.md",
    ]
)

