# Zine Magick Scripts

Hi there! 👋 This is a collection of ImageMagick scripts I initially put together to help make quick printer-friendly zines with my two-year-old but it's slowly evolving into a [web interface / heroku project](https://www.zine.garden/). Indirectly inspired by [Fred's ImageMagick Scripts](http://www.fmwconcepts.com/imagemagick/index.php) which are awesome and much more extensive than these.

The larger zine-building scripts below will process folders of images with mixed aspect ratios and resolutions into printable zine pdfs. The pages will print out in the proper order and with the proper rotations to be printed out on standard 8.5 x 11 inch paper through a home or office printer. Pagination is set up for the simplest possible side-staple binding. This means each individual sheet should be folded, then stacked side-by-side rather than clam-shelled / nested together, and then stapled along the binding with the zine closed.

For full ImageMagick installation instructions and documentation head over to the [official ImageMagick docs](https://imagemagick.org/).

```
⚠️ Warning: These are definitely a work in progress!
```

![magick](https://bestanimations.com/Careers/Entertainment/Magic/magician-animation-10.gif)


### Basic Scripts
1. [Make a Blank Print File](#make-a-blank-print-file)
2. [Rotate an Image](#rotate-an-image)
3. [Resize an Image](#resize-an-image)
4. [Crop or Contain an Image](#crop-or-contain-an-image)
5. [Combining Images](#combining-images)
6. [Get Images in Directory](#get-images-in-directory)


### Zine-Building Scripts
1. [Make a Half-Page Vertical Zine](#make-a-half-page-vertical-zine)
2. [Make a Quarter-Page Vertical Zine](#make-a-quarter-page-vertical-zine)
3. [Make an Eighth-Page Vertical Zine](#make-an-eighth-page-vertical-zine)

```more sizes / orientations in the works!...```




---

# The Basics

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
  convert image.jpg -resize 100x100! image.jpg
  
  # force image to FILL desired pixel dimensions / may be larger than desired / retains original aspect ratio
  convert image.jpg -resize 100x100^ image.jpg
```

---

## Crop or Contain an Image

This one is more niche, I'm using it to process user input images of varying aspect ratios and sizes to fit into printable zine pages. The user is given the option to crop or contain their images into the print space but the centering and adding of whitespace is critical to automate properly placing them in a larger multi-page print file.

```bash
  # this resizes the image to fit INSIDE the desired dimensions retaining the original aspect ratio and adding white space,  outputting a centered version of the image with desired dimensions
  convert image.jpg -resize 100x100 image2.jpeg -extent 100x100 image.jpg
  
  # this forces image to FILL the desired dimensions retaining the original aspect ratio and cropping a centered version of the image with the desired dimensions
  convert image.jpg -resize 100x100^ -gravity center -extent 100x100 image.jpg
```

---

## Combining Images

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

## Get Images in Directory

This is a bash script not image magick but it's useful for using image magick to do dynamic stuff to a batch of images. Basically it just stores all file names in an bash array and then iterates through them and lets you do whatever you want with each one.

```bash
  arr=(~/images-folder/*)

  # iterate through array using a counter
  for ((i=0; i<${#arr[@]}; i++)); do
      # insert image magick here
      echo "${arr[$i]}"
  done
```

---

[[back to top]](#zine-magick-scripts)








# Make a Half-Page Vertical Zine

This script builds probably the most standard zine layout, an 8.5 x 11 inch sheet of standard printer paper folded in half forming a vertically oriented 5.5 inch wide 8.5 inch tall booklet. As stated at 
[the start of this readme](#zine-magick-scripts) this script assumes a side-staple or japanese sewn binding rather than saddle binding with pages clam-shelled together which is completely different in terms of page ordering and requires a different script.

To use the script make a folder called "zine-images-originals" and fill it with the images you want to turn into zine pages. Then paste the following into a bash script file, comment in / out the desired settings for size, style etc. and then run the script. Make sure to have [imagemagick](#zine-magick-scripts) properly installed!

* vertical / portrait orientation
* 8.5 x 5.5 inch zine
* 8.5 x 11 inch print paper
* home or office printer friendly
* 64 pages max (32 sheets)

```bash
  # ~~~~~~~~~~ GENERAL SETUP ~~~~~~~~~~~~~~~~~~~~

  # first we delete and recreate our zine images directory
  # we copy all of our original input images into this directory to manipulate
  rm -rf zine-images
  cp -r zine-images-originals zine-images

  # also delete the zine pages folder if it exists and remake it empty
  rm -rf zine-pages
  mkdir zine-pages

  # then we capture all the filenames in an array
  # we grab the length for reference also since thats a pain in bash
  zineImageFileNames=(./zine-images/*)
  zineImageCount=${#zineImageFileNames[@]}

  # now we set the max number of images per page
  # we also set the maximum number of image that can be on a sheet which could be calculated too
  pageMax=2
  sheetMax=4

  # now we calculate the number of pages we'll need
  # this may need to be adjusted for larger zine counts and should be tested
  # it divides the total number of images for the zine by how many can fit on the page rounding down
  # then it adds another tow pages (one double-sided print sheet) if there were any leftover pages
  # its good this is here but it really shouldnt be used
  # zine page counts should be adjusted to fit evenly onto desired print layout without blank end pages
  pagesNeeded=$(((zineImageCount / pageMax)+((zineImageCount % pageMax > 0 ) * 2)))

  # below are the pixel dimensions for page files which represent resolution
  # these will determine how pixellated or compressed any styling done later on is
  # comment them in and out freely to experiment

  # xPageSizePixels=3400
  # yPageSizePixels=4400

  # xPageSizePixels=1700
  # yPageSizePixels=2200

  # xPageSizePixels=850
  # yPageSizePixels=1100

  xPageSizePixels=425
  yPageSizePixels=550

  # xPageSizePixels=217
  # yPageSizePixels=275




  # ~~~~~~~~~~ CREATE BLANK PAGES ~~~~~~~~~~~~~~~~~~~~

  # this approach makes blank pages first to overlay the images onto later
  # making the blank page files doesn't need to happen first but might as well
  # first it makes a single starter blank page to copy which speed things up
  convert -size ${xPageSizePixels}x${yPageSizePixels} xc:white zine-pages/1-page.png

  # then it makes all blank pages in new directory
  # this is just faster than making each page with convert
  for ((i=1; i<${pagesNeeded}; i++)); do
    cp zine-pages/1-page.png zine-pages/$(($i+1))-page.png
  done




  # ~~~~~~~~~~ ROTATE IMAGE FILES ~~~~~~~~~~~~~~~~~~~~

  # this uses a rotation pattern array with numbers representing clockwise degrees
  # it can be referenced dynamically for any page number with some modulus arithmatic
  # the pattern here is tricky since it needs to be applied before reordering the images for page placement
  # this is best calculated manually with a physical mock-up of the zine size

  rotations=(270 90 90 270) # <--- set these manually for different zine layouts
  rotationsLength=${#rotations[@]}

  for ((i=0; i<$((zineImageCount)); i++)); do
    rotation=${rotations[$((i % rotationsLength))]}
    zineImage=${zineImageFileNames[$((i))]}
    convert $zineImage -rotate $rotation $zineImage
  done




  # ~~~~~~~~~~ CALCULATE IMAGE POSITION COORDINATES ~~~~~~~~~~~~~~~~~~~~

  # this determines the desired individual image size 
  # this will allow us so simply place it on the page files by coordinate
  # these could be calculated dynamically but can be determined manually
  # its easier to do with a physical mockup
  # percentages were determined by measuring in 1/8th inch units
  # could also have been done with millimeters
  # image sizes are percentages of total page height / width accounting for 1/8th inch border gaps
  # the border gaps are to match the 1/8th inch unprited white boarder on most home printers

  xImagePercent=9706 # represents 97.06% <-- set this manually for different zine layouts
  yImagePercent=4773 # represents 47.73% <-- set this manually for different zine layouts

  # calculate percentages into pixels
  xImageSizePixels=$(((xImagePercent * xPageSizePixels) / 10000)) # <-- division simulates percentage
  yImageSizePixels=$(((yImagePercent * yPageSizePixels) / 10000))
  # note that bash only uses integers so perform calculation manually before running script

  # this resizes all images in place
  # this has to happen after rotation right now but should be changed for efficiency later
  for ((i=0; i<$((zineImageCount)); i++)); do
    zineImage=${zineImageFileNames[$((i))]}
    convert $zineImage -resize $((xImageSizePixels))x$((yImageSizePixels))^ -gravity center -extent $((xImageSizePixels))x$((yImageSizePixels)) $zineImage
  done




  # ~~~~~~~~~~ CALCULATE IMAGE ORDER FOR PAGES ~~~~~~~~~~~~~~~~~~~~

  # this renames the pages based on the order they should be added to the pages
  # this gets more complicated the smaller the zine gets
  # its best figured out with a physical mockup of the zine size
  # this array can give us the correct relative orders for any image count with some modulus arithmatic
  # the first image for a page will get reordered to the number at index 0 in the array
  # the second will be assigned the relative order number at index 1 and so on
  # the pattern repeats for every print sheet meaning front and back

  relativePageOrders=(1 3 4 2) # <--- set these manually for different zine layouts
  relativePageOrdersLength=${#relativePageOrders[@]}

  # rename all zine image files for correct order
  for ((i=0; i<$((zineImageCount)); i++)); do
    zineImage=${zineImageFileNames[$((i))]}
    relativeOrder=${relativePageOrders[$((i % relativePageOrdersLength))]}
    pageNumber=$((((i) / 4))) # <-- first page is zero since divide will always round down
    absoluteOrder=$(((pageNumber * 4) + relativeOrder))

    # use some horrible bash syntax to separate the filetype for renaming
    extension="${zineImage##*.}"
    newFileName=./zine-images/$((absoluteOrder))-ordered.$extension
    mv $zineImage ./zine-images/$((absoluteOrder))-ordered.$extension
  done




  # ~~~~~~~~~~ CALCULATE IMAGE POSITION COORDINATES ~~~~~~~~~~~~~~~~~~~~

  # coordinates are split into two arrays so they can be easily looked up in later iteration
  # there are only two coordinates because this is a half page zine with two images per page
  # more coordinates can be added here for smaller zines
  # they start as percentages and are translated to pixels based on page size

  xCoordinatesPercentages=(147 147) # representing 1.47% 1.47%
  yCoordinatesPercentages=(114 5114) # representing 1.14% 51.14%

  xCoordinatesPercentagesLength=${#xCoordinatesPercentages[@]}
  yCoordinatesPercentagesLength=${#yCoordinatesPercentages[@]}

  xCoordinatesPixels=()
  yCoordinatesPixels=()

  # calculate these percentages into pixels and add to coordinate arrays
  # again bash cant do floating point numbers so percentages are calculated with integers
  for ((i=0; i<$((xCoordinatesPercentagesLength)); i++)); do
    pixelValue=$(((xCoordinatesPercentages[$i] * xPageSizePixels) / 10000))
    xCoordinatesPixels+=($pixelValue)
  done

  for ((i=0; i<$((yCoordinatesPercentagesLength)); i++)); do
    pixelValue=$(((yCoordinatesPercentages[$i] * yPageSizePixels) / 10000))
    yCoordinatesPixels+=($pixelValue)
  done




  # ~~~~~~~~~~ ADD IMAGES TO PAGES ~~~~~~~~~~~~~~~~~~~~

  # recollect new image names
  zineImageFileNames=(./zine-images/*)

  # place all zine images on pages in new order alternating positions
  for ((i=0; i<$((zineImageCount)); i++)); do
    zineImage=${zineImageFileNames[$((i))]}
    xPosition=$((xCoordinatesPixels[$((i % xCoordinatesPercentagesLength))]))
    yPosition=$((yCoordinatesPixels[$((i % yCoordinatesPercentagesLength))]))
    pageNumber=$((((i) / 2) + 1)) # first page is zero since divide will always round down

    magick composite -geometry +$((xPosition))+$((yPosition)) $zineImage ./zine-pages/$((pageNumber))-page.png ./zine-pages/$((pageNumber))-page.png
  done




  # ~~~~~~~~~~ STYLE PAGES ~~~~~~~~~~~~~~~~~~~~

  # collect page file names and length then iterate through
  pageFileNames=(./zine-pages/*)
  pageFileCount=${#pageFileNames[@]}

  for ((i=0; i<$((pageFileCount)); i++)); do
    # grab page name and apply imagemagick styling
    pageFileName=${pageFileNames[$((i))]}
    convert $pageFileName -colorspace gray -ordered-dither o2x2 $pageFileName
  done




  # ~~~~~~~~~~ INCREASE PAGE RESOLUTION FOR PRINT ~~~~~~~~~~~~~~~~~~~~

  # this is to help retain the pixel sharpness on lower resolution dithers etc
  # the conversion to a jpeg is to help speed up printing

  for ((i=0; i<$((pageFileCount)); i++)); do
    pageFileName=${pageFileNames[$((i))]}

    convert $pageFileName -filter point -resize 1700x2200 $pageFileName
    magick $pageFileName ./zine-pages/$((i))-page.jpg
    rm $pageFileName
  done



  # ~~~~~~~~~~ COMBINE INTO SINGLE PDF ~~~~~~~~~~~~~~~~~~~~
  currentTime=`date -u +%s`
  magick convert ./zine-pages/* zine-${currentTime}.pdf
```

---

[[back to top]](#zine-magick-scripts)















# Make a Quarter-Page Vertical Zine

This script builds a less common zine size but my personal favorite, an 8.5 x 11 inch sheet of standard printer paper folded in quarters forming a vertically oriented 4.25 inch wide 5.5 inch tall booklet. Once again, as stated in 
[the start of this readme](#zine-magick-scripts) this script assumes a side-staple or japanese sewn binding rather than saddle binding with pages clam-shelled together which would still be completely different in terms of page ordering.

To use the script make a folder called "zine-images-originals" and fill it with the images you want to turn into zine pages. Then paste the following into a bash script file, comment in / out the desired settings for size, style etc. and then run the script. Make sure to have [imagemagick](#zine-magick-scripts) properly installed!

* vertical / portrait orientation
* 4.25 x 5.5 inch zine
* 8.5 x 11 inch print paper
* home or office printer friendly
* 64 pages max (32 sheets)

```bash
  # ~~~~~~~~~~ GENERAL SETUP ~~~~~~~~~~~~~~~~~~~~

  # first we delete and recreate our zine images directory
  # we copy all of our original input images into this directory to manipulate
  rm -rf zine-images
  cp -r zine-images-originals zine-images

  # also delete the zine pages folder if it exists and remake it empty
  rm -rf zine-pages
  mkdir zine-pages

  # then we capture all the filenames in an array
  # we grab the length for reference also since thats a pain in bash
  zineImageFileNames=(./zine-images/*)
  zineImageCount=${#zineImageFileNames[@]}

  # now we set the max number of images per page
  # we also set the maximum number of image that can be on a sheet which could be calculated too
  pageMax=4
  sheetMax=8

  # now we calculate the number of pages we'll need
  # this may need to be adjusted for larger zine counts and should be tested
  # it divides the total number of images for the zine by how many can fit on the page rounding down
  # then it adds another tow pages (one double-sided print sheet) if there were any leftover pages
  # its good this is here but it really shouldnt be used
  # zine page counts should be adjusted to fit evenly onto desired print layout without blank end pages
  pagesNeeded=$(((zineImageCount / pageMax)+((zineImageCount % pageMax > 0 ) * 2)))

  # below are the pixel dimensions for page files which represent resolution
  # these will determine how pixellated or compressed any styling done later on is
  # comment them in and out freely to experiment

  # xPageSizePixels=3400
  # yPageSizePixels=4400

  # xPageSizePixels=1700
  # yPageSizePixels=2200

  xPageSizePixels=850
  yPageSizePixels=1100

  # xPageSizePixels=425
  # yPageSizePixels=550

  # xPageSizePixels=217
  # yPageSizePixels=275




  # ~~~~~~~~~~ CREATE BLANK PAGES ~~~~~~~~~~~~~~~~~~~~

  # this approach makes blank pages first to overlay the images onto later
  # making the blank page files doesn't need to happen first but might as well
  # first it makes a single starter blank page to copy which speed things up
  convert -size ${xPageSizePixels}x${yPageSizePixels} xc:white zine-pages/1-page.png

  # then it makes all blank pages in new directory
  # this is just faster than making each page with convert
  for ((i=1; i<${pagesNeeded}; i++)); do
    cp zine-pages/1-page.png zine-pages/$(($i+1))-page.png
  done




  # ~~~~~~~~~~ ROTATE IMAGE FILES ~~~~~~~~~~~~~~~~~~~~

  # this uses a rotation pattern array with numbers representing clockwise degrees
  # it can be referenced dynamically for any page number with some modulus arithmatic
  # the pattern here is tricky since it needs to be applied before reordering the images for page placement
  # this is best calculated manually with a physical mock-up of the zine size

  rotations=(0 0 180 180 180 180 0 0) # <--- set these manually for different zine layouts
  # rotations=(90 90 270 270 270 270 90 90) # <--- for stupid iphone photos that are sometimes secretly rotated
  rotationsLength=${#rotations[@]}

  for ((i=0; i<$((zineImageCount)); i++)); do
    rotation=${rotations[$((i % rotationsLength))]}
    zineImage=${zineImageFileNames[$((i))]}
    convert $zineImage -rotate $rotation $zineImage
  done




  # ~~~~~~~~~~ CALCULATE IMAGE POSITION COORDINATES ~~~~~~~~~~~~~~~~~~~~

  # this determines the desired individual image size 
  # this will allow us so simply place it on the page files by coordinate
  # these could be calculated dynamically but can be determined manually
  # its easier to do with a physical mockup
  # percentages were determined by measuring in 1/8th inch units
  # could also have been done with millimeters
  # image sizes are percentages of total page height / width accounting for 1/8th inch border gaps
  # the border gaps are to match the 1/8th inch unprited white boarder on most home printers

  xImagePercent=4706 # represents 97.06% <-- set this manually for different zine layouts
  yImagePercent=4773 # represents 47.73% <-- set this manually for different zine layouts

  # calculate percentages into pixels
  xImageSizePixels=$(((xImagePercent * xPageSizePixels) / 10000)) # <-- division simulates percentage
  yImageSizePixels=$(((yImagePercent * yPageSizePixels) / 10000))
  # note that bash only uses integers so perform calculation manually before running script

  # this resizes all images in place
  # this has to happen after rotation right now but should be changed for efficiency later
  for ((i=0; i<$((zineImageCount)); i++)); do
    zineImage=${zineImageFileNames[$((i))]}
    convert $zineImage -resize $((xImageSizePixels))x$((yImageSizePixels))^ -gravity center -extent $((xImageSizePixels))x$((yImageSizePixels)) $zineImage
  done




  # ~~~~~~~~~~ CALCULATE IMAGE ORDER FOR PAGES ~~~~~~~~~~~~~~~~~~~~

  # this renames the pages based on the order they should be added to the pages
  # this gets more complicated the smaller the zine gets
  # its best figured out with a physical mockup of the zine size
  # this array can give us the correct relative orders for any image count with some modulus arithmatic
  # the first image for a page will get reordered to the number at index 0 in the array
  # the second will be assigned the relative order number at index 1 and so on
  # the pattern repeats for every print sheet meaning front and back

  relativePageOrders=(2 5 7 4 3 8 6 1) # <--- set these manually for different zine layouts
  relativePageOrdersLength=${#relativePageOrders[@]}

  # create a max image number
  # this is needed to create relative orders that will be in the right order
  # avoids 10-ordered.png coming before 2-ordered.png etc...
  maxImages=10000 # <--- can be changed for high page count

  # rename all zine image files for correct order
  for ((i=0; i<$((zineImageCount)); i++)); do
    zineImage=${zineImageFileNames[$((i))]}
    relativeOrder=$((relativePageOrders[$((i % relativePageOrdersLength))]))
    pageNumber=$((((i) / sheetMax))) # <-- first page is zero since divide will always round down
    absoluteOrder=$(((pageNumber * sheetMax) + relativeOrder + maxImages))

    # use some horrible bash syntax to separate the filetype for renaming
    extension="${zineImage##*.}"
    # newFileName=./zine-images/$((absoluteOrder))-ordered.$extension
    mv $zineImage ./zine-images/$((absoluteOrder))-ordered.$extension
  done




  # ~~~~~~~~~~ CALCULATE IMAGE POSITION COORDINATES ~~~~~~~~~~~~~~~~~~~~

  # coordinates are split into two arrays so they can be easily looked up in later iteration
  # there are only two coordinates because this is a half page zine with two images per page
  # more coordinates can be added here for smaller zines
  # they start as percentages and are translated to pixels based on page size

  xCoordinatesPercentages=(147 5147 147 5147) # <-- these two arrays need to be set manually based on zine layout
  yCoordinatesPercentages=(114 114 5114 5114) # representing 1.47% 51.47% etc

  xCoordinatesPercentagesLength=${#xCoordinatesPercentages[@]}
  yCoordinatesPercentagesLength=${#yCoordinatesPercentages[@]}

  xCoordinatesPixels=()
  yCoordinatesPixels=()

  # calculate these percentages into pixels and add to coordinate arrays
  # again bash cant do floating point numbers so percentages are calculated with integers
  for ((i=0; i<$((xCoordinatesPercentagesLength)); i++)); do
    pixelValue=$(((xCoordinatesPercentages[$i] * xPageSizePixels) / 10000))
    xCoordinatesPixels+=($pixelValue)
  done

  for ((i=0; i<$((yCoordinatesPercentagesLength)); i++)); do
    pixelValue=$(((yCoordinatesPercentages[$i] * yPageSizePixels) / 10000))
    yCoordinatesPixels+=($pixelValue)
  done




  # ~~~~~~~~~~ ADD IMAGES TO PAGES ~~~~~~~~~~~~~~~~~~~~

  # recollect new image names
  zineImageFileNames=(./zine-images/*)
  # orderedImageNumber=$((maxImages + 1))
  imagesAdded=0
  i=0

  # place all zine images on pages in new order alternating positions
  # for ((i=0; i<$((zineImageCount)); i++)); do
  while [ $imagesAdded -lt $zineImageCount ]; do
    # zineImage=${zineImageFileNames[$((i))]}
    zineImage=./zine-images/$((maxImages + i + 1))-ordered.jpg
    if test -f "$zineImage"; then
      xPosition=$((xCoordinatesPixels[$((i % xCoordinatesPercentagesLength))]))
      yPosition=$((yCoordinatesPixels[$((i % yCoordinatesPercentagesLength))]))
      pageNumber=$((((i) / pageMax) + 1)) # first page is zero since divide will always round down

      magick composite -geometry +$((xPosition))+$((yPosition)) $zineImage ./zine-pages/$((pageNumber))-page.png ./zine-pages/$((pageNumber))-page.png
      imagesAdded=$((imagesAdded + 1))
    fi
    i=$((i + 1))

    echo $zineImage
    echo $i
    echo $imagesAdded
    echo "~~~~~~~~~"
  done




  # ~~~~~~~~~~ STYLE PAGES ~~~~~~~~~~~~~~~~~~~~

  # collect page file names and length then iterate through
  pageFileNames=(./zine-pages/*)
  pageFileCount=${#pageFileNames[@]}

  for ((i=0; i<$((pageFileCount)); i++)); do
    # grab page name and apply imagemagick styling
    pageFileName=${pageFileNames[$((i))]}
    convert $pageFileName -colorspace gray -ordered-dither o2x2 $pageFileName
  done




  # ~~~~~~~~~~ INCREASE PAGE RESOLUTION FOR PRINT ~~~~~~~~~~~~~~~~~~~~

  # this is to help retain the pixel sharpness on lower resolution dithers etc
  # the conversion to a jpeg is to help speed up printing

  for ((i=0; i<$((pageFileCount)); i++)); do
    pageFileName=${pageFileNames[$((i))]}

    convert $pageFileName -filter point -resize 1700x2200 $pageFileName
    magick $pageFileName ./zine-pages/$((i))-page.jpg
    rm $pageFileName
  done



  # ~~~~~~~~~~ COMBINE INTO SINGLE PDF ~~~~~~~~~~~~~~~~~~~~
  currentTime=`date -u +%s`
  magick convert ./zine-pages/* zine-${currentTime}.pdf

  open zine-${currentTime}.pdf
```


---

[[back to top]](#zine-magick-scripts)













# Make an Eighth-Page Vertical Zine

This script builds a zine size that I personally like but have never actually seen before in the wild, an 8.5 x 11 inch sheet of standard printer paper folded in eighths forming a vertically oriented 2.125 inch wide 2.25 inch tall booklet. Once again, as stated in 
[the start of this readme](#zine-magick-scripts) this script assumes a side-staple or japanese sewn binding rather than saddle binding with pages clam-shelled together which would still be completely different in terms of page ordering.

To use the script make a folder called "zine-images-originals" and fill it with the images you want to turn into zine pages. Then paste the following into a bash script file, comment in / out the desired settings for size, style etc. and then run the script. Make sure to have [imagemagick](#zine-magick-scripts) properly installed!

* vertical / portrait orientation
* 2.125 x 2.75 inch zine
* 8.5 x 11 inch print paper
* home or office printer friendly
* 64 pages max (32 sheets)


```
⚠️ Warning: This one may still have some bugs!
```

```bash
# ~~~~~~~~~~ GENERAL SETUP ~~~~~~~~~~~~~~~~~~~~

# i=0
# for file in ./zine-images-originals/*
# do
#   mv "$file" ./zine-images-originals/${i}.jpg
#   i=$(($i + 1))
# done


# first we delete and recreate our zine images directory
# we copy all of our original input images into this directory to manipulate
rm -rf zine-images
cp -r zine-images-originals zine-images

# also delete the zine pages folder if it exists and remake it empty
rm -rf zine-pages
mkdir zine-pages

# then we capture all the filenames in an array
# we grab the length for reference also since thats a pain in bash
zineImageFileNames=(./zine-images/*)
zineImageCount=${#zineImageFileNames[@]}

# now we set the max number of images per page
# we also set the maximum number of image that can be on a sheet which could be calculated too
pageMax=16
sheetMax=32

# now we calculate the number of pages we'll need
# this may need to be adjusted for larger zine counts and should be tested
# it divides the total number of images for the zine by how many can fit on the page rounding down
# then it adds another tow pages (one double-sided print sheet) if there were any leftover pages
# its good this is here but it really shouldnt be used
# zine page counts should be adjusted to fit evenly onto desired print layout without blank end pages
pagesNeeded=$(((zineImageCount / pageMax)+((zineImageCount % pageMax > 0 ) * 2) + 1)) # <-- temporary +1 needs to be coded dynamically

# below are the pixel dimensions for page files which represent resolution
# these will determine how pixellated or compressed any styling done later on is
# comment them in and out freely to experiment

# xPageSizePixels=3400
# yPageSizePixels=4400

# xPageSizePixels=1700
# yPageSizePixels=2200

xPageSizePixels=850
yPageSizePixels=1100

# xPageSizePixels=425
# yPageSizePixels=550

# xPageSizePixels=217
# yPageSizePixels=275




# ~~~~~~~~~~ CREATE BLANK PAGES ~~~~~~~~~~~~~~~~~~~~

# this approach makes blank pages first to overlay the images onto later
# making the blank page files doesn't need to happen first but might as well
# first it makes a single starter blank page to copy which speed things up
convert -size ${xPageSizePixels}x${yPageSizePixels} xc:lime zine-pages/1-page.png

# then it makes all blank pages in new directory
# this is just faster than making each page with convert
for ((i=1; i<${pagesNeeded}; i++)); do
  cp zine-pages/1-page.png zine-pages/$(($i+1))-page.png
done




# ~~~~~~~~~~ ROTATE IMAGE FILES ~~~~~~~~~~~~~~~~~~~~

# this uses a rotation pattern array with numbers representing clockwise degrees
# it can be referenced dynamically for any page number with some modulus arithmatic
# the pattern here is tricky since it needs to be applied before reordering the images for page placement
# this is best calculated manually with a physical mock-up of the zine size

rotations=(180 180 0 0 0 0 180 180 0 0 180 180 180 180 0 0 0 0 180 180 180 180 0 0 180 180 180 0 0 0 180 180) # <--- set these manually for different zine layouts
# rotations=(90 90 270 270 270 270 90 90) # <--- set these manually for different zine layouts
rotationsLength=${#rotations[@]}

for ((i=0; i<$((zineImageCount)); i++)); do
  rotation=${rotations[$((i % rotationsLength))]}
  zineImage=${zineImageFileNames[$((i))]}
  convert $zineImage -rotate $rotation $zineImage
done




# ~~~~~~~~~~ CALCULATE IMAGE POSITION COORDINATES ~~~~~~~~~~~~~~~~~~~~

# this determines the desired individual image size 
# this will allow us so simply place it on the page files by coordinate
# these could be calculated dynamically but can be determined manually
# its easier to do with a physical mockup
# percentages were determined by measuring in 1/8th inch units
# could also have been done with millimeters
# image sizes are percentages of total page height / width accounting for 1/8th inch border gaps
# the border gaps are to match the 1/8th inch unprited white boarder on most home printers

xImagePercent=2285 # represents 22.85% <-- set this manually for different zine layouts
yImagePercent=2335 # represents 23.35% <-- set this manually for different zine layouts

# calculate percentages into pixels
xImageSizePixels=$(((xImagePercent * xPageSizePixels) / 10000)) # <-- division simulates percentage
yImageSizePixels=$(((yImagePercent * yPageSizePixels) / 10000))
# note that bash only uses integers so perform calculation manually before running script

# this resizes all images in place
# this has to happen after rotation right now but should be changed for efficiency later
for ((i=0; i<$((zineImageCount)); i++)); do
  zineImage=${zineImageFileNames[$((i))]}
  convert $zineImage -resize $((xImageSizePixels))x$((yImageSizePixels))^ -gravity center -extent $((xImageSizePixels))x$((yImageSizePixels)) $zineImage
done




# ~~~~~~~~~~ CALCULATE IMAGE ORDER FOR PAGES ~~~~~~~~~~~~~~~~~~~~

# this renames the pages based on the order they should be added to the pages
# this gets more complicated the smaller the zine gets
# its best figured out with a physical mockup of the zine size
# this array can give us the correct relative orders for any image count with some modulus arithmatic
# the first image for a page will get reordered to the number at index 0 in the array
# the second will be assigned the relative order number at index 1 and so on
# the pattern repeats for every print sheet meaning front and back

relativePageOrders=(15 30 18 3 2 19 31 14 10 27 23 6 7 22 26 11 12 25 21 8 5 24 28 9 13 32 20 1 4 17 29 16) # <--- set these manually for different zine layouts
relativePageOrdersLength=${#relativePageOrders[@]}

# create a max image number
# this is needed to create relative orders that will be in the right order
# avoids 10-ordered.png coming before 2-ordered.png etc...
maxImages=10000 # <--- can be changed for high page count

# rename all zine image files for correct order
for ((i=0; i<$((zineImageCount)); i++)); do
  zineImage=${zineImageFileNames[$((i))]}
  relativeOrder=$((relativePageOrders[$((i % relativePageOrdersLength))]))
  pageNumber=$((((i) / sheetMax))) # <-- first page is zero since divide will always round down
  absoluteOrder=$(((pageNumber * sheetMax) + relativeOrder + maxImages))
  
  # use some horrible bash syntax to separate the filetype for renaming
  extension="${zineImage##*.}"
  # newFileName=./zine-images/$((absoluteOrder))-ordered.$extension
  mv $zineImage ./zine-images/$((absoluteOrder))-ordered.$extension
done




# ~~~~~~~~~~ CALCULATE IMAGE POSITION COORDINATES ~~~~~~~~~~~~~~~~~~~~

# coordinates are split into two arrays so they can be easily looked up in later iteration
# there are only two coordinates because this is a half page zine with two images per page
# more coordinates can be added here for smaller zines
# they start as percentages and are translated to pixels based on page size

xCoordinatesPercentages=(0 2571 5143 7715) # <-- these two arrays need to be set manually based on zine layout
yCoordinatesPercentages=(0 0 0 0 2555 2555 2555 2555 5110 5110 5110 5110 7665 7665 7665 7665) # representing 1.47% 51.47% etc

xCoordinatesPercentagesLength=${#xCoordinatesPercentages[@]}
yCoordinatesPercentagesLength=${#yCoordinatesPercentages[@]}

xCoordinatesPixels=()
yCoordinatesPixels=()

# calculate these percentages into pixels and add to coordinate arrays
# again bash cant do floating point numbers so percentages are calculated with integers
for ((i=0; i<$((xCoordinatesPercentagesLength)); i++)); do
  pixelValue=$(((xCoordinatesPercentages[$i] * xPageSizePixels) / 10000))
  xCoordinatesPixels+=($pixelValue)
done

for ((i=0; i<$((yCoordinatesPercentagesLength)); i++)); do
  pixelValue=$(((yCoordinatesPercentages[$i] * yPageSizePixels) / 10000))
  yCoordinatesPixels+=($pixelValue)
done




# ~~~~~~~~~~ ADD IMAGES TO PAGES ~~~~~~~~~~~~~~~~~~~~

# recollect new image names
zineImageFileNames=(./zine-images/*)
# orderedImageNumber=$((maxImages + 1))
imagesAdded=0
i=0

# place all zine images on pages in new order alternating positions
# for ((i=0; i<$((zineImageCount)); i++)); do
while [ $imagesAdded -lt $zineImageCount ]; do
  # zineImage=${zineImageFileNames[$((i))]}
  zineImage=./zine-images/$((maxImages + i + 1))-ordered.jpg
  if test -f "$zineImage"; then
    xPosition=$((xCoordinatesPixels[$((i % xCoordinatesPercentagesLength))]))
    yPosition=$((yCoordinatesPixels[$((i % yCoordinatesPercentagesLength))]))
    pageNumber=$((((i) / pageMax) + 1)) # first page is zero since divide will always round down

    magick composite -geometry +$((xPosition))+$((yPosition)) $zineImage ./zine-pages/$((pageNumber))-page.png ./zine-pages/$((pageNumber))-page.png
    imagesAdded=$((imagesAdded + 1))
  fi
  i=$((i + 1))
done




# ~~~~~~~~~~ STYLE PAGES ~~~~~~~~~~~~~~~~~~~~

# collect page file names and length then iterate through
pageFileNames=(./zine-pages/*)
pageFileCount=${#pageFileNames[@]}

for ((i=0; i<$((pageFileCount)); i++)); do
  # grab page name and apply imagemagick styling
  pageFileName=${pageFileNames[$((i))]}
  # magick $pageFileName -color-threshold 'sRGB(163,112,0)-sRGB(203,152,40)' $pageFileName
  # magick $pageFileName -color-threshold 'sRGB(0,0,0)-sRGB(150,150,150)' $pageFileName
  # convert $pageFileName -colorspace gray -edge 1 -fuzz 1% -trim +repage $pageFileName
  # magick $pageFileName -colorspace gray -color-threshold 'gray(46.4152%)-gray(55.3278%)' $pageFileName
  # convert $pageFileName -negate $pageFileName
  convert $pageFileName -ordered-dither o2x2 $pageFileName # <--- color dither
  # convert $pageFileName -colorspace gray -ordered-dither o2x2 $pageFileName # <--- black and white dither
  # convert $pageFileName -colorspace RGB -fuzz 15% -fill red -opaque black $pageFileName
  # convert $pageFileName -colorspace RGB -fuzz 15% -fill blue -opaque black $pageFileName
  # convert $pageFileName -separate -threshold 50% -combine $pageFileName # <--- color posterize
  convert $pageFileName -colorspace RGB -fuzz 1% -fill white -opaque lime $pageFileName
done




# ~~~~~~~~~~ INCREASE PAGE RESOLUTION FOR PRINT ~~~~~~~~~~~~~~~~~~~~

# this is to help retain the pixel sharpness on lower resolution dithers etc
# the conversion to a jpeg is to help speed up printing

for ((i=0; i<$((pageFileCount)); i++)); do
  pageFileName=${pageFileNames[$((i))]}

  convert $pageFileName -filter point -resize 1700x2200 $pageFileName
  magick $pageFileName ./zine-pages/$((i))-page.jpg
  rm $pageFileName
done



# ~~~~~~~~~~ COMBINE INTO SINGLE PDF ~~~~~~~~~~~~~~~~~~~~
currentTime=`date -u +%s`
magick convert ./zine-pages/* zine-${currentTime}.pdf

open zine-${currentTime}.pdf

```





















<!-- ## Print Location Dictionary

```json
  {
    "instructions": "Take every input page number and modulo by 4. Take the remainder and run through the lookup table. Then add the value from the lookup table to the original input page number devided by 4 and floored, indicating the print page number. That should produce the correct new order number to be placed on the print page files."
    "half-page-zine": {
      "print-sheet-capacity-both-sides": 4,
        "page-ordering-offsets": {
         "1": {
          "offset": 4,
          "rotate": 270
        },
        "2": {
          "offset": 1,
          "rotate": 90
        },
        "3": {
          "offset": 2,
          "rotate": 90
        },
        "4": {
          "offset": 3,
          "rotate": 270
        },
        "position-offsets-percentages": {
          "portrait-orientation":
            "image-width": 97.06,
            "image-height": 47.73,
            "image-1-position": {
              "x": 1.47,
              "y": 1.14
            },
            "image-2-postiion": {
              "x": 1.47,
              "y": 51.14
            }
        }
      } 
    },
    "quarter-page-zine": {
      "print-sheet-capacity-both-sides": 8,
      "page-ordering-offsets": {
        "1": {
          "offset": 2,
          "rotate": 0
        },
        "2": {
          "offset": 5,
          "rotate": 0
        },
        "3": {
          "offset": 7,
          "rotate": 180
        },
        "4": {
          "offset": 4,
          "rotate": 180
        },
        "5": {
          "offset": 3,
          "rotate": 180
        },
        "6": {
          "offset": 8,
          "rotate": 180
        },
        "7": {
          "offset": 6,
          "rotate": 0
        },
        "8": {
          "offset": 1,
          "rotate": 0
        },
        "position-offsets-percentages": {
          "portrait-orientation":
            "image-width": 97.06,
            "image-height": 47.73,
            "image-1-position": {
              "x": 1.47,
              "y": 1.14
            },
            "image-2-postiion": {
              "x": 1.47,
              "y": 51.14
            }
        }
      }
    }
  }
``` -->

<!-- ## Coming Soon
* Creating Half-Page Zine
  - single page
  - from image set
* Creating Quarter-Page Zine
  - single page
  - from image set
* Creating Eighth-Page Zine
  - single page
  - from image set
* Creating Double-Size Zine
  - single page
  - from image set
* Creating Quadruple-Size Zine
  - single page
  - from image set
* Creating ~4-Foot Zine
  - single page
  - from image set
* Adding Text
  - position
  - size
  - background
  - borders
  - box shadows
  - test shadows
* Jumbling Images
  - randomly place image
  - place random image
  - randomly place set of images
  - randomly place random images so many times -->
