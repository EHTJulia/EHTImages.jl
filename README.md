# EHTImages
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ehtjulia.github.io/EHTImages.jl/dev/)
[![Build Status](https://github.com/EHTJulia/EHTImages.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/EHTJulia/EHTImages.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/EHTJulia/EHTImages.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/EHTJulia/EHTImages.jl)

This module provides data types and implements basic functions to handle five-dimensional astronomical images for radio interferometry. The module aims to provide the following features, meeting the needs for multi-dimensional high-resolution imaging, particularly for Very Long Baseline Interferometry (e.g., Event Horizon Telescope) and millimeter interferometry (e.g., ALMA) in the regime of narrow field of views.

The package currently implements:

- Provides abstract types and methods to handle both in-memory and disk-based image cubes.
- Offers native support for five-dimensional images (x, y, frequency, polarization, time) in a self-descriptive data format.
  - Supports non-equidistant grid in time for the application of dynamic imaging methods (e.g., Johnson et al., 2017, Bouman et al., 2017).
  - Supports non-equidistant grid in frequency for the application of multi-frequency imaging methods (e.g., Chael et al., 2023).
  - Supports both in-memory and disk-based (lazily-loaded) image files.
    - In-memory data is stored in a self-descriptive data type powered by [EHTDimensionalData.jl](https://github.com/EHTJulia/EHTDimensionalData.jl) (an extension of the powerful [DimensionalData.jl](https://github.com/rafaqz/DimensionalData.jl)).
    - Disk-based data is based on NetCDF (on HDF5) accessed by [NCDatasets.jl](https://github.com/Alexander-Barth/NCDatasets.jl), allowing lazy access to data suitable for a large image cube that may not fit into memory and also for containing multiple image data sets inside a single file.
  - Includes a FITS writer and loader compatible with the eht-imaging library (Chael et al., 2016, 2018) and SMILI (Akiyama et al., 2017a, b) for the EHT community, as well as with more traditional packages including AIPS, DIFMAP, and CASA software packages.
- Provides interactive plotting tools powered by [PythonPlot.jl](https://github.com/JuliaPy/PythonPlot.jl).
- Offers interactive tools to analyze, edit, and transform images using pure Julia native functions.


## Installation
Assuming that you already have Julia correctly installed, it suffices to import EHTImages.jl in the standard way:

```julia
using Pkg
Pkg.add("EHTImages")
```

EHTImages.jl uses [PythonPlot.jl](https://github.com/stevengj/PythonPlot.jl) for the image visulization.
You can use a custom set of perceptually uniform colormaps implemented in the Python's [ehtplot](https://github.com/liamedeiros/ehtplot) library, which
has been used in the publications of the EHT Collaboration, by installing it through [CondaPkg.jl](https://github.com/cjdoris/CondaPkg.jl) and 
import it using [PythonCall.jl](https://github.com/cjdoris/PythonCall.jl). For example:
```julia
# Install CondaPkg.jl and  PythonCall.jl: (need to run only once in your local/global Julia enviroment)
using Pkg
Pkg.add("CondaPkg")
Pkg.add("PythonCall")

# Install ehtplot (again need to run only once in your local/global Julia enviroment)
using CondaPkg
CondaPkg.add_pip("ehtplot", version="@git+https://github.com/liamedeiros/ehtplot")
```
After installing ehtplot, you can import and utilize it for image visualization in EHTImages.jl. See the documentation.

## Documentation
The documentation is in progress, but the documentation of some key data types are aldready made for the [latest](https://ehtjulia.github.io/EHTImages.jl/dev) version along with all docstings of types, methods and constants. The stable version has not been released. 


## What if you don't find a feature you want? 
We are prioritizing to implement features needed for the image analysis conducted in the EHT and ngEHT Collaborations. Nevertheless, your feedback is really helpful to make the package widely useful for the broad community. Please request a feature in the [GitHub's issue page](https://github.com/EHTJulia/EHTImages.jl/issues).


## Acknowledgements
The development of this package has been finantially supported by the following programs.
- [AST-2107681](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2107681), National Science Foundation, USA: v0.1.5 - present
- [AST-2034306](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2034306), National Science Foundation, USA: v0.1.5 - present
- [OMA-2029670](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2029670), National Science Foundation, USA: v0.1.5 - present
- [AST-1935980](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1935980), National Science Foundation, USA: v0.1.5 - present
- [ALMA North American Development Study Cycle 8](https://science.nrao.edu/facilities/alma/science_sustainability/alma-develop-history), National Radio Astronomy Observatory, USA: v0.1.0 - v0.1.4

The National Radio Astronomy Observatory is a facility of the National Science Foundation operated under cooperative agreement by Associated Universities, Inc.
