export create_image, create_ddimage

"""
    create_image(nx, dx, angunit; keywords) -> DDImage
    create_ddimage(nx, dx, angunit; keywords) -> DDImage

Create and return a blank DDImage object.

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
- `pol::Symbol=:single`:
    number of polarizations. Availables are `:single` or `:full` (i.e. four)
    polarizations.
- `freq::Vector{Float64}=[1.0]`:
    a vector for frequencies in the unit of Hz
- `mjd::Vector{Float64}=[0.0]`:
    a vector for time in the unit of MJD.
- `metadata::AbstractDict=default_metadata(NCImage())`:
    other metadata. Note that the above keywords and arguments will overwrite
    the values of the conflicting keys in this `metadata` argument.
"""
function create_ddimage(
    nx::Integer,
    dx::Real,
    angunit::Union{Unitful.Quantity,Unitful.Units,String};
    ixref::Real=(nx + 1) / 2,
    ny::Real=nx,
    dy::Real=dx,
    iyref::Real=(ny + 1) / 2,
    pol::Symbol=:single,
    freq::Vector{Float64}=[1.0],
    mjd::Vector{Float64}=[0.0],
    metadata::AbstractDict=default_metadata(NCImage())
)::DDImage
    # check variables
    for arg in [nx, dx, ny, dy]
        if arg <= 0
            @throwerror ArgumentError "`nx`, `ny`, `dx` and `dy` must be positive"
        end
    end

    # get the number of polarization
    if pol ∉ [:single, :full]
        @throwerror ArgumentError "we only support `:single` or `:full` polarizaiton images"
    elseif pol == :single
        np = 1  # single polarization
    else
        np = 4  # full polarization
    end

    # get the size of mjd and freq
    nf = length(freq)
    nt = length(mjd)

    # conversion factor of angular unit
    if angunit == rad
        aconv = 1
    else
        aconv = unitconv(angunit, rad)
    end

    # set metadata
    #   initialize metadata
    attrib = default_metadata(NCImage())
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
    xg, yg = get_xygrid(attrib)
    x = Dim{:x}(xg)
    y = Dim{:y}(yg)

    # define other axises
    p = Dim{:p}(["I", "Q", "U", "V"][1:np])
    f = Dim{:f}(freq[:])
    t = Dim{:t}(mjd[:])

    # create DimArray data
    dimarray = DimArray(
        data=zeros(Float64, (nx, ny, np, nf, nt)),
        dims=(x, y, p, f, t),
        name=:intensity,
        metadata=attrib
    )

    # create a DDImage instance.
    return create_ddimage(dimarray)
end

"""
    create_ddimage(dimarray::DimArray)

Create DDImage instance from a given DimArray.
"""
function create_ddimage(dimarray::DimArray)::DDImage
    return DDImage(
        dimarray=dimarray,
        metadata=dimarray.metadata,
        data=dimarray.data,
        pol=dimarray.dims[3].val.data,
        freq=dimarray.dims[4].val.data,
        mjd=dimarray.dims[5].val.data
    )
end

# Alias to create_image
create_image = create_ddimage