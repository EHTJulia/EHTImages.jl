using EHTImage
using Documenter

DocMeta.setdocmeta!(EHTImage, :DocTestSetup, :(using EHTImage); recursive=true)

makedocs(;
    modules=[EHTImage],
    authors="Kazu Akiyama",
    repo="https://github.com/kazuakiyama/EHTImage.jl/blob/{commit}{path}#{line}",
    sitename="EHTImage.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://kazuakiyama.github.io/EHTImage.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/kazuakiyama/EHTImage.jl",
    devbranch="main",
)
