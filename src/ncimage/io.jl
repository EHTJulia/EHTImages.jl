export load_image, save_netcdf
export open!
export close!, close

function open!(image::NCImage; mode="r", args...)
    # check if the file is already opened
    if isopen(image)
        close!(image)
    end

    # open NetCDF file
    image.dataset = NCDataset(image.filename, mode, args...)

    # open subdataset
    groups = get_groups(image.group)
    imds = get_subdataset(image.dataset, groups)

    # reload arrays
    image.data = imds["image"].var
    image.mjd = imds["mjd"].var
    image.freq = imds["freq"].var
    image.pol = imds["pol"].var
    image.metadata = imds.attrib
end


function close!(image::NCImage)
    if isopen(image)
        Base.close(image.dataset)
    end
end


function close(image::NCImage)
    close!(image)
end


function load_image(
    filename::AbstractString;
    mode::AbstractString="r",
    group::AbstractString="image",
    args...
)::NCImage
    # genrate image object
    image = NCImage(
        filename=filename,
        group=group,
    )

    # load image
    open!(image, mode=mode, args...)
    return image
end


function save_netcdf(
    image::NCImage,
    filename::AbstractString;
    mode::AbstractString="c",
    group::AbstractString="image",
    args...
)
    # check if the file is already opened
    if isopen(image)
        open!(image::NCImage; mode="r")
    end

    # create the output NetCDF file
    outdataset = NCDataset(filename, mode, args...)

    # generate dataset
    groups = get_groups(group)
    outsubds = gen_subdataset(outdataset, groups)

    # set dimension
    nx, ny, np, nf, nt = size(image)
    defDim(outsubds, "time", nt)
    defDim(outsubds, "freq", nf)
    defDim(outsubds, "pol", np)
    defDim(outsubds, "y", ny)
    defDim(outsubds, "x", nx)

    # set attributes
    for key in keys(image.metadata)
        outsubds.attrib[key] = image.metadata[key]
    end

    # set variables
    vim = defVar(outsubds, "image", Float64, ("x", "y", "pol", "freq", "time"))
    vim[:] = image.data[:]
    vim.attrib["coordinates"] = "mjd"

    xg, yg = get_xygrid(image)
    vx = defVar(outsubds, "x", Float64, ("x",))
    vx[:] = xg[:]

    vy = defVar(outsubds, "y", Float64, ("y",))
    vy[:] = yg[:]

    vp = defVar(outsubds, "pol", String, ("pol",))
    vp[:] = image.pol[:]

    vf = defVar(outsubds, "freq", Float64, ("freq",))
    vf[:] = image.freq[:]

    vt = defVar(outsubds, "mjd", Float64, ("time",))
    vt[:] = image.mjd[:]

    NCDatasets.close(outdataset)
end


function get_groups(group::AbstractString)::Vector{String}
    groups = splitpath(group)
    groups = deleteat!(groups, findall(x -> x == "/", groups))
    groups = deleteat!(groups, findall(x -> x == "", groups))
    return groups
end


function get_subdataset(dataset::NCDataset, groups)::NCDataset
    curds = dataset
    if length(groups) > 0
        for group in groups
            curds = curds.group[group]
        end
    end
    return curds
end

function gen_subdataset(dataset::NCDataset, groups)::NCDataset
    ds = dataset
    if length(groups) > 0
        for group in groups
            defGroup(ds, group)
            ds = ds.group[group]
        end
    end
    return ds
end