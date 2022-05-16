# Tom's ImageMagick Scripts

A collection of imagemagick commands and scripts ***mainly for weird art projects and zines*** that I've found, modified and duct-taped together. In the grand tradition of [Fred's ImageMagick Scripts](http://www.fmwconcepts.com/imagemagick/index.php) which are awesome. For full ImageMagick installation instructions and documentation head over to the [official imagemagick docs](https://imagemagick.org/).

![magick](https://bestanimations.com/Careers/Entertainment/Magic/magician-animation-10.gif)

---

## Make a Blank Print File 📄

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

## Rotate an Image ♻️

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

## Resize an Image 🗜

This ones also obvious but its worth noting a couple things. If the bang ("!") is not present the resized image will ***fit inside*** the desired dimensions, meaning one of the two dimensions will be resized to fit one of the new dimensions and the other dimension will maintain the original aspect ratio. To force the image into the new aspect ration add a bang ("!").

```bash
  # force image to fit INSIDE desired pixel dimensions / retains original aspect ration
  convert image.jpg -resize 100x100 image.jpg
  
  # force image to MATCH desired pixel dimensions / may distort image to match desired aspect ratio
  convert image.jpg -resize 100x100! image.jpg
  
  # force image to FILL desired pixel dimensions / may be larger than desired / retains original aspect ratio
  convert image.jpg -resize 100x100^ image.jpg
```

---

## Crop or Contain an Image ✂️

This one is more niche, I'm using it to process user input images of varying aspect ratios and sizes to fit into printable zine pages. The user is given the option to crop or contain their images into the print space but the centering and adding of whitespace is critical to automate properly placing them in a larger multi-page print file.

```bash
  # this resizes the image to fit INSIDE the desired dimensions retaining the original aspect ratio and adding white space,  outputting a centered version of the image with desired dimensions
  convert image.jpg -resize 100x100 image2.jpeg -extent 100x100 image.jpg
  
  # this forces image to FILL the desired dimensions retaining the original aspect ratio and cropping a centered version of the image with the desired dimensions
  convert image.jpg -resize 100x100^ -gravity center -extent 100x100 image.jpg
```

---

## Combining Images 👥

This one's pretty straight-forward but centering the overlayed image versus giving it a specific location is pretty important if your doing anything more complex.

```bash
  # this will overlay image1.jpg on top of image2.jpg right in the center and output image3.jpg
  magick composite -gravity center image1.jpg image2.jpg image3.jpg
  
  # this will overlay image1.jpg on top of image2.jpg at the top left corner and output image3.jpg
  magick composite -compose atop -geometry +0+0 image1.jpg image2.jpg image3.jpg
  
  # this will overlay image1.jpg on top of image2.jpg along the left edge 150 pixels down and output image3.jpg
  magick composite -compose atop -geometry +0+150 image1.jpg image2.jpg image3.jpg

  # this will overlay image1.jpg on top of image2.jpg 150 pixels down and 100 pixels to the right of the top left corner
  magick composite -compose atop -geometry +100+150 image1.jpg image2.jpg image3.jpg
  
  # this will add cumulatively by overlaying image1.jpg on top of image2.jpg and overriding the old image2.jpg
  magick composite -geometry +100+200 image1.jpeg image2.jpg image2.jpg
  
  # ~~~~~~~~~~~~~~~~~~~~~~~~~

  # just a side-note, this is insane but imagemagick has some buit in images like "rose" in this example
  magick composite -gravity center image2.jpeg rose: rose-over.jpeg
```
