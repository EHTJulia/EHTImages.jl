export imshow
export get_imextent
export plot_colorbar
export plot_xylabel

function imshow(
    image::AbstractEHTImage;
    angunit::Union{String,Unitful.Units,Unitful.Quantity}=rad,
    fluxunit::Union{String,Unitful.Units,Unitful.Quantity}=Jy,
    saunit::Union{String,Unitful.Units,Unitful.Quantity}="pixel",
    idx=[1, 1, 1],
    cmap="afmhot",
    scale::String="linear",
    gamma::Number=0.5,
    dyrange::Number=1000,
    vmax=nothing,
    vmin=nothing,
    relative=false,
    axisoff=false,
    axislabel=true,
    add_colorbar=false,
    imshowargs...)

    # get angular unit
    dopixel::Bool = false
    if isnothing(angunit)
        aunit = get_unit(image.metadata["angunit"])
    elseif angunit isa String
        if startswith(lowercase(angunit), "pixel")
            aunit = "pixel"
            dopixel = true
        else
            aunit = get_unit(angunit)
        end
    else
        aunit = angunit
    end

    # get imextent
    imextent = get_imextent(image, angunit)

    # get flux unit
    if fluxunit isa String
        funit = get_unit(fluxunit)
    else
        funit = fluxunit
    end

    # Convert the intensity unit
    bconv = get_bconv(image, fluxunit=funit, saunit=saunit)
    if dimension(funit) == dimension(K)
        bconv = bconv[idx[2]]
    end
    imarr = image.data[:, :, idx...] * bconv

    if vmax isa Nothing
        nmax = maximum(imarr)
    else
        nmax = vmax
    end

    if lowercase(scale) == "log"
        nmin = nmax / dyrange
        norm = matplotlib[:colors][:LogNorm](vmin=nmin, vmax=nmax)
        imarr[imarr.<nmax/dyrange] .= nmin
        nmin = nothing
        nmax = nothing
    elseif lowercase(scale) == "gamma"
        if vmin isa Nothing
            nmin = 0
        elseif relative == true
            nmin = vmin * nmax
        end
        imarr[imarr.<0] .= 0
        norm = matplotlib[:colors][:PowerNorm](vmin=nmin, vmax=nmax, gamma=gamma)
        nmin = nothing
        nmax = nothing
    elseif lowercase(scale) == "linear"
        if vmin isa Nothing
            nmin = minimum([minimum(imarr), 0])
        elseif relative
            nmin = vmin * nmax
        else
            nmin = vmin
        end
        norm = nothing
    else
        @throwerror ArgumentError "scale must be log, gamma or linear"
    end

    imsobj = PyPlot.imshow(
        imarr,
        origin="lower", extent=imextent,
        vmin=nmin, vmax=nmax, norm=norm,
        cmap=cmap, interpolation="bilinear",
        imshowargs...)

    outdict = Dict()
    outdict["imshowobj"] = imsobj

    if axisoff
        axis("off")
    elseif axislabel
        output = plot_xylabel(aunit)
        outdict["xlabelobj"] = output[1]
        outdict["ylabelobj"] = output[2]
    end

    if add_colorbar
        outdict["colorbarobj"] = plot_colorbar(funit)
    end

    return outdict
end

function get_imextent(
    image::AbstractEHTImage,
    angunit::Union{String,Unitful.Units,Unitful.Quantity,Nothing}=nothing)

    # check angular units
    dopixel = false
    if isnothing(angunit)
        aunit = get_unit(image.metadata["angunit"])
    elseif angunit isa String
        dopixel = startswith(lowercase(angunit), "pix")
        if dopixel == false
            aunit = get_unit(angunit)
        end
    else
        aunit = angunit
    end

    if dopixel == false
        angconv = unitconv(u"rad", aunit)

        nx, ny = size(image.data)[1:2]
        dx = image.metadata["dx"]
        dy = image.metadata["dy"]
        ixref = image.metadata["ixref"]
        iyref = image.metadata["iyref"]

        xmax = -dx * (1 - ixref - 0.5)
        xmin = -dx * (nx - ixref + 0.5)
        ymax = dy * (ny - iyref + 0.5)
        ymin = dy * (1 - iyref - 0.5)

        return [xmax, xmin, ymin, ymax] * angconv
    else
        nx, ny = size(image.data)[1:2]
        ixref = image.metadata["ixref"]
        iyref = image.metadata["iyref"]

        xmax = -1 * (1 - ixref - 0.5)
        xmin = -1 * (nx - ixref + 0.5)
        ymax = (ny - iyref + 0.5)
        ymin = (1 - iyref - 0.5)

        return [xmax, xmin, ymin, ymax]
    end
end

function plot_xylabel(
    angunit::Union{Unitful.Units,Unitful.Quantity,String};
    labelargs...)

    # get the label for angular units
    if angunit isa String
        if startswith(lowercase(angunit), "pix")
            unitlabel = "pixel"
        else
            unitlabel = get_unit(angunit)
        end
    end
    unitlabel = string(angunit)

    # make the labels and plot them
    xaxis_label = format("Relative RA ({})", unitlabel)
    yaxis_label = format("Relative Dec ({})", unitlabel)
    xlabobj = xlabel(xaxis_label, labelargs...)
    ylabobj = ylabel(yaxis_label, labelargs...)
    return xlabobj, ylabobj
end

function plot_colorbar(
    fluxunit::Union{Unitful.Units,Unitful.Quantity,String};
    colorbarargs...)

    # get flux unit
    if fluxunit isa String
        funit = get_unit(fluxunit)
    else
        funit = fluxunit
    end

    if dimension(funit) == dimension(u"K")
        label = format("Brightness Temperature ({})", string(funit))
    else
        label = format("Intensity ({})", string(funit))
    end

    cbarobj = colorbar(label=label, colorbarargs...)
    return cbarobj
end