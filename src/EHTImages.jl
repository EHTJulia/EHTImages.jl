module EHTImages

# Import external packages
using Base
using DimensionalData
using DocStringExtensions # for docstrings
using EHTUtils: c, kB, unitconv, get_unit, Jy, K, rad, deg, σ2fwhm, @throwerror
using EHTModels
using EHTNCDBase
using FFTW: fftfreq, fftshift, plan_fft, plan_ifft # for FFT
using FLoops
using Formatting # for python-ish string formatter
using Logging
using Missings: disallowmissing # to load netcdf data
using NCDatasets # to hande netcdf files
using OrderedCollections # to use OrderedDictionary
using Parameters # for more flexible definitions of struct
using PyPlot # to use matplotlib
using Unitful, UnitfulAngles, UnitfulAstro # for Units

# Include 
#   AbstractImage
include("abstractimage/abstractimage.jl")
include("abstractimage/convolution.jl")
include("abstractimage/metadata.jl")
include("abstractimage/modelmap.jl")
include("abstractimage/pyplot.jl")

#   NCImage
include("ncimage/ncimage.jl")
include("ncimage/convolution.jl")
include("ncimage/io/const.jl")
include("ncimage/io/reader.jl")
include("ncimage/io/writer.jl")

#   DDImage
include("ddimage/ddimage.jl")
include("ddimage/io/reader.jl")
include("ddimage/io/writer.jl")

end
