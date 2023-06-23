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

EHTImages.jl uses [PythonPlot.jl](https://github.com/stevengj/PythonPlot.jl) for the image visulization.
You can use a custom set of perceptually uniform colormaps implemented in the Python's [ehtplot](https://github.com/liamedeiros/ehtplot) library, which
has been used in the publications of the EHT Collaboration, by installing it through [CondaPkg.jl](https://github.com/cjdoris/CondaPkg.jl) and 
import it using [PythonCall.jl](https://github.com/cjdoris/PythonCall.jl). For

```julia
# Install CondaPkg.jl and  PythonCall.jl: (need to run only once in your local/global Julia enviroment)
using Pkg
Pkg.add("CondaPkg")
Pkg.add("PythonCall")

# Install ehtplot (again need to run only once in your local/global Julia enviroment)
using CondaPkg
CondaPkg.add_pip("ehtplot", version="@git+https://github.com/liamedeiros/ehtplot")
```
Then, you can use ehtplot for, for instance, `imshow` method for the image plotting.
```julia
# When you want to use ehtplot
using EHTImages
using PythonCall # provide the `pyimport` function
ehtplot = pyimport("ehtplot")

# plot using the `afmhot_us` colormap in ehtplot.
imshow(::yourimage, colormap="afmhot_us", ...)
```

## Documentation
The documentation is in preparation, but docstrings of available functions are listed for the [latest](https://ehtjulia.github.io/EHTImages.jl/dev) version. The stable version has not been released. 


## Acknowledgements
The development of this package has been finantially supported by the following programs.
- [AST-2107681](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2107681), National Science Foundation, USA: v0.1.5 - present
- [AST-2034306](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2034306), National Science Foundation, USA: v0.1.5 - present
- [OMA-2029670](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2029670), National Science Foundation, USA: v0.1.5 - present
- [AST-1935980](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1935980), National Science Foundation, USA: v0.1.5 - present
- [ALMA North American Development Study Cycle 8](https://science.nrao.edu/facilities/alma/science_sustainability/alma-develop-history), National Radio Astronomy Observatory, USA: v0.1.0 - v0.1.4

The National Radio Astronomy Observatory is a facility of the National Science Foundation operated under cooperative agreement by Associated Universities, Inc.