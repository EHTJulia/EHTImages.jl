using EHTImages
using Documenter

DocMeta.setdocmeta!(EHTImages, :DocTestSetup, :(using EHTImages); recursive=true)

makedocs(;
    modules=[EHTImages],
    authors="Kazunori Akiyama",
    repo="https://github.com/EHTJulia/EHTImages.jl/blob/{commit}{path}#{line}",
    sitename="EHTImages.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://EHTJulia.github.io/EHTImages.jl",
        edit_link="main",
        assets=String[]
    ),
    pages=[
        "Home" => "index.md",
        "All Docstrings" => "autodocstrings.md",
    ]
)

deploydocs(;
    repo="github.com/EHTJulia/EHTImages.jl",
    devbranch="main"
)
