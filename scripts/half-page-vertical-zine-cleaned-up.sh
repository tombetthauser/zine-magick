# Welcome, this is a time-saving tool for making zines!

# It does the following...
#   - takes image files of varying resolutions, aspect ratios and filetypes
#   - outputs a single printable pdf optimized for home / office printers
#   - gets images in correct order for printing / folding which is mind-numbing
#   - automates image resizing, rotating and cropping which is also mind-numbing
#   - applies a variety of optional styles with imagemagick
#   - outputs pdfs ready to print, fold and staple!

# To try it out...
#   - make sure you have imagemagick installed (https://imagemagick.org)
#   - make a folder called "images" and drop your page images in it
#   - they can be any size, aspect ratio etc
#   - then run the script!



# ---------------------------------------------------------------------------

# show all activity in shell
set -x

# reset directories and copy zine images
rm -rf ./zine-images ./zine-pages ./output
cp -r ./images ./zine-images
mkdir ./zine-pages ./output

# capture zine file names and count
zineImageFileNames=(./zine-images/*)
imageCount=${#zineImageFileNames[@]}

# define final zine size by setting images per print sheet
pageMax=2; sheetMax=4

# calculate number of pages needed rounding up
pagesNeeded=$(((imageCount / sheetMax) * 2))
if [ $(($imageCount % $sheetMax)) -gt 1 ]; then pagesNeeded=$((pagesNeeded+2))
elif [ $(($imageCount % $sheetMax)) -gt 0 ]; then pagesNeeded=$((pagesNeeded+1))
fi

# set output page resolution in pixels
pageWidth=850; pageHeight=1100


# ---------------------------------------------------------------------------

# set styling option defaults
replaceColorWhite=false
blackReplacement=false
monochromeDither=false
colorDither=false
traceEdges=false
monochrome=false
posterize=false
dither=false
invert=false


# take optional styling arguments from command line 
for arg in "$@"
do
  if [ $arg -eq resolution:* ]; then xPixelsTemp=(${arg//:/ }); pageWidth=${xPixelsTemp[1]}; pageHeight=${xPixelsTemp[2]}; fi
  if [ $arg -eq white:* ]; then tempColor=(${arg//:/ }); replaceColorWhite=${tempColor[1]}; fi
  if [ $arg -eq black:* ]; then blackReplacement=${tempColor#black:}; fi
  if [ $arg -eq monochrome-dither:* ]; then monochromeDither=true; fi
  if [ $arg -eq color-dither:* ]; then colorDither=true; fi
  if [ $arg -eq trace-edges:* ]; then traceEdges=true; fi
  if [ $arg -eq monochrome:* ]; then monochrome=true; fi
  if [ $arg -eq posterize:* ]; then posterize=true; fi
  if [ $arg -eq invert:* ]; then invert=true; fi
done


# ---------------------------------------------------------------------------

# create blank page with color to prevent mono defaulting
convert -size ${pageWidth}x${pageHeight} xc:lime ./zine-pages/1-page.png

# create other pages with cp rather than imagemagick for speed
for ((i=1; i<$pagesNeeded; i++)); do
  cp ./zine-pages/1-page.png ./zine-pages/$(($i+1))-page.png
done


# ---------------------------------------------------------------------------

# static percent sizes for individual images on zine pages
xImagePercent=9706 # <-- represents 97.06%
yImagePercent=4773 # <-- represents 47.73%

# calculate percentages into pixels dimensions for images
imageHeight=$(((xImagePercent * pageWidth) / 10000)) # <-- division simulates percentage
imageWidth=$(((yImagePercent * pageHeight) / 10000))


# resize and then style all individual image files
for ((i=0; i<$((imageCount)); i++)); do

  # capture image filename and path
  zineImage=${zineImageFileNames[$((i))]}
  
  # resize image
  convert $zineImage -resize $((imageWidth))x$((imageHeight))^ -gravity center -extent $((imageWidth))x$((imageHeight)) $zineImage

  # apply all imagemagick styles
  if [ $monochrome = true ]; then convert $zineImage -colorspace Gray $zineImage; fi
  if [ $posterize = true ]; then convert $zineImage -separate -threshold 50% -combine $zineImage; fi
  if [ $traceEdges = true ]; then convert $zineImage -colorspace sRGB -edge 1 -fuzz 1% -trim +repage $zineImage; fi
  if [ $invert = true ]; then convert $zineImage -negate $zineImage; fi
  if [ $monochromeDither = true ]; then convert $zineImage -monochrome $zineImage; fi
  if [ $colorDither = true ]; then convert $zineImage -channel RGBA -separate +clone -dither FloydSteinberg -remap pattern:gray50 +swap +delete -combine $zineImage; fi
  if ! [ $replaceColorWhite = false ]; then convert $zineImage -colorspace sRGB -fuzz 33% -fill $replaceColorWhite -opaque white $zineImage; fi
  if ! [ $blackReplacement = false ]; then convert $zineImage -colorspace sRGB -fuzz 33% -fill $blackReplacement -opaque black $zineImage; fi
done


# ---------------------------------------------------------------------------

# static image rotation pattern for proper print orientations
rotations=(270 90 90 270) # <--- represent clockwise degrees

# grab length of rotations dynamically for longer patterns
rotationsLength=${#rotations[@]}

# rotate all images individually
for ((i=0; i<$((imageCount)); i++)); do
  rotation=${rotations[$((i % rotationsLength))]}
  zineImage=${zineImageFileNames[$((i))]}
  convert $zineImage -rotate $rotation $zineImage
done


# ---------------------------------------------------------------------------

# create placeholder images for irregular number of images
if [ $((imageCount % sheetMax)) -gt 0 ]
then
  # create temporary directory
  rm -rf ./zine-placeholders
  mkdir ./zine-placeholders

  # calculate the number of images needed for all pages
  imageCountRoundedUp=$((imageCount + (sheetMax - (imageCount % sheetMax))))

  # make 1px placeholder image with placeholder color
  convert -size 1x1 xc:lime ./zine-placeholders/1001-ordered.png

  # copy placeholder image and name for proper unix ordering
  for ((i=1; i<((imageCountRoundedUp)); i++)); do
    cp ./zine-placeholders/1001-ordered.png ./zine-placeholders/$((i + 1 + 1000))-ordered.png
  done
fi


# static pattern for relative image orders
relativePageOrders=(1 3 4 2) # <--- set these manually for different zine layouts
relativePageOrdersLength=${#relativePageOrders[@]}

# make a variable to track the max image placement location
# this will be used when the images are actually getting placed
# so we can place blank images when there are uneven image numbers
maxImagePlacementNumber=1


# rename all zine image files for correct order
for ((i=0; i<$((imageCount)); i++)); do
  zineImage=${zineImageFileNames[$((i))]}

  relativeOrder=${relativePageOrders[$((i % relativePageOrdersLength))]}
  
  pageNumber=$((i / 4)) # <-- first page is zero since divide will always round down
  absoluteOrder=$(((pageNumber * 4) + relativeOrder + 1000))

  # update maxImagePlacementNumber
  if [ $absoluteOrder -gt $maxImagePlacementNumber ]
  then
    maxImagePlacementNumber=$absoluteOrder
  fi
  
  # trim off the file extension
  extension=${zineImage##*.} # <-- clarify need for ## vs #
  rm ./zine-placeholders/$absoluteOrder* # <-- clarify need to remove these
  rm ./zine-images/$absoluteOrder*
  mv $zineImage ./zine-images/$absoluteOrder-ordered.$extension
done

mv ./zine-placeholders/* ./zine-images/
rm -rf ./zine-placeholders


# ---------------------------------------------------------------------------

# patterns for relatively placing images on pages with print margins
xPercentages=(147 147) # <-- representing 1.47% 1.47%
yPercentages=(114 5114) # <-- representing 1.14% 51.14%

xPercentagesLength=${#xPercentages[@]}
yPercentagesLength=${#yPercentages[@]}

# create empty arrays to add actual pixel coordinates to
xCoordinatesPixels=()
yCoordinatesPixels=()

# calculate these percentages into pixels and add to coordinate arrays
for ((i=0; i<$((xPercentagesLength)); i++)); do
  pixelValue=$(((xPercentages[i] * pageWidth) / 10000)) # <-- bash doesnt do floats
  xCoordinatesPixels+=($pixelValue) # <-- appending array element
done

for ((i=0; i<$((yPercentagesLength)); i++)); do
  pixelValue=$(((yPercentages[i] * pageHeight) / 10000))
  yCoordinatesPixels+=($pixelValue)
done


# ---------------------------------------------------------------------------

# recollect new image file names with new placeholders
zineImageFileNames=(./zine-images/*)
imageCount=${#zineImageFileNames[@]}

# place all zine images on correct pages in orders and positions
for ((i=0; i<$((imageCount)); i++)); do
  zineImage=${zineImageFileNames[$((i))]}
  xPosition=${xCoordinatesPixels[$((i % xPercentagesLength))]}
  yPosition=${yCoordinatesPixels[$((i % yPercentagesLength))]}
  pageNumber=$(((i / 2) + 1)) # <-- first page is zero since divide rounds down

  magick composite -geometry +$xPosition+$yPosition $zineImage ./zine-pages/$pageNumber-page.png ./zine-pages/$pageNumber-page.png
done


# ---------------------------------------------------------------------------

# combine all image files into pdf
magick convert ./zine-pages/* ./output/zine.pdf

# replace limegreen placeholder color
convert ./output/zine.pdf -colorspace sRGB -fuzz 1% -fill white -opaque lime ./output/zine.pdf

# clean up temp directories and files
rm -rf ./zine-placeholders
rm -rf ./zine-images
rm -rf ./zine-pages

# open the finished zine file
open ./output/*