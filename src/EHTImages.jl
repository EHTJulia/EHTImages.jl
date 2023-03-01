module EHTImages

# Import external packages
using Base
using Dates
using DimensionalData
using DocStringExtensions # for docstrings
using EHTUtils: c, kB, unitconv, get_unit, Jy, K, rad, deg, σ2fwhm, @throwerror, mjd2datetime, datetime2mjd, jd2mjd, mjd2jd
using EHTModels
using EHTNCDBase
using FFTW: fftfreq, fftshift, plan_fft, plan_ifft # for FFT
using FITSIO
using FLoops
using Formatting # for python-ish string formatter
using Logging
using Missings: disallowmissing # to load netcdf data
using NCDatasets # to hande netcdf files
using OrderedCollections # to use OrderedDictionary
using Parameters # for more flexible definitions of struct
using PyPlot # to use matplotlib
using Unitful, UnitfulAngles, UnitfulAstro # for Units

# For UVDATA
using Conda
using DataFrames
using PyCall
using Statistics

# For UVDATA
const numpy = PyCall.PyNULL()
const pyfits = PyCall.PyNULL()

# Include 
#   AbstractImage
include("abstractimage/abstractimage.jl")
include("abstractimage/convolution.jl")
include("abstractimage/metadata.jl")
include("abstractimage/modelmap.jl")
include("abstractimage/pyplot.jl")
include("abstractimage/io/fitswriter.jl")

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
include("ddimage/io/fitsreader.jl")

#  tentatively put UVDATA module here
include("uvdatasets/abstractuvdataset/abstract.jl")
include("uvdatasets/uvdataset/abstract.jl")
include("uvdatasets/uvdataset/utils.jl")
include("uvdatasets/uvdataset/io/uvfitsloader.jl")

end