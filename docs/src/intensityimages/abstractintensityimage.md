```@meta
CurrentModule = EHTImages
```

# Intensity Image Data Types
The package provides the high-level abstract data type [`AbstractIntensityImage`](@ref) for  five-dimensional images (x (right ascention), y (declination), frequency, polarization, time) and many methods to handle these data sets. 

The package further provides two reference implementations of the 5D intensity image cube data sets: in-memory [`IntensityImage`](@ref) and NetCDF4-based [`DiskIntensityImage`](@ref) data types, which share common methods through [`AbstractIntensityImage`](@ref).

Intensity image data types adopt the following convensions:
  - Equispaced grid along with `x` and `y` axises, which is left-handed following the standard of astronomy images.
  - Non-equidistant grid in time for the application of dynamic imaging methods (e.g., Johnson et al., 2017, Bouman et al., 2017).
  - Non-equidistant grid in frequency for the application of multi-frequency imaging methods (e.g., Chael et al., 2023).
  - The intensity image cube is assumed to be real. This convension practically limits the polarization representation of images to the standard stokes parameters (I, Q, U, V). The data type does not support other polarization represenations such as (RR, LL, RL, LR) or (XX, YY, XY, YX), which are both image-domain conterparts of raw interferometric data and are in general described as complex functions. 


## Abstract Intensity Images
The high-level abstract type of the 5D intensity image cube is defined by [`AbstractIntensityImage`](@ref). Here, [`AbstractImageDataSet`](@ref) is a common high-level abstract type for data sets handled in this package (i.e. not limited to the intensity cube). While [`AbstractIntensityImage`](@ref) is not a subtype of `AbstractArray`, it behaves like `AbstractArray` thanks to methods associated with [`AbstractImageDataSet`](@ref).

To handle the 5D intensity cube [`AbstractIntensityImage`](@ref) assumes following fields
- `data`: 5 dimensional array for intensity [x, y, polarization, frequency, time]
- `p`: 1 dimensional array for polarization codes in string (coordinate for polarization axis)
- `f`: 1 dimensional array for frequency in Hz (coordinate for frequency axis)
- `t`: 1 dimensional array for time in modified Julian dates (coordinate for time axis)
- `metadata`: `OrderedCollections.OrderedDict`-like object to stock metadata

Let's walk through methods defined in [`AbstractIntensityImage`](@ref) using its in-memory subtype [`IntensityImage`](@ref) in the next section.


