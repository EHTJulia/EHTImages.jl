export default_metadata
export copy_metadata!


"""
    intensityimage_metadata_default::NamedTuple

A tuple for the default metadata keys and values for `AbstractIntensityImage`.
"""
const intensityimage_metadata_default = (
    format="EHTJulia Intensity Image NetCDF4 Format",
    version=v"0.1.0",
    source="Nameless Source",
    instrument="Nameless Instrument",
    observer="Nameless Observer",
    coordsys="icrs",
    equinox=-1,
    nx=1,
    dx=1.0,
    xref=0.0,
    ixref=0.5,
    xunit="rad",
    ny=1,
    dy=1.0,
    yref=0.0,
    iyref=0.5,
    yunit="rad",
    np=1,
    polrep="stokes",
    nf=1,
    funit="Hz",
    nt=1,
    tunit="MJD",
    fluxunit="Jy/Pixel",
    pulsetype="delta",
)
int(x) = round(Int64, x)


"""
    intensityimage_metadata_default::NamedTuple

A tuple of types for metadata keys in `intensityimage_metadata_default`.
"""
const intensityimage_metadata_type = (
    format=string,
    version=VersionNumber,
    source=string,
    instrument=string,
    observer=string,
    coordsys=string,
    equinox=float,
    nx=int,
    dx=float,
    xref=float,
    ixref=float,
    xunit=string,
    ny=int,
    dy=float,
    yref=float,
    iyref=float,
    yunit=string,
    np=int,
    polrep=string,
    nf=int,
    funit=string,
    nt=int,
    tunit=string,
    fluxunit=string,
    pulsetype=string,
)


"""
    intensityimage_metadata_compat::NamedTuple

A tuple of available values for some of keys in `intensityimage_metadata_default`.
"""
const intensityimage_metadata_compat = (
    coordsys=["icrs"],
    equinox=[-1],
    xunit=["rad"],
    yunit=["rad"],
    np=[1, 4],
    polrep=["stokes"],
    funit=["Hz"],
    tunit=["MJD"],
    fluxunit=["Jy/Pixel"],
    pulsetype=["delta", "rectangle"],
)


"""
    default_metadata(dataset) -> OrderedDict

Return the default metadata of the given dataset.
"""
@inline function default_metadata(::Type{<:AbstractIntensityImage})
    dict = OrderedDict{Symbol,Any}()

    for key in keys(intensityimage_metadata_default)
        dict[key] = intensityimage_metadata_default[key]
    end

    return dict
end

@inline function get_xygrid(
    metadata,
    angunit::Union{Unitful.Quantity,Unitful.Units,String}=rad)
    # Get scaling for the flux unit
    if angunit == rad
        aunitconv = 1
    else
        # get unit
        if angunit isa String
            aunit = get_unit(angunit)
        else
            aunit = angunit
        end

        # get scaling factor
        aunitconv = unitconv(rad, aunit)
    end

    nx = metadata[:nx]
    ny = metadata[:ny]
    dx = metadata[:dx] * aunitconv
    dy = metadata[:dy] * aunitconv
    ixref = metadata[:ixref]
    iyref = metadata[:iyref]

    xg = -dx * ((1-ixref):1:(nx-ixref))
    yg = dy * ((1-iyref):1:(ny-iyref))

    return (xg, yg)
end

@inline function get_uvgrid(metadata, dofftshift::Bool=true)
    # nx, ny
    nx = metadata[:nx]
    ny = metadata[:ny]

    # dx, dy
    dxrad = metadata[:dx]
    dyrad = metadata[:dy]

    ug = fftfreq(nx, -1 / dxrad)
    vg = fftfreq(ny, 1 / dyrad)

    if dofftshift
        ug = fftshift(ug)
        vg = fftshift(vg)
    end

    return (ug, vg)
end


"""
    copy_metadata!(image::AbstractIntensityImage, uvdataset::AbstractUVDataSet)

copy metadata from the given uvdataset.
"""
@inline function copy_metadata!(image::AbstractIntensityImage, uvdataset::EHTUVData.AbstractUVDataSet)
    for key in [:source, :instrument, :observer, :coordsys, :equinox]
        image.metadata[key] = uvdataset.metadata[key]
    end
    image.metadata[:xref] = uvdataset.metadata[:ra]
    image.metadata[:yref] = uvdataset.metadata[:dec]
end
