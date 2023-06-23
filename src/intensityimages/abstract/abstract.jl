export AbstractIntensityImage

"""
    $(TYPEDEF)

This defines a basic interface for intensity images. It is a subtype of `AbstractImageDataSet`.

# Mandatory fields
- `data`: 5 dimensional array for intensity [x, y, polarization, frequency, time]
- `p`: 1 dimensional array for polarization codes in string (coordinate for polarization axis)
- `f`: 1 dimensional array for frequency in Hz (coordinate for frequency axis)
- `t`: 1 dimensional array for time in modified Julian dates (coordinate for time axis)
- `metadata`: Dict-like object to stock metadata

# Mandatory methods need to be defined.
See also documentations for `AbstractImageDataSet`.
"""
abstract type AbstractIntensityImage <: AbstractImageDataSet end

