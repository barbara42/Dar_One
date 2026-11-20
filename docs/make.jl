using Documenter, DarOne

makedocs(
    sitename="DarOne.jl",
    pages = [
        "Getting Started" => "getting_started.md",
        "Beginner Tutorials" => "beginner_tutorials.md",
        "Case Studies" => "case_studies.md",
        "Modify Parameters" => "index.md",
        "All Documentation" => "all_docs.md",
        "Darwin Background" => "darwin_background.md",
    ]
)

