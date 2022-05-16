# Tom's ImageMagick Scripts

A collection of imagemagick commands and scripts ***mainly for weird art projects and zines*** that I've found, modified and duct-taped together. In the grand tradition of [Fred's ImageMagick Scripts](http://www.fmwconcepts.com/imagemagick/index.php) which are awesome. For full ImageMagick installation instructions and documentation head over to the [official imagemagick docs](https://imagemagick.org/).

![magick](https://bestanimations.com/Careers/Entertainment/Magic/magician-animation-10.gif)

---

## Make a Blank Print File

These are for making a starter 8.5 x 11 inch print file for a standard home printer that you can overlay other images onto. The argument given to the -size option are pixel counts and are set at fairly standard dimensions for good and excellent print resolution.

```bash
  # decent resolution / vertical orientation
  convert -size 2550x3300 xc:white empty.png
  
  # decent resolution / horizontal orientation
  convert -size 3300x2550 xc:white empty.png
  
  # excellent resolution / vertical orientation
  convert -size 3400x4400 xc:white empty.png
  
  # excellent resolution / horizontal orientation
  convert -size 4400x3400 xc:white empty.png
```

---

## Rotate an Image

This ones obvious but the argument number after -rotate is in degrees. Note that the output file sometimes may have to be different than the input file, maybe with certain filetypes. Couldn't reproduce the error so for now in place rotations seem fine. Also note that if images are rotated at non-right angles white space will be created in corners, seemingly even if the output is a png.

```bash
  # rotate 90 degrees clockwise
  convert image.jpg -rotate 90 image.jpg
  
  # rotate 180 degrees clockwise
  convert image.jpg -rotate 180 image.jpg
  
  # rotate 45 degrees clockwise / creates whitespace in corners
  convert image.jpg -rotate 45 image.jpg
```

---

## Resize an Image

This ones also obvious but its worth noting a couple things. If the bang ("!") is not present the resized image will ***fit inside*** the desired dimensions, meaning one of the two dimensions will be resized to fit one of the new dimensions and the other dimension will maintain the original aspect ratio. To force the image into the new aspect ration add a bang ("!").

```bash
  # force image to fit INSIDE desired pixel dimensions / retains original aspect ration
  convert image.jpg -resize 100x100 image.jpg
  
  # force image to MATCH desired pixel dimensions / may distort image to match desired aspect ratio
  convert image.jpg -resize 100x100 image.jpg
```
