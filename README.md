# EHTImages
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ehtjulia.github.io/EHTImages.jl/dev/)
[![Build Status](https://github.com/EHTJulia/EHTImages.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/EHTJulia/EHTImages.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/EHTJulia/EHTImages.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/EHTJulia/EHTImages.jl)

This module defines data types and implement basic functions to handle five dimensional astronomical images for radio interferometry.
The module aims to provide the following features meeting the needs for multi-dimensional imaging in particular for Very Long Baseline Inferferometry (e.g. Event Horizon Telescope) and millimeter interferometry (e.g. ALMA).
- Native support of the five dimensional images (x, y, frequency, polarizaition, time) in a self-descriptive data format.
    + Non equispaced grid in time for the application of dynamic imaging methods (e.g. Johnson et al. 2017, Bouman et al. 2017)
    + Non equispaced grid in frequency for the application of multi-frequency imaging methods (e.g. Chael et al. 2023)
- Interactive plotting tools powered by PyPlot.jl and Makie.jl
- Interactive tools to analyze, edit, and transform images through pure Julia native functions
- Supporting multiple data format for loading and writing
    + FITS/HDF5 formats of eht-imaging library (Chael et al. 2016, 2018) and SMILI (Akiyama et al. 2017a, b) for the EHT community.
    + FITS formats of AIPS, DIFMAP and CASA software packages
    + Native data format in NETCDF4 (on HDF5)

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
The documentation is in preparation, but docstrings of available functions are listed for the [latest](https://ehtjulia.github.io/EHTImages.jl/dev) version. The stable version has not been released. 


## Acknowledgement
The development of this package has been finantially supported by the following programs.
- v0.1.0 - v0.1.4: [ALMA North American Development Study Cycle 8](https://science.nrao.edu/facilities/alma/science_sustainability/alma-develop-history), National Radio Astronomy Observatory (NRAO), USA

The National Radio Astronomy Observatory is a facility of the National Science Foundation operated under cooperative agreement by Associated Universities, Inc.