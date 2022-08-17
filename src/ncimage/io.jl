export load_image
export save_netcdf, save_netcdf!
export open!
export close!

"""
    ncdmodes

A dictrionary relating Symbols to actual strings for the access mode to netCDF files
using NCDatasets.jl. Keys are:

- `:read`: 
    open an existing netCDF file or OPeNDAP URL in read-only mode (`"r"` in NCDatasets.jl).
- `:create`:
    create a new NetCDF file (an existing file with the same name will be overwritten;
    `"c"` in NCDatasets.jl)
- `:append`:
    open filename into append mode (i.e. existing data in the netCDF file is 
    not overwritten; `"a"` in NCDatasets.jl)
"""
const ncdmodes = Dict(
    :read => "r",
    :create => "c",
    :append => "a"
)

"""
    get_ncdmodestr(mode::Symbol) => String
"""
function get_ncdmodestr(mode::Symbol)::String
    if mode in keys(ncdmodes)
        return ncdmodes[mode]
    else
        @error "The input mode `$(mode)` is not available. See help for `EHTImage.ncdmodes`"
    end
end

"""
    open!(image, mode)
"""
function open!(image::NCImage, mode::Symbol=:read)

    # get mode string
    modestr = get_ncdmodestr(mode)

    # check if the file is already opened
    if isopen(image)
        close!(image)
    end

    # open NetCDF file
    image.dataset = NCDataset(image.filename, modestr)

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

"""
    close!(image::NCImage)
"""
function close!(image::NCImage)
    if isopen(image)
        Base.close(image.dataset)
    end
end


"""
    close(image::NCImage)
"""
function Base.close(image::NCImage)
    close!(image)
end


"""
    load_image(filename; [group="image", mode=:read])
"""
function load_image(
    filename::AbstractString;
    group::AbstractString="image",
    mode::Symbol=:read
)::NCImage
    # generate image object
    image = NCImage(
        filename=filename,
        group=group,
    )

    # load image
    open!(image, mode)
    return image
end

"""
    save_netcdf!(image, filename; [mode=:create, group="image"])
"""
function save_netcdf!(
    image::NCImage,
    filename::AbstractString;
    mode::Symbol=:create,
    group::AbstractString="image"
)
    # get mode string
    if mode ∉ [:create, :append]
        @error "mode must be :create or :append"
    else
        modestr = get_ncdmodestr(mode)
    end

    # check if the file is already opened
    if isopen(image) == false
        open!(image, :read)
    end

    # create the output NetCDF file
    outdataset = NCDataset(filename, modestr)

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

"""
    save_netcdf(image, filename; [mode=:create, group="image"]) => NCImage
"""
function save_netcdf(
    image::NCImage,
    filename::AbstractString;
    mode::Symbol=:create,
    group::AbstractString="image"
)
    save_netcdf!(image, filename, mode=mode, group=group)
    return load_image(filename, group=group, mode=:read)
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