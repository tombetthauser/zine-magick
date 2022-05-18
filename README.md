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

## Get Images in Directory 🔍

This is a bash script not image magick but it's useful for using image magick to do dynamic stuff to a batch of images. Basically it just stores all file names in an bash array and then iterates through them and lets you do whatever you want with each one.

```bash
  arr=(~/images-folder/*)

  # iterate through array using a counter
  for ((i=0; i<${#arr[@]}; i++)); do
      # insert image magick here
      echo "${arr[$i]}"
  done
```

## Make a Half-Page Portrait Zine 🦘

All sizes in pixels, all rotations in degrees.

```bash
  # temporary zine images reset
  rm -rf zine-images
  cp -r zine-images-originals zine-images

  zineImageFileNames=(./zine-images/*)
  zineImageCount=${#zineImageFileNames[@]}

  pageMax=2
  sheetMax=4

  # this is just a manual way 
  pagesNeeded=$(( ( zineImageCount / pageMax ) + ( zineImageCount % pageMax > 0 ) ))

  xPageSizeMedium=2550
  yPageSizeMedium=3300

  xPageSizeLarge=3400
  yPageSizeLarge=4400

  printPageCount=$((zineImageCount/2))

  # delete zine pages folder if it exists and remake it
  rm -rf zine-pages
  mkdir zine-pages

  # make starter blank page to copy
  convert -size ${xPageSizeLarge}x${yPageSizeLarge} xc:white zine-pages/1-page.png

  # make all blank pages in new directory named off order number by copying first one
  # this is just faster than making each page with convert
  for ((i=1; i<${pagesNeeded}; i++)); do
    cp zine-pages/1-page.png zine-pages/$(($i+1))-page.png
  done

  # rotate all images in place
  rotations=(270 90 90 270)
  rotationsLength=${#rotations[@]}

  for ((i=0; i<$((zineImageCount)); i++)); do
    rotation=${rotations[$((i % rotationsLength))]}
    zineImage=${zineImageFileNames[$((i))]}
    convert $zineImage -rotate $rotation $zineImage
  done

  # image sizes are percentages of total page height / width accounting for 1/8th inch border gaps
  xImagePercent=9706 # represents 97.06%
  yImagePercent=4773 # represents 47.73%

  # calculate percentages into pixels
  xImagePixels=$(((xImagePercent * xPageSizeLarge) / 10000))
  yImagePixels=$(((yImagePercent * yPageSizeLarge) / 10000))

  # note that bash only uses integers so perform calculation manually before running script
  # resize all images in place
  # this has to happen after rotation right now but this should be changed
  for ((i=0; i<$((zineImageCount)); i++)); do
    zineImage=${zineImageFileNames[$((i))]}
    convert $zineImage -resize $((xImagePixels))x$((yImagePixels))^ -gravity center -extent $((xImagePixels))x$((yImagePixels)) $zineImage
  done

  # TESTED AND WORKS UP THROUGH HERE ~~~~~~~~~~~~~~~~~~~~


  relativePageOrders=(4 1 2 3)
  relativePageOrdersLength=${#relativePageOrders[@]}

  # rename all zine image files for correct order ie -> 2-ordered.png
  for ((i=0; i<$((zineImageCount)); i++)); do
    zineImage=${zineImageFileNames[$((i))]}
    relativeOrder=${relativePageOrders[$((i % relativePageOrdersLength))]}
    pageNumber=$(((i / 4))) # first page is zero since divide will always round down
    absoluteOrder=$(((pageNumber * 4) + relativeOrder))
    mv $zineImage $((absoluteOrder))-ordered-$((zineImage))
  done
  
  xCoordinates=(1.47 1.47)
  yCoordinates=(1.14 51.14)
  # calculate these percentages into pixels
  # again bash can only use integers so calculate manually before running script
  
  # iterate through all new correctly ordered images
  # place on blank page files replacing page file each time
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
