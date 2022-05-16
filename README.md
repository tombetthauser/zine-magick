# ImageMagick Scripts for Art Hippies

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
