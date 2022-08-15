module EHTImage

# Import external packages
using Base
using DocStringExtensions # for docstrings
using EHTUtils: c, kB, unitconv, get_unit, Jy, K, rad
using EHTModel
using Formatting # for python-ish string formatter
using FFTW: fftfreq, fftshift, plan_fft, plan_ifft # for FFT
using Logging
using Missings: disallowmissing # to load netcdf data
using NCDatasets # to hande netcdf files
using Parameters # for more flexible definitions of struct
using PyPlot # to use matplotlib
using Unitful, UnitfulAngles, UnitfulAstro # for Units

# Include 
#   AbstractImage
include("abstractimage/abstractimage.jl")
include("abstractimage/convolve_fftw.jl")
include("abstractimage/pyplot.jl")

#   NCImage
include("ncimage/ncimage.jl")
include("ncimage/io.jl")

#   DimImage
#include("dimimage/dimimage.jl")
#include("dimimage/io.jl")
#include("dimimage/pyplot.jl")
end
