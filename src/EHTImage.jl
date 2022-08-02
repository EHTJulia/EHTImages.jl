module EHTImage

# Import external packages
using Base
using Unitful, UnitfulAngles, UnitfulAstro # for Units
using FFTW: fftfreq, fftshift, plan_fft, plan_ifft # for FFT
using PyPlot # to use matplotlib
using Formatting # for python-ish string formatter
using NCDatasets # to hande netcdf files
using Missings: disallowmissing # to load netcdf data
using DocStringExtensions # for docstrings
using Parameters
using EHTUtils: c, kB, unitconv, get_unit, Jy, K, rad

# Include 
#   AbstractImage
include("abstractimage/abstractimage.jl")
include("abstractimage/pyplot.jl")

#   NCImage
include("ncimage/ncimage.jl")
include("ncimage/io.jl")

#   DimImage
#include("dimimage/dimimage.jl")
#include("dimimage/io.jl")
#include("dimimage/pyplot.jl")
end
