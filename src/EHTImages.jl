module EHTImages

# Import external packages
using Base
using ComradeBase
import ComradeBase:
    imagepixels, intensitymap
using Dates
using DocStringExtensions # for docstrings
using EHTDimensionalData
using EHTNCDBase
using EHTUVData
using EHTUtils:
    c, kB, σ2fwhm,
    unitconv, get_unit,
    Jy, K, rad, deg,
    @throwerror,
    mjd2datetime, datetime2mjd, jd2mjd, mjd2jd
using FFTW: fftfreq, fftshift, plan_fft, plan_ifft # for FFT
using FITSIO
using FLoops
using Formatting # for python-ish string formatter
using Logging
using Missings: disallowmissing # to load netcdf data
using NCDatasets # to hande netcdf files
using OrderedCollections # to use OrderedDictionary
using Parameters # for more flexible definitions of struct
using PythonCall: pyimport # to use python
import PythonPlot # to use matplotlib
import PythonPlot: imshow
using Unitful, UnitfulAngles, UnitfulAstro # for Units
using VLBISkyModels

# Include
#   DataStorageTypes
include("datastoragetypes/datastoragetype.jl")

#   Abstract Image Data Set
include("imagedatasets/abstract.jl")

#   Intensity images
#       Abstract Type
include("intensityimages/abstract/abstract.jl")
include("intensityimages/abstract/metadata.jl")
#include("intensityimages/abstract/convolution.jl")
#include("intensityimages/abstract/modelmap.jl")
include("intensityimages/abstract/plotting_tools.jl")
include("intensityimages/abstract/pythonplot.jl")
include("intensityimages/abstract/io/fitswriter.jl")
include("intensityimages/abstract/io/vlbiskymodels.jl")

#       DiskIntensityImage
include("intensityimages/diskintensityimage/diskintensityimage.jl")
include("intensityimages/diskintensityimage/io/const.jl")
include("intensityimages/diskintensityimage/io/reader.jl")
include("intensityimages/diskintensityimage/io/writer.jl")
#include("intensityimages/diskintensityimage/convolution.jl")

#       IntensityImage
include("intensityimages/intensityimage/intensityimage.jl")
include("intensityimages/intensityimage/io/reader.jl")
include("intensityimages/intensityimage/io/fitsreader.jl")
include("intensityimages/intensityimage/io/vlbiskymodels.jl")

end
