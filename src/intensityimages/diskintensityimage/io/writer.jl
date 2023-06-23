export create_DiskIntensityImage
export save_netcdf, save_netcdf!


"""
    $(FUNCTIONNAME)(filename, nx, dx, angunit; keywords) -> DiskIntensityImage

Create a blank `DiskIntensityImage` object. Return `DiskIntensityImage` data loaded with :read mode.

# Arguments
- `filename::AbstractString`:
    NetCDF4 file where image data will be created.
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
- `metadata::AbstractDict=default_metadata(AbstractIntensityImage)`:
    other metadata. Note that the above keywords and arguments will overwrite
    the values of the conflicting keys in this `metadata` argument.
- `mode::Symbol=:create`:
    The access mode to NCDataset.
    Available modes are `:read`, `:append`, `:create`.
    See help for `EHTNCDBase.ncdmodes` for details.
- `group::AbstractString=EHTImage.ncd_intensity_defaultgroup`:
    The group of the image data in the input NetCDF4 file.
"""
function diskintensityimage(
    filename::AbstractString,
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
    metadata::AbstractDict=default_metadata(AbstractIntensityImage),
    mode::Symbol=:create,
    group::AbstractString=ncd_intensity_defaultgroup
)::DiskIntensityImage
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

    # get mode string
    if mode ∉ [:create, :append]
        @throwerror ArgumentError "mode must be :create or :append"
    else
        modestr = ncdmodes[mode]
    end

    # create the output NetCDF file
    dataset = NCDataset(filename, modestr)

    # define the group
    groups = split_group(group)
    imds = define_group(dataset, groups)

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
        attrib[key] = metadata[key]
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
    #   set metadata
    set_ncd_intensity_metadata!(imds, attrib)

    # define dimensions and variables
    define_ncd_intensity_dimensions!(imds, nx, ny, np, nf, nt)
    define_ncd_intensity_variables!(imds)

    # initialize variables
    #   image
    imds[ncd_intensity_varnames[:data]].var[:] = 0.0
    #   x and y
    xg, yg = get_xygrid(attrib)
    imds[ncd_intensity_varnames[:x]].var[:] = xg[:]
    imds[ncd_intensity_varnames[:y]].var[:] = yg[:]
    #   polarization
    imds[ncd_intensity_varnames[:p]].var[:] = ["I", "Q", "U", "V"][1:np]
    #   frequency
    imds[ncd_intensity_varnames[:f]].var[:] = freq[:]
    #   time
    imds[ncd_intensity_varnames[:t]].var[:] = mjd[:]

    # close data set
    NCDatasets.close(dataset)

    # open file
    image = load_image(filename, group=group, mode=:read)

    return image
end


"""
    save_netcdf!(image, filename; [mode, group])

Save image data to NetCDF4 format.

# Arguments
- `image::AbstractIntensityImage`
    Input image data
- `filename::AbstractString`:
    NetCDF4 file where image data will be saved.
- `mode::Symbol=:create`:
    The access mode to NCDataset.
    Available modes are `:read`, `:append`, `:create`.
    See help for `EHTNCDBase.ncdmodes` for details.
- `group::AbstractString=EHTImage.ncd_intensity_defaultgroup`:
    The group of the image data in the input NetCDF4 file.
"""
function save_netcdf!(
    image::AbstractIntensityImage,
    filename::AbstractString;
    mode::Symbol=:create,
    group::AbstractString=ncd_intensity_defaultgroup
)
    # get mode string
    if mode ∉ [:create, :append]
        @throwerror ArgumentError "mode must be :create or :append"
    else
        modestr = ncdmodes[mode]
    end

    # check if the file is already opened
    if isopen(image) == false
        open!(image, :read)
    end

    # create the output NetCDF file
    outdataset = NCDataset(filename, modestr)

    # define the group
    groups = split_group(group)
    outsubds = define_group(outdataset, groups)

    # get the size of the image
    nx, ny, np, nf, nt = size(image)

    # define dimensions and variables
    define_ncd_intensity_dimensions!(outsubds, nx, ny, np, nf, nt)
    define_ncd_intensity_variables!(outsubds)

    # set metadata
    #   initialize metadata
    attrib = default_metadata(AbstractIntensityImage)
    #   fill metadata
    for key in keys(image.metadata)
        skey = Symbol(key)
        attrib[skey] = image.metadata[skey]
    end
    #   write metadata
    set_ncd_intensity_metadata!(outsubds, attrib)

    # set variables
    #   image
    outsubds[ncd_intensity_varnames[:data]].var[:, :, :, :, :] = image.data[:, :, :, :, :]
    #   x and y
    xg, yg = get_xygrid(image)
    outsubds[ncd_intensity_varnames[:x]].var[:] = xg[:]
    outsubds[ncd_intensity_varnames[:y]].var[:] = yg[:]
    #   pol, freq, mjd
    outsubds[ncd_intensity_varnames[:p]].var[:] = image.p[:]
    outsubds[ncd_intensity_varnames[:f]].var[:] = image.f[:]
    outsubds[ncd_intensity_varnames[:t]].var[:] = image.t[:]

    # close data set
    NCDatasets.close(outdataset)

    return nothing
