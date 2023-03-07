var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = EHTImages","category":"page"},{"location":"#EHTImages","page":"Home","title":"EHTImages","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for EHTImages.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [EHTImages]","category":"page"},{"location":"#EHTImages.ehtimage_metadata_compat","page":"Home","title":"EHTImages.ehtimage_metadata_compat","text":"ehtimage_metadata_compat::NamedTuple\n\nA tuple of available values for some of keys in ehtimage_metadata_default.\n\n\n\n\n\n","category":"constant"},{"location":"#EHTImages.ehtimage_metadata_default","page":"Home","title":"EHTImages.ehtimage_metadata_default","text":"ehtimage_metadata_default::NamedTuple\n\nA tuple for the default metadata keys and values for AbstractEHTImage.\n\n\n\n\n\n","category":"constant"},{"location":"#EHTImages.ehtimage_metadata_type","page":"Home","title":"EHTImages.ehtimage_metadata_type","text":"ehtimage_metadata_default::NamedTuple\n\nA tuple of types for metadata keys in ehtimage_metadata_default.\n\n\n\n\n\n","category":"constant"},{"location":"#EHTImages.ncd_image_defaultgroup","page":"Home","title":"EHTImages.ncd_image_defaultgroup","text":"ncd_image_defaultgroup::String\n\nDefault group name of the EHT Image NetCDF4 format.\n\n\n\n\n\n","category":"constant"},{"location":"#EHTImages.ncd_image_dimnames","page":"Home","title":"EHTImages.ncd_image_dimnames","text":"ncd_image_dimnames::NamedTuple\n\nA named tuple relating Symbols to actual strings for the dimension of the EHT Image NetCDF4 format. keys are :x, :y for x and y axis, :p for polarization, :f for frequency, :t for time. \n\n\n\n\n\n","category":"constant"},{"location":"#EHTImages.ncd_image_metadata_typeconv","page":"Home","title":"EHTImages.ncd_image_metadata_typeconv","text":"ncd_image_metadata_typeconv::NamedTuple\n\nA named tuple relating Symbols to types of the corresponding variables of the EHT Image NetCDF4 format.\n\n\n\n\n\n","category":"constant"},{"location":"#EHTImages.ncd_image_vardims","page":"Home","title":"EHTImages.ncd_image_vardims","text":"ncd_image_vartypes::NamedTuple\n\nA named tuple relating Symbols to types of the corresponding variables of the EHT Image NetCDF4 format.\n\n\n\n\n\n","category":"constant"},{"location":"#EHTImages.ncd_image_varnames","page":"Home","title":"EHTImages.ncd_image_varnames","text":"ncd_image_varnames::NamedTuple\n\nA named tuple relating Symbols to names of the corresponding variables of the EHT Image NetCDF4 format.\n\n\n\n\n\n","category":"constant"},{"location":"#EHTImages.ncd_image_vartypes","page":"Home","title":"EHTImages.ncd_image_vartypes","text":"ncd_image_vartypes::NamedTuple\n\nA named tuple relating Symbols to types of the corresponding variables of the EHT Image NetCDF4 format.\n\n\n\n\n\n","category":"constant"},{"location":"#EHTImages.DDImage","page":"Home","title":"EHTImages.DDImage","text":"struct DDImage <: AbstractEHTImage\n\n<: AbstractEHTImage\n\nA data type for five dimensional images of which data are all stored in the memory.  This format relies on DimensionalData.DimArray to provide an easy access of data through many useful methods in Dimensional Data. Note that this data type is immutable. \n\nFields\n\ndata::Array{Float64, 5}:   The five dimensional intensity disbrituions. Alias to dimarray.data.\npol::Vector{String}:   The polarization code, giving the polarization axis (:p) of dimarray.   Alias to dimarray.dims[3].val.data.\nfreq::Vector{Float64}:   The central frequency in Hz, giving the frequency axis (:f) of dimarray.   Alias to dimarray.dims[4].val.data.\nmjd::Vector{Float64}:   The modified Julian date, giving the time axis (:t) of dimarray.   Alias to dimarray.dims[5].val.data.\nmetadata::OrderedDict:   metadata.\ndimarray::DimArray{Float64, 5}.   DimArray stroing all of data, pol, freq, mjd and metadata.\n\n\n\n\n\n","category":"type"},{"location":"#EHTImages.DataStorageType","page":"Home","title":"EHTImages.DataStorageType","text":"DataStorageType\n\nInternal type for specifying the nature of the location of data.\n\n\n\n\n\n","category":"type"},{"location":"#EHTImages.IsDiskData","page":"Home","title":"EHTImages.IsDiskData","text":"struct IsDiskData <: EHTImages.DataStorageType\n\nDefines a trait that a states that data is disk based.\n\n\n\n\n\n","category":"type"},{"location":"#EHTImages.NotDiskData","page":"Home","title":"EHTImages.NotDiskData","text":"struct NotDiskData <: EHTImages.DataStorageType\n\nDefines a trait that a states that data is memory based.\n\n\n\n\n\n","category":"type"},{"location":"#Base.close-Tuple{NCImage}","page":"Home","title":"Base.close","text":"close(image::NCImage)\n\nClose the access to the associated NetCDF4 file. This function is an alias to close!(image).\n\n\n\n\n\n","category":"method"},{"location":"#Base.isopen-Tuple{AbstractEHTImage}","page":"Home","title":"Base.isopen","text":"isopen(image::AbstractEHTImage)\n\nCheck if data is accessible, return true for accessible data and false if data is not accessible. This is relevant if image is based on disk data.\n\n\n\n\n\n","category":"method"},{"location":"#Base.iswritable-Tuple{AbstractEHTImage}","page":"Home","title":"Base.iswritable","text":"isopen(image::AbstractEHTImage)\n\nCheck if data is accessible, return true for accessible data and false if data is not accessible. This is relevant if image is based on disk data.\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.close!-Tuple{NCImage}","page":"Home","title":"EHTImages.close!","text":"close!(image::NCImage)\n\nClose the access to the associated NetCDF4 file.\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.convolve!-Tuple{AbstractEHTImage, EHTModels.AbstractModel}","page":"Home","title":"EHTImages.convolve!","text":"convolve!(image, model; ex)\n\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.convolve-Tuple{AbstractEHTImage, EHTModels.AbstractModel}","page":"Home","title":"EHTImages.convolve","text":"convolve(image, model; ex)\n\n\n-> AbstractEHTImage\n\nConvolve the input image with a given model, and return the convolved image.\n\nArguments\n\nimage::AbstractEHTImage:   The input image. It must be not disk-based.\nmodel::EHTModels.AbstractModel:  The model to be used as the convolution kernel. \nex=SequentialEx()   An executor of FLoops.jl.\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.copy_metadata!-Tuple{AbstractEHTImage, EHTUVData.AbstractUVDataSet}","page":"Home","title":"EHTImages.copy_metadata!","text":"copy_metadata!(image::AbstractEHTImage, uvdataset::AbstractUVDataSet)\n\ncopy metadata from the given uvdataset.\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.create_ddimage-Tuple{DimensionalData.DimArray}","page":"Home","title":"EHTImages.create_ddimage","text":"create_ddimage(dimarray::DimArray)\n\nCreate DDImage instance from a given DimArray.\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.create_ddimage-Tuple{Integer, Real, Union{String, Unitful.Quantity, Unitful.Units}}","page":"Home","title":"EHTImages.create_ddimage","text":"create_image(nx, dx, angunit; keywords) -> DDImage\ncreate_ddimage(nx, dx, angunit; keywords) -> DDImage\n\nCreate and return a blank DDImage object.\n\nArguments\n\nnx::Integer:   the number of pixels along with the horizontal axis. Must be positive.\ndx::Real:   the pixel size of the horizontal axis. Must be positive.\nangunit::Union{Unitful.Quantity, Unitful.Units or String}=rad:   the angular unit for dx and dy.\n\nKeywords\n\nny::Real=nx:   the number of pixels along with the vertical axis. Must be positive.  \ndy::Real=dx:   the pixel size of the vertical axis. Must be positive.\nixref::Real=(nx + 1) / 2, iyref::Real=(ny + 1) / 2:   index of the reference pixels along with the horizontal and vertical    axises, respectively. Default values set to the center of the field   of the view.\npol::Symbol=:single:   number of polarizations. Availables are :single or :full (i.e. four)   polarizations.\nfreq::Vector{Float64}=[1.0]:   a vector for frequencies in the unit of Hz\nmjd::Vector{Float64}=[0.0]:   a vector for time in the unit of MJD.\nmetadata::AbstractDict=default_metadata(NCImage()):   other metadata. Note that the above keywords and arguments will overwrite   the values of the conflicting keys in this metadata argument.\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.create_ncimage-Tuple{AbstractString, Integer, Real, Union{String, Unitful.Quantity, Unitful.Units}}","page":"Home","title":"EHTImages.create_ncimage","text":"create_ncimage(filename, nx, dx, angunit; keywords) -> NCImage\n\nCreate a blank NCImage object. Return NCImage data loaded with :read mode.\n\nArguments\n\nfilename::AbstractString:   NetCDF4 file where image data will be created.\nnx::Integer:   the number of pixels along with the horizontal axis. Must be positive.\ndx::Real:   the pixel size of the horizontal axis. Must be positive.\nangunit::Union{Unitful.Quantity, Unitful.Units or String}=rad:   the angular unit for dx and dy.\n\nKeywords\n\nny::Real=nx:   the number of pixels along with the vertical axis. Must be positive.  \ndy::Real=dx:   the pixel size of the vertical axis. Must be positive.\nixref::Real=(nx + 1) / 2, iyref::Real=(ny + 1) / 2:   index of the reference pixels along with the horizontal and vertical    axises, respectively. Default values set to the center of the field   of the view.\npol::Symbol=:single:   number of polarizations. Availables are :single or :full (i.e. four)   polarizations.\nfreq::Vector{Float64}=[1.0]:   a vector for frequencies in the unit of Hz\nmjd::Vector{Float64}=[0.0]:   a vector for time in the unit of MJD.\nmetadata::AbstractDict=default_metadata(NCImage()):   other metadata. Note that the above keywords and arguments will overwrite   the values of the conflicting keys in this metadata argument.\nmode::Symbol=:create:   The access mode to NCDataset.   Available modes are :read, :append, :create.   See help for EHTNCDBase.ncdmodes for details.\ngroup::AbstractString=EHTImage.ncd_image_defaultgroup:   The group of the image data in the input NetCDF4 file.\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.default_metadata-Tuple{AbstractEHTImage}","page":"Home","title":"EHTImages.default_metadata","text":"default_metadata(dataset) -> OrderedDict\n\nReturn the default metadata of the given dataset.\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.define_ncd_image_dimensions!","page":"Home","title":"EHTImages.define_ncd_image_dimensions!","text":"define_ncd_image_dimensions!(ncd[, nx, ny, np, nf, nt])\n\nDefine NetCDF4 dimensions based on the given size of the image data.\n\n\n\n\n\n","category":"function"},{"location":"#EHTImages.define_ncd_image_variables!-Tuple{Any}","page":"Home","title":"EHTImages.define_ncd_image_variables!","text":"define_ncd_image_variables!(ncd)\n\nDefine NetCDF4 variables based on EHT NetCDF4 Image Format.\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.get_bconv-Tuple{AbstractEHTImage}","page":"Home","title":"EHTImages.get_bconv","text":"get_bconv\n\nget a conversion factor from Jy/pixel (used in AbstractEHTImage.data) to an arbitrary unit for the intensity. fluxunit is for the unit of the flux density (e.g. Jy, mJy, μJy) or brightness temperture (e.g. K), while saunit is for the unit of the solid angle (pixel, beam, mas, μJy).\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.get_uvgrid","page":"Home","title":"EHTImages.get_uvgrid","text":"get_uvgrid(metadata, dofftshift=true)\n\nreturning u and v grids corresponding to the image field of view and pixel size.\n\n\n\n\n\n","category":"function"},{"location":"#EHTImages.get_uvgrid-2","page":"Home","title":"EHTImages.get_uvgrid","text":"get_uvgrid(image, dofftshift=true)\n\nreturning u and v grids corresponding to the image field of view and pixel size.\n\n\n\n\n\n","category":"function"},{"location":"#EHTImages.get_xygrid","page":"Home","title":"EHTImages.get_xygrid","text":"get_xygrid --> Tuple{StepRangeLen, StepRangeLen}\n\nReturning 1-dimensional StepRangeLen objects for the grids along with x and y axis in the given angular unit specified by angunit.\n\nArguments\n\nmetadata::Dict{Symbol, Any}-like: Input dictionary.\nangunit::Union{Unitful.Quantity,Unitful.Units,String}=rad: Angular units of the output pixel grids.\n\n\n\n\n\n","category":"function"},{"location":"#EHTImages.get_xygrid-2","page":"Home","title":"EHTImages.get_xygrid","text":"get_xygrid\n\nReturning 1-dimensional StepRange objects for the grids along with x and y axis in the given angular unit specified by angunit.\n\n\n\n\n\n","category":"function"},{"location":"#EHTImages.isdiskdata-Tuple{AbstractEHTImage}","page":"Home","title":"EHTImages.isdiskdata","text":"isdiskdata(data)\n\nDetermines whether the data is disk-based or memory-based. Return IsDiskData() if data is disk-based, while return NotDiskData() if data is memory-based.\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.load-Tuple{NCImage}","page":"Home","title":"EHTImages.load","text":"load(image::NCImage) --> DDImage\n\nLoad image data from the input disk image to memory. \n\nArguments\n\nimage::NCImage: Input NCImage. \n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.load_fits","page":"Home","title":"EHTImages.load_fits","text":"load_fits(filename::AbstractString, hduid::Integer=1)\n\nLoad the input FITS image into DDImage (in-memory image data).\n\nArguments\n\nfilename::AbstractString: name of the input FITS file\nhduid::Integer=1: ID of the HDU to be loaded. Default to the primary HDU.\n\n\n\n\n\n","category":"function"},{"location":"#EHTImages.load_fits-2","page":"Home","title":"EHTImages.load_fits","text":"load_fits(filename::FITS, hduid::Integer=1)\n\nLoad the input FITS image into DDImage (in-memory image data).\n\nArguments\n\nfits::FITS: the input FITS data\nhduid::Integer=1: ID of the HDU to be loaded. Default to the primary HDU.\n\n\n\n\n\n","category":"function"},{"location":"#EHTImages.load_fits-Tuple{FITSIO.ImageHDU}","page":"Home","title":"EHTImages.load_fits","text":"load_fits(hdu)\n\nLoad the input FITS image into DDImage (in-memory image data).\n\nArguments\n\nhdu::ImageHDU: the input image HDU data\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.load_image-Tuple{AbstractString}","page":"Home","title":"EHTImages.load_image","text":"load_image(filename; [group, mode]) -> NCImage\n\nLoad image data from the specified group in the given NetCDF4 file  with the specified access mode.\n\nArguments\n\nfilename::AbstractString:   The input NetCDF4 file.\ngroup::AbstractString=EHTImage.ncd_image_defaultgroup   The group of the image data in the input NetCDF4 file.\nmode::Symbol=:read:   The access mode to NCDataset.   Available modes are :read, :append, :create.   See help for EHTImage.ncdmodes for details.\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.open!","page":"Home","title":"EHTImages.open!","text":"open!(image[, mode])\n\nLoad image data from NCDataset specified in the input image object with the given access mode. If image data are already opened,  it will close it and reload data again.\n\nArguments\n\nimage::NCImage:   The input image object.\nmode::Symbol=:read:   The access mode to NCDataset.   Available modes are :read, :append, :create.   See help for EHTImage.ncdmodes for details.\n\n\n\n\n\n","category":"function"},{"location":"#EHTImages.save_fits!","page":"Home","title":"EHTImages.save_fits!","text":"save_fits[!](image::AbstractEHTImage, filename::AbstractString, idx=(1, 1); fitstype::Symbol=:casa)\n\nSaving the image into a FITS file in a specifed format.\n\nArguments\n\nimage::AbstractEHTImage: the input image\nfilename::AbstractString: the name of the output FITS file\nidx: the index of the saved image. Should be (frequency index, time index). Default to (1,1).\n\nKeywords\n\nfitstype::Symbol: the format type of the output FITS. Availables are :casa (CASA compatible).\n\n\n\n\n\n","category":"function"},{"location":"#EHTImages.save_netcdf!-Tuple{AbstractEHTImage, AbstractString}","page":"Home","title":"EHTImages.save_netcdf!","text":"save_netcdf!(image, filename; [mode, group])\n\nSave image data to NetCDF4 format. \n\nArguments\n\nimage::AbstractEHTImage   Input image data\nfilename::AbstractString:   NetCDF4 file where image data will be saved.\nmode::Symbol=:create:   The access mode to NCDataset.   Available modes are :read, :append, :create.   See help for EHTNCDBase.ncdmodes for details.\ngroup::AbstractString=EHTImage.ncd_image_defaultgroup:   The group of the image data in the input NetCDF4 file.\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.save_netcdf-Tuple{AbstractEHTImage, AbstractString}","page":"Home","title":"EHTImages.save_netcdf","text":"save_netcdf(image, filename; [mode=:create, group=\"image\"]) => NCImage\n\nSave image data to NetCDF4 format. Saved data will be loaded and returned with :read access mode.\n\nArguments\n\nimage::AbstractEHTImage   Input image data\nfilename::AbstractString:   NetCDF4 file where image data will be saved.\nmode::Symbol=:create:   The access mode to NCDataset.   Available modes are :read, :append, :create.   See help for EHTNCDBase.ncdmodes for details.\ngroup::AbstractString=EHTImage.ncd_image_defaultgroup:   The group of the image data in the input NetCDF4 file.\n\n\n\n\n\n","category":"method"},{"location":"#EHTImages.set_ncd_image_metadata!-Tuple{Any, Any}","page":"Home","title":"EHTImages.set_ncd_image_metadata!","text":"set_ncd_image_metadata!(ncd)\n\nSet NetCDF4 metadata based on EHT NetCDF4 Image Format.\n\n\n\n\n\n","category":"method"}]
}
