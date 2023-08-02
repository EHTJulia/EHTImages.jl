export imagepixels
export intensitymap
export intensitymap2d
export intensitymap4d
export stokesintensitymap
export stokesintensitymap2d
export stokesintensitymap4d
export add!, mul!

"""
    imagepixels(metadata) --> grid <: VLBISkyModels.AbstractDims
    imagepixels(::AbstractIntensityImage) --> grid <: VLBISkyModels.AbstractDims

Create the grid instance for Comrade.
"""
@inline function imagepixels(metadata)
    fovx, fovy = get_fov(metadata)
    nx = metadata[:nx]
    ny = metadata[:ny]
    dx = metadata[:dx]
    dy = metadata[:dy]
    ixref = metadata[:ixref]
    iyref = metadata[:iyref]
    x0 = -dx * (ixref - (nx + 1) / 2)
    y0 = dy * (iyref - (ny + 1) / 2)
    return VLBISkyModels.imagepixels(fovx, fovy, nx, ny, x0, y0)
end

@inline imagepixels(im::AbstractIntensityImage) = imagepixels(im.metadata)

"""
    $(FUNCTIONNAME)(im::AbstractIntensityImage, pidx=1, fidx=1, tidx=1) --> VLBISkyModels.IntensityMap

create a two-dimensional Comrade.IntensityMap model.

** Arguments **
- `pidx, fidx, tidx::Integer`: indices for polarizaiton, frequency and time, respectively.
"""
@inline function intensitymap2d(im::AbstractIntensityImage, pidx=1, fidx=1, tidx=1)
    xg, yg = get_xygrid(im)
    nx = im.metadata[:nx]
    ny = im.metadata[:ny]
    xitr = range(xg[end], xg[1], length=nx)
    yitr = range(yg[1], yg[end], length=ny)

    metadata = intensitymap_header2d(im, pidx, fidx, tidx)
    dims = GriddedKeys{(:X, :Y)}((xitr, yitr), metadata)

    return IntensityMap(im[end:-1:1, :, pidx, fidx, tidx], dims)
end

"""
    $(FUNCTIONNAME)(im::AbstractIntensityImage, pidx=1) --> VLBISkyModels.IntensityMap

create a four-dimensional Comrade.IntensityMap model.

** Arguments **
- `pidx::Integer`: the polarization index.
"""
@inline function intensitymap4d(im::AbstractIntensityImage, pidx=1)
    xg, yg = get_xygrid(im)
    nx = im.metadata[:nx]
    ny = im.metadata[:ny]
    xitr = range(xg[end], xg[1], length=nx)
    yitr = range(yg[1], yg[end], length=ny)
    metadata = intensitymap_header4d(im, pidx)
    dims = GriddedKeys{(:X, :Y, :F, :T)}((xitr, yitr, im.f, im.t), metadata)
    return IntensityMap(im[end:-1:1, :, pidx, :, :], dims)
end

@inline function intensitymap_header2d(im::AbstractIntensityImage, pidx, fidx, tidx)
    return (
        source=im.metadata[:source],
        RA=im.metadata[:xref],
        DEC=im.metadata[:yref],
        mjd=im.t[tidx],
        F=im.f[fidx],
        stokes=pidx
    )
end

@inline function intensitymap_header4d(im::AbstractIntensityImage, pidx)
    return (
        source=im.metadata[:source],
        RA=im.metadata[:xref],
        DEC=im.metadata[:yref],
        mjd=im.t[1],
        F=im.f[1],
        stokes=pidx
    )
end

"""
    stokesintensitymap2d(im::AbstractIntensityImage, fidx=1, tidx=1) --> VLBISkyModels.StokesIntensityMap

create a 2D Comrade.StokesIntensityMap model.

** Arguments **
- `fidx, tidx::Integer`: indices for frequency and time, respectively.
"""
@inline function stokesintensitymap2d(im::AbstractIntensityImage, fidx=1, tidx=1)
    @assert im.metadata[:np] == 4
    imap = intensitymap2d(im::AbstractIntensityImage, pidx=1, fidx, tidx)
    qmap = intensitymap2d(im::AbstractIntensityImage, pidx=2, fidx, tidx)
    umap = intensitymap2d(im::AbstractIntensityImage, pidx=3, fidx, tidx)
    vmap = intensitymap2d(im::AbstractIntensityImage, pidx=4, fidx, tidx)
    return VLBISkyModels.StokesIntensityMap(imap, qmap, umap, vmap)
