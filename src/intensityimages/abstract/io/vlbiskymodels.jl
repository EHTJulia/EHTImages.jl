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
    return imagepixels(fovx, fovy, nx, ny, x0, y0)
end

@inline imagepixels(im::AbstractIntensityImage) = imagepixels(im.metadata)

"""
    intensitymap(im::AbstractIntensityImage, pidx=1, fidx=1, tidx=1) --> VLBISkyModels.IntensityMap

create Comrade.IntensityMap model.

** Arguments **
- `pidx, fidx, tidx::Integer`: indices for polarizaiton, frequency and time, respectively.
"""
@inline function intensitymap(im::AbstractIntensityImage, pidx=1, fidx=1, tidx=1)
    grid = imagepixels(im)
    return IntensityMap(im[:, :, pidx, fidx, tidx], imagepixels(im))
end

"""
    stokesintensitymap(im::AbstractIntensityImage, fidx=1, tidx=1) --> VLBISkyModels.StokesIntensityMap

create Comrade.StokesIntensityMap model.

** Arguments **
- `fidx, tidx::Integer`: indices for frequency and time, respectively.
"""
@inline function stokesintensitymap(im::AbstractIntensityImage, fidx=1, tidx=1)
    @assert im.metadata[:np] == 4
    grid = imagepixels(im)
    imap = IntensityMap(im[:, :, 1, fidx, tidx], grid)
    qmap = IntensityMap(im[:, :, 2, fidx, tidx], grid)
    umap = IntensityMap(im[:, :, 3, fidx, tidx], grid)
    vmap = IntensityMap(im[:, :, 4, fidx, tidx], grid)
    return StokesIntensityMap(imap, qmap, umap, vmap)
end
