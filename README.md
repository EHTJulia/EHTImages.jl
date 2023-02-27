# EHTImages
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ehtjulia.github.io/EHTImages.jl/dev/)
[![Build Status](https://github.com/EHTJulia/EHTImages.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/EHTJulia/EHTImages.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/EHTJulia/EHTImages.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/EHTJulia/EHTImages.jl)

This module defines data types and implement basic functions to handle five dimensional astronomical images for radio interferometry in particular for the Event Horizon Telescope (EHT) and next generation EHT (ngEHT).

## Installation
Assuming that you already have Julia correctly installed, it suffices to import EHTImages.jl in the standard 
way:

```julia
using Pkg
Pkg.add("EHTImages")
```

EHTImages.jl uses [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl) for the image visulization, which
will need to have the Python [Matplotlib](http://matplotlib.org/) library installed on your machine in some way.
Please see the documentation of [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl).


## Documentation
The [latest](https://ehtjulia.github.io/EHTImages.jl/dev) version available. The stable version has not been released. 