end

"""
    stokesintensitymap2d(im::AbstractIntensityImage) --> VLBISkyModels.StokesIntensityMap

create a 4D Comrade.StokesIntensityMap model.
"""
@inline function stokesintensitymap4d(im::AbstractIntensityImage)
    @assert im.metadata[:np] == 4
    imap = intensitymap4d(im::AbstractIntensityImage, pidx=1)
    qmap = intensitymap4d(im::AbstractIntensityImage, pidx=2)
    umap = intensitymap4d(im::AbstractIntensityImage, pidx=3)
    vmap = intensitymap4d(im::AbstractIntensityImage, pidx=4)
    return VLBISkyModels.StokesIntensityMap(imap, qmap, umap, vmap)
end

# load intensity map into the existing AbstractIntensityImage
@inline function Base.map!(im::AbstractIntensityImage, imap::VLBISkyModels.IntensityMap, pidx=1, fidx=1, tidx=1)
    nimapdim = ndims(imap)
    @assert nimapdim == 2 || nimapdim == 4
    if nimapdim == 2
        @assert size(imap) == (im.metadata[:nx], im.metadata[:ny])
        im.data[:, :, pidx, fidx, tidx] .= imap.data.data[end:-1:1, 1:end]
    else
        @assert size(imap) == (im.metadata[:nx], im.metadata[:ny], im.metadata[:nf], im.metadata[:nt])
        im.data[:, :, pidx, :, :] .= imap.data.data[end:-1:1, 1:end, :, :]
    end
    return nothing
end

@inline function add!(im::AbstractIntensityImage, imap::VLBISkyModels.IntensityMap, pidx=1, fidx=1, tidx=1)
    nimapdim = ndims(imap)
    @assert nimapdim == 2 || nimapdim == 4
    if nimapdim == 2
        @assert size(imap) == (im.metadata[:nx], im.metadata[:ny])
        im.data[:, :, pidx, fidx, tidx] .+= imap.data.data[end:-1:1, 1:end]
    else
        @assert size(imap) == (im.metadata[:nx], im.metadata[:ny], im.metadata[:nf], im.metadata[:nt])
        im.data[:, :, pidx, :, :] .+= imap.data.data[end:-1:1, 1:end, :, :]
    end
    return nothing
end

@inline function mul!(im::AbstractIntensityImage, imap::VLBISkyModels.IntensityMap, pidx=1, fidx=1, tidx=1)
    nimapdim = ndims(imap)
    @assert nimapdim == 2 || nimapdim == 4
    if nimapdim == 2
        @assert size(imap) == (im.metadata[:nx], im.metadata[:ny])
        im.data[:, :, pidx, fidx, tidx] .*= imap.data.data[end:-1:1, 1:end]
    else
        @assert size(imap) == (im.metadata[:nx], im.metadata[:ny], im.metadata[:nf], im.metadata[:nt])
        im.data[:, :, pidx, :, :] .*= imap.data.data[end:-1:1, 1:end, :, :]
    end
    return nothing
end

# load an abstract model into the existing AbstractIntensityImage
@inline function Base.map!(im::AbstractIntensityImage, model::ComradeBase.AbstractModel, pidx=1, fidx=1, tidx=1)
    imap = intensitymap2d(im, pidx, fidx, tidx)
    intensitymap!(imap, model)
    im.data[:, :, pidx, fidx, tidx] = imap.data.data[end:-1:1, 1:end]
    return nothing
end

@inline function add!(im::AbstractIntensityImage, model::ComradeBase.AbstractModel, pidx=1, fidx=1, tidx=1)
    imap = intensitymap2d(im, pidx, fidx, tidx)
    intensitymap!(imap, model)
    im.data[:, :, pidx, fidx, tidx] .+= imap.data.data[end:-1:1, 1:end]
    return nothing
end

@inline function mul!(im::AbstractIntensityImage, model::ComradeBase.AbstractModel, pidx=1, fidx=1, tidx=1)
    imap = intensitymap2d(im, pidx, fidx, tidx)
    intensitymap!(imap, model)
    im.data[:, :, pidx, fidx, tidx] .*= imap.data.data[end:-1:1, 1:end]
    return nothing
end

# defaults
const intensitymap(im::AbstractIntensityImage, args...) = intensitymap2d(im, args...)
const stokesintensitymap(im::AbstractIntensityImage, args...) = stokesintensitymap2d(im, args...)
