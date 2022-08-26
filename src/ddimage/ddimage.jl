"""
    $(TYPEDEF) <: AbstractEHTImage

A data type for five dimensional images of which data are all stored in the memory. 
This format relies on DimensionalData.DimArray to provide an easy access of data
through many useful methods in Dimensional Data. Note that this data type is
immutable. 

# Fields
- `data::Array{Float64, 5}`:
    The five dimensional intensity disbrituions. Alias to `dimarray.data`.
- `pol::Vector{String}`:
    The polarization code, giving the polarization axis (`:p`) of `dimarray`.
    Alias to `dimarray.dims[3].val.data`.
- `freq::Vector{Float64}`:
    The central frequency in Hz, giving the frequency axis (`:f`) of `dimarray`.
    Alias to `dimarray.dims[4].val.data`.
- `mjd::Vector{Float64}`:
    The modified Julian date, giving the time axis (`:t`) of `dimarray`.
    Alias to `dimarray.dims[5].val.data`.
- `metadata::OrderedDict`:
    metadata.
- `dimarray::DimArray{Float64, 5}`.
    DimArray stroing all of `data`, `pol`, `freq`, `mjd` and `metadata`.
"""
@with_kw struct DDImage <: AbstractEHTImage
    dimarray::DimArray{Float64,5}
    data::Array{Float64,5}
    mjd::Vector{Float64}
    freq::Vector{Float64}
    pol::Vector{String}
    metadata::OrderedDict{Symbol,Any}
end

# It is memory-based, so non-disk-based, always accessible and writable.
@inline isdiskdata(::DDImage) = NotDiskData()
Base.isopen(::DDImage) = true
Base.iswritable(::DDImage) = true