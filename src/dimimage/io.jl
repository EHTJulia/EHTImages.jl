function load_image(ds::NCDataset; group::String="image")
    # get the image data set
    imds = ds.group[group]

    # get the image size
    nx, ny, np, nf, nt = size(imds["image"])

    # get metadata
    metadata = Dict(imds.attrib)

    # get dx and dy
    dx = metadata["dx"]
    dy = metadata["dy"]
    ixref = metadata["ixref"]
    iyref = metadata["iyref"]

    # define dimensions
    x = Dim{:x}(-dx * ((1-ixref):1:(nx-ixref)))
    y = Dim{:y}(+dy * ((1-iyref):1:(ny-iyref)))
    p = Dim{:pol}(disallowmissing(imds["pol"]))
    f = Dim{:freq}(disallowmissing(imds["freq"]))
    t = Dim{:time}(disallowmissing(imds["mjd"]))

    # define the dimensions
    image = DimImage(
        DimArray(
            disallowmissing(imds["image"][:, :, :, :, :]),
            (x, y, p, f, t),
            metadata=metadata
        )
    )
    return image
end

function load_image(infile::String; group::String="image")
    return load_image(Dataset(infile, "r"), group=group)
end

function save_netcdf(image::DimImage, outfile::String; mode="c", group="image")
    outds = NCDataset(outfile, mode)

    groups = splitpath(group)
    groups = deleteat!(groups, findall(x -> x == "/", groups))
    groups = deleteat!(groups, findall(x -> x == "", groups))

    # create groups
    curds = outds
    if length(groups) > 0
        for group in groups
            defGroup(curds, group)
            curds = curds.group[group]
        end
    end

    # set dimension
    nx, ny, np, nf, nt = size(image.da)
    defDim(curds, "time", nt)
    defDim(curds, "freq", nf)
    defDim(curds, "pol", np)
    defDim(curds, "y", ny)
    defDim(curds, "x", nx)

    # set attributes
    for key in keys(image.da.metadata)
        curds.attrib[key] = image.da.metadata[key]
    end

    # set variables
    vim = defVar(curds, "image", Float64, ("x", "y", "pol", "freq", "time"))
    vim[:] = image.da.data[:]
    vim.attrib["coordinates"] = "mjd"

    vx = defVar(curds, "x", Float64, ("x",))
    vx[:] = collect(image.da.dims[1].val.data)

    vy = defVar(curds, "y", Float64, ("y",))
    vy[:] = collect(image.da.dims[2].val.data)

    vp = defVar(curds, "pol", String, ("pol",))
    vp[:] = image.da.dims[3].val.data[:]

    vf = defVar(curds, "freq", Float64, ("freq",))
    vf[:] = image.da.dims[4].val.data[:]

    vt = defVar(curds, "mjd", Float64, ("time",))
    vt[:] = image.da.dims[5].val.data[:]

    close(outds)
end