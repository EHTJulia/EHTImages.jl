```@meta
CurrentModule = EHTImages
```

# Intensity Image Data Types
The package provides the high-level abstract data type `AbstractIntensityImage' for  five-dimensional images (x, y, frequency, polarization, time) and many methods to handle these data sets. 

The package further provides two reference implementations of the 5D intensity image cube data sets: in-memory `IntensityImage <: AbstractIntensityImage` and NetCDF4-based `DiskIntensityImage <: AbstractIntensityImage` data types, which share common methods through `AbstractIntensityImage`.


## `AbstractIntensityImage`
The high-level abstract type of the 5D intensity image cube is defined by `AbstractIntensityImage <: AbstractImageDataSet`. Here, `AbstractImageDataSet` is a common high-level abstract type for data sets handled in this package (i.e. not limited to the intensity cube). While `AbstractIntensityImage` is not a subtype of `AbstractArray`, it behaves like `AbstractArray` thanks to methods associated with `AbstractImageDataSet`.
```@docs
AbstractImageDataSet
```

Upon `AbstractImageDataSet`, AbstractIntensityImage assumes following fields
- `data`: 5 dimensional array for intensity [x, y, polarization, frequency, time]
- `p`: 1 dimensional array for polarization codes in string (coordinate for polarization axis)
- `f`: 1 dimensional array for frequency in Hz (coordinate for frequency axis)
- `t`: 1 dimensional array for time in modified Julian dates (coordinate for time axis)
- `metadata`: `OrderedCollections.OrderedDict`-like object to stock metadata


# IntensityImage