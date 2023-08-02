function load(imap::VLBISkyModels.IntensityMap; p=:single, pidx=1, fidx=1, tidx=1)
    # get the number of dimensions
    ndim = ndims(imap)
    @assert ndim == 2 || ndim == 4

    # get the header from the input Intensity Map
    #   default metadata
    metadata_default = (
        source="unknown",
        RA=0.0,
        DEC=0.0,
        mjd=1.0,
        F=1.0,
        stokes=1
    )
    metadata = OrderedDict()
    for key in keys(metadata_default)
        metadata[key] = metadata_default[key]
    end

    #   Load metadata
    metadata_imap = ComradeBase.header(imap)
    if metadata_imap != ComradeBase.NoHeader()
        for key in keys(metadata_imap)
            metadata[key] = metadata_imap[key]
        end
    end

    # get image grids
    if ndim == 2
        nx, ny = size(imap)
        nf = 1
        nt = 1
        f = [metadata[:F]]
        t = [metadata[:mjd]]
    else
        nx, ny, nf, nt = size(imap)
        f = collect(imap.F)
        t = collect(imap.T)
    end
    dxrad = imap.X.step.hi
    dyrad = imap.Y.step.hi
    ixref = -imap.X[1] / dxrad + 1
    iyref = -imap.Y[1] / dyrad + 1

    # create metadata
    metadata_im = default_metadata(IntensityImage)
    metadata_im[:source] = metadata[:source]
    metadata_im[:x] = metadata[:RA]
    metadata_im[:y] = metadata[:DEC]

    im = intensityimage(nx, dxrad, rad; ny=ny, dy=dyrad, ixref=ixref, iyref=iyref, p=p, metadata=metadata_im)
    if p == :single
        pidx_im = 1
    else
        pidx_im = pidx
    end

    if ndim == 2
        im.data[:, :, pidx_im, tidx, fidx] = imap[end:-1:1, :]
        im.p[1] = ("I", "Q", "U", "V")[pidx]
    else
        im.data[:, :, pidx_im, :, :] = imap[end:-1:1, :, :, :]
    end

    return im
end
