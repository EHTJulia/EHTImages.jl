"""
    ncd_intensity_defaultgroup::String

Default group name of the EHT Intensity Image NetCDF4 format.
"""
const ncd_intensity_defaultgroup = "intensityimage"


"""
    ncd_intensity_dimnames::NamedTuple

A named tuple relating Symbols to actual strings for the dimension of the EHT Intensity Image NetCDF4 format.
keys are `:x, :y` for x and y axis, `:p` for polarization, `:f` for frequency, `:t` for time.
"""
const ncd_intensity_dimnames = (
    x="x",
    y="y",
    p="polarization",
    f="frequency",
    t="time",
)


"""
    ncd_intensity_varnames::NamedTuple

A named tuple relating Symbols to names of the corresponding variables
of the EHT Intensity Image NetCDF4 format.
"""
const ncd_intensity_varnames = (
    data="intensity",
    x="x",
    y="y",
    p="polarization",
    f="frequency",
    t="time",
)


"""
    ncd_intensity_vartypes::NamedTuple

A named tuple relating Symbols to types of the corresponding variables
of the EHT Intensity Image NetCDF4 format.
"""
const ncd_intensity_vartypes = (
    data=Float64,
    x=Float64,
    y=Float64,
    p=String,
    f=Float64,
    t=Float64,
)


"""
    ncd_intensity_vartypes::NamedTuple

A named tuple relating Symbols to types of the corresponding variables
of the EHT Intensity Image NetCDF4 format.
"""
const ncd_intensity_vardims = (
    data=tuple(ncd_intensity_dimnames...,),
    x=(ncd_intensity_dimnames[:x],),
    y=(ncd_intensity_dimnames[:y],),
    p=(ncd_intensity_dimnames[:p],),
    f=(ncd_intensity_dimnames[:f],),
    t=(ncd_intensity_dimnames[:t],),
)


"""
    ncd_intensity_metadata_typeconv::NamedTuple

A named tuple relating Symbols to types of the corresponding variables
of the EHT Intensity Image NetCDF4 format.
"""
const ncd_intensity_metadata_typeconv = (
    format=string,
    version=string,
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