end


"""
    save_netcdf(image, filename; [mode=:create, group="image"]) => DiskIntensityImage

Save image data to NetCDF4 format. Saved data will be loaded and returned
with `:read` access mode.

# Arguments
- `image::AbstractIntensityImage`
    Input image data
- `filename::AbstractString`:
    NetCDF4 file where image data will be saved.
- `mode::Symbol=:create`:
    The access mode to NCDataset.
    Available modes are `:read`, `:append`, `:create`.
    See help for `EHTNCDBase.ncdmodes` for details.
- `group::AbstractString=EHTImage.ncd_intensity_defaultgroup`:
    The group of the image data in the input NetCDF4 file.
"""
function save_netcdf(
    image::AbstractIntensityImage,
    filename::AbstractString;
    mode::Symbol=:create,
    group::AbstractString=ncd_intensity_defaultgroup
)::DiskIntensityImage
    save_netcdf!(image, filename, mode=mode, group=group)
    return load_image(filename, group=group, mode=:read)
end


"""
    define_ncd_intensity_dimensions!(ncd[, nx, ny, np, nf, nt])

Define NetCDF4 dimensions based on the given size of the image data.
"""
function define_ncd_intensity_dimensions!(ncd, nx=1, ny=1, np=1, nf=1, nt=1)
    # image size
    imsize = (nx, ny, np, nf, nt)

    # set dimension
    for i in 1:5
        @debug i, ncd_intensity_dimnames[i], imsize[i]
        defDim(ncd, ncd_intensity_dimnames[i], imsize[i])
    end

    return nothing
end

"""
    define_ncd_intensity_variables!(ncd)

Define NetCDF4 variables based on EHT NetCDF4 Image Format.
"""
function define_ncd_intensity_variables!(ncd)
    # define variables
    for key in keys(ncd_intensity_varnames)
        @debug key, ncd_intensity_varnames[key], ncd_intensity_vartypes[key], ncd_intensity_vardims[key]
        defVar(ncd, ncd_intensity_varnames[key], ncd_intensity_vartypes[key], ncd_intensity_vardims[key])
    end

    return nothing
end


"""
    set_ncd_intensity_metadata!(ncd)

Set NetCDF4 metadata based on EHT NetCDF4 Image Format.
"""
function set_ncd_intensity_metadata!(ncd, metadata)
    # shortcut to the format
    tconv = ncd_intensity_metadata_typeconv
    tkeys = keys(ncd_intensity_metadata_typeconv)

    # update metadata
    for key in keys(metadata)
        if key in tkeys
            ncd.attrib[key] = tconv[key](metadata[key])
        else
            ncd.attrib[key] = metadata[key]
        end
    end

    return nothing
end
