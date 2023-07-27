# Disk Intensity Images
[`DiskIntensityImage`](@ref) provides a disk-based implementation of the 5D intensity image. 
Image data is stored in a NetCDF4 container, and data will be lazily loaded. NetCDF4 is a widely-used ND-labeled data format, which uses HDF5 in the lower level and therefore are accessible by interfaces for both NetCDF4 and HDF5 available for all most programming langages used in Scientific Computing.
Internally, it uses a self-descriptive data set using the `NCDataset` type of [NCDatasets.jl](URL). Thanks to the feature-rich [NCDatasets.jl](URL), the package allows to store the image in an arbitrary HDF group --- this means users can store multiple data sets not limited to images in a single file. 

## Converting an Image FITS file into NetCDF4 format
Here, we will use a FITS image created by Python's eht-imaging library, which was used in [Chael et al. 2023](https://ui.adsabs.harvard.edu/abs/2023ApJ...945...40C/abstract). Let's download the data and load into the`IntensityImage` instance.
```@example 1
using Downloads: download
using EHTImages

# Download a FITS image
fitsname = download("https://github.com/achael/multifrequency_scripts/raw/main/sec_4.2/images_M87_Chael/M87_230GHz_Chael.fits")

# Load the FITS image into an IntensityImage instance
image = load_fits(fitsname)
```
You can save data into NetCDF4 file with [`save_netcdf!`](@ref) method. 


All of the loaded intensity images, including their metadata, are loaded into the field `image.dimstack::EHTDimensionalData.DimStack`.
```julia
image.dimstack # will give an access to the dimstack instance storing all image data.
```
[`IntensityImage`](@ref) is *immutable*, so users cannot change the `DimStack` object associated with an [`IntensityImage`](@ref) instance to something else. However, arrays and metadata stored in the `DimStack` object are *mutable*. This allows users to flexibly edit data inside.

## Accessing to and editing data
You can access to the raw array of the intensity image in dimension of (x, y, polarization, fequency, time) by
```@example 1
image.data # return an array of intensity in the unit of Jy/pixel
```
You can access to the label or coordinates of each axis by
```@example 1
image.p # return an array of polarization labels in string
```
```@example 1
image.t # return an array of time in MJD
```
```@example 1
image.f # return an array of frequencies in Hz
```
Now you can see that this particular image is a single-frequency, single-stokes, and single-epoch image with 512 x 512 pixels. For the spatial extent, there is a dedicated method [`get_xygrid(::AbstractIntensityImage)`](@ref). By default, it returns a series of central coordinates in radians.
```@example 1
xygrid = get_xygrid(image)
```
or you can specify a unit in mutliple ways.
```@example 1
# use string
xygrid = get_xygrid(image, "μas")

# use Unitful
using Unitful
using UnitfulAngles
xygrid = get_xygrid(image, u"μas")

# use preload units in EHTUtils
using EHTUtils # preload units
xygrid = get_xygrid(image, μas)
```
Now you see that this image has a field of view of about 1022 μas in each axes. If you need to sample a vector from each you can simply use `collect(xygrid[1])`.

Metadata are stored in `OrderedDict`. You can access to metadata from the `metadata` field.
```@example 1
image.metadata # access to metadata
```
As noted eariler, arrays and metadata stored in [`IntensityImage`](@ref) instances are *mutable*. This allows users to flexibly edit data inside.
```@example 1
image.metadata[:observer] = "Wonderful Astronomer" # edit metadata
image.metadata
```

## Plotting Images
### Intensity map
The package currently relies on [PythonPlot.jl](https://github.com/stevengj/PythonPlot.jl) for image visualization. It has a customized [`imshow`](@ref) method for [`AbstractIntensityImage`](@ref) type.
```julia
using EHTUtils # for shortcuts to flux and angular units
using PythonPlot

f = figure()
ax = gca()
imshow(image, fluxunit=1e9K, angunit=μas, scale=:linear, cmap="viridis")
```
```
Dict{Any, Any} with 4 entries:
  "ylabelobj"   => <py Text(0, 0.5, 'Relative Dec (μas)')>
  "xlabelobj"   => <py Text(0.5, 0, 'Relative RA (μas)')>
  "colorbarobj" => <py matplotlib.colorbar.Colorbar object at 0x1803c3090>
  "imshowobj"   => <py matplotlib.image.AxesImage object at 0x180c20f10>
```
![imshow's output](img/intensityimage_plot1.png)

As you can see [`imshow`](@ref) will return all python objects in the generated plot so that users can further customize each component.

You can utilize a custom set of perceptually uniform colormaps implemented in the Python library [ehtplot](https://github.com/liamedeiros/ehtplot), which has been utilized in publications by the EHT Collaboration. After installing ehtplot via [CondaPkg.jl](https://github.com/cjdoris/CondaPkg.jl) (see the Installation section of the documentation), you can import and utilize it for image visualization using [PythonCall.jl](https://github.com/cjdoris/PythonCall.jl). For example:
```julia
using PythonCall  # provides the `pyimport` function
ehtplot = pyimport("ehtplot")

f = figure()
ax = gca()
# use "afmhot_us" colormap in ehtplot, a standard colormap used in the EHT Collaboration
imshow(image, fluxunit=1e9K, angunit=μas, scale=:linear, cmap="afmhot_us")
xlim(200, -200)
ylim(-200, 200)
```
![imshow's output](img/intensityimage_plot2.png)

You can also change a scale. `imshow` method has three options (`:linear`, `:log`, and `:gamma`). The dynamic range of `:log` scale contour can be controlled by `dyrange`.
```julia
f = figure()
ax = gca()
imshow(image, fluxunit=1e9K, angunit=μas, scale=:log, dyrange=1000, cmap="gnuplot2_us")
```
![imshow's output](img/intensityimage_plot3.png)

For gamma scale, the power low can be controled by `gamma`:
```julia
f = figure()
ax = gca()
imshow(image, fluxunit=1e9K, angunit=μas, scale=:gamma, gamma=0.5, cmap="cubehelix_u")
```
![imshow's output](img/intensityimage_plot4.png)

### Toolkit for a custom plot of images
Sometimes, users might want to create a custom function to plot images. There are some useful sets of methods to assist with this. Additionally, the source code for the [`imshow`](@ref) method would be helpful for learning how to use PythonPlot for custom plotting.
- [`get_imextent`](@ref) method: This method will return the extent of the image in the specified angular unit for the `PythonPlot.imshow`'s `extent` argument. Users can plot images with the actual angular scales using `PythonPlot.imshow(array, origin="lower", extent=imextent)`.
- [`get_bconv`](@ref) method: This method derives a conversion factor from Jy/Pixel (the unit for the `data` field) to an arbitrary unit of intensity.

## Saving into a FITS file
You can save a 3D cube of a sliced image using the [`save_fits!`](@ref)`(::AbstractIntensityImage, filename::AbstractString, idx=(1,1))` method. The `idx` parameter here represents the (time, frequency) indices, as popular image FITS formats do not support non-equidistant grids for time and frequency. The exported FITS file is compatible with CASA, AIPS, DIFMAP, and other EHT imaging packages (eht-imaging and SMILI).
```julia
save_fits!(image, './foobar.fits')
```

## Create a brank new image
You can create a blank 5D image directy with the [`intensityimage`](@ref) function. 
```@example
im = intensityimage(200, 1.0, μas)
```
You can specify also time, frequency, number of polarizations and all other metadata as well. Please see the docstring of [`intensityimage`](@ref) here.