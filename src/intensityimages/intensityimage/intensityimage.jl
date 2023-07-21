export IntensityImage
export intensityimage


"""
    $(TYPEDEF)

A data type for five dimensional images of which data are all stored in the memory.
This format relies on `EHTDimensionalData.DimArray` to provide an easy access of data
through many useful methods in `EHTDimensionalData` and its origin `DimensionalData` packages.
Note that this data type is immutable.

$(TYPEDFIELDS)
"""
@with_kw struct IntensityImage <: AbstractIntensityImage
    "`DimArray` storing all of `data`, `p`, `f`, `t` and `metadata`."
    dimstack::DimStack
    "the five dimensional intensity disbrituion. Alias to `dimstack.intensity.data`."
    data::Array{Float64,5}
    "metadata. Aliast to `dimarray.metadata`."
    metadata::OrderedDict{Symbol,Any}
    "the polarization code, giving the polarization axis (`:p`) of `dimarray`. Alias to `dimarray.dims[3].val.data`."
    p::Vector{String}
    "the central frequency in Hz, giving the frequency axis (`:f`) of `dimarray`. Alias to `dimarray.dims[4].val.data`."
    f::Vector{Float64}
    "the central modified Julian date, giving the time axis (`:t`) of `dimarray`. Alias to `dimarray.dims[5].val.data`."
    t::Vector{Float64}

    # Constructor from DimArray
    function IntensityImage(dimstack::DimStack)
        data = dimstack[:intensity].data
        metadata = getfield(dimstack, :metadata)
        p = dimstack[:polarization].data
        f = dimstack[:frequency].data
        t = dimstack[:time].data
        new(dimstack, data, metadata, p, f, t)
    end
end

# It is memory-based, so non-disk-based, always accessible and writable.
@inline isdiskdata(::IntensityImage) = NotDiskData()
Base.isopen(::IntensityImage) = true
Base.iswritable(::IntensityImage) = true


Base.show(io::IO, mine::MIME"text/plain", image::IntensityImage) = show(io, mine, image.dimstack)
Base.copy(im::IntensityImage) = IntensityImage(copy(im.dimstack))


"""
    $(FUNCTIONNAME)(nx, dx, angunit; keywords) -> IntensityImage

Create and return a blank `IntensityImage` object.

# Arguments
- `nx::Integer`:
    the number of pixels along with the horizontal axis. Must be positive.
- `dx::Real`:
    the pixel size of the horizontal axis. Must be positive.
- `angunit::Union{Unitful.Quantity, Unitful.Units or String}=rad`:
    the angular unit for `dx` and `dy`.

# Keywords
- `ny::Real=nx`:
    the number of pixels along with the vertical axis. Must be positive.
- `dy::Real=dx`:
    the pixel size of the vertical axis. Must be positive.
- `ixref::Real=(nx + 1) / 2`, `iyref::Real=(ny + 1) / 2`:
    index of the reference pixels along with the horizontal and vertical
    axises, respectively. Default values set to the center of the field
    of the view.
- `p::Symbol=:single`:
    number of parizations. Availables are `:single` or `:full` (i.e. four)
    parizations.
- `f::Vector{Float64}=[1.0]`:
    a vector for fuencies in the unit of Hz
- `t::Vector{Float64}=[0.0]`:
    a vector for time in the unit of t.
- `metadata::AbstractDict=default_metadata(AbstractIntensityImage)`:
    other metadata. Note that the above keywords and arguments will overwrite
    the values of the conflicting keys in this `metadata` argument.
"""
function intensityimage(
    nx::Integer,
    dx::Real,
    angunit::Union{Unitful.Quantity,Unitful.Units,String};
    ixref::Real=(nx + 1) / 2,
    ny::Real=nx,
    dy::Real=dx,
    iyref::Real=(ny + 1) / 2,
    p::Symbol=:single,
    f::Vector{Float64}=[1.0],
    t::Vector{Float64}=[0.0],
    metadata::AbstractDict=default_metadata(AbstractIntensityImage)
)
    # check variables
    for arg in [nx, dx, ny, dy]
        if arg <= 0
            @throwerror ArgumentError "`nx`, `ny`, `dx` and `dy` must be positive"
        end
    end

    # get the number of parization
    if p ∉ [:single, :full]
        @throwerror ArgumentError "we only support `:single` or `:full` parizaiton images"
    elseif p == :single
        np = 1  # single parization
    else
        np = 4  # full parization
    end

    # get the size of t and f
    nf = length(f)
    nt = length(t)

    # conversion factor of angular unit
    if angunit == rad
        aconv = 1
    else
        aconv = unitconv(angunit, rad)
    end

    # set metadata
    #   initialize metadata
    attrib = default_metadata(AbstractIntensityImage)
    #   input metadata in arguments
    for key in keys(metadata)
        skey = Symbol(key)
        attrib[skey] = metadata[key]
    end
    #   input other information from arguments
    attrib[:nx] = nx
    attrib[:dx] = dx * aconv
    attrib[:ixref] = ixref
    attrib[:ny] = ny
    attrib[:dy] = dy * aconv
    attrib[:iyref] = iyref
    attrib[:np] = np
    attrib[:nf] = nf
    attrib[:nt] = nt

    # define x, y grids
    dimx = Dim{:x}(1:nx)
    dimy = Dim{:y}(1:ny)
    dimp = Dim{:polarization}(1:np)
    dimf = Dim{:frequency}(1:nf)
    dimt = Dim{:time}(1:nt)

    # create DimStack data
    intensity = DimArray(
        data=zeros(Float64, (nx, ny, np, nf, nt)),
        dims=(dimx, dimy, dimp, dimf, dimt),
        name=:intensity,
    )
    polarization = DimArray(
        data=["I", "Q", "U", "V"][1:np],
        dims=(dimp,),
        name=:polarization
    )
    frequency = DimArray(
        data=f,
        dims=(dimf,),
        name=:frequency
    )
    time = DimArray(
        data=t,
        dims=(dimt,),
        name=:time
    )
    dimstack = DimStack(
        (intensity, polarization, frequency, time),
        metadata=metadata
    )

    # create a IntensityImage instance.
    return IntensityImage(dimstack)
end