module EHTImage

# Import external packages
using DimensionalData #: Dim, DimArray
using Unitful, UnitfulAngles, UnitfulAstro # for Units
using FFTW: fftfreq, fftshift, plan_fft, plan_ifft # for FFT
using PyPlot # to use matplotlib
using Formatting # for python-ish string formatter
using NCDatasets # to hande netcdf files
using Missings: disallowmissing # to load netcdf data
using EHTUtils: c, kB, unitconv, get_unit, Jy, K, rad

# Functions to be inhereted
import Base: copy
import PyPlot: imshow

# Exports
#   Types
export AbstractEHTImage, DimImage
#   Misc functions
export copy
export get_bconv, get_uvgrid
#   I/O
export load_image, save_netcdf
#   convolution
#export convolve_geomodel, convolve_geomodel!
#   plotting related
export get_imextent
export imshow, plot_xylabel, plot_colorbar

# Include 
#   AbstractImage
include("abstractimage/abstractimage.jl")
#   DimImage
include("dimimage/dimimage.jl")
include("dimimage/io.jl")
include("dimimage/pyplot.jl")
end
