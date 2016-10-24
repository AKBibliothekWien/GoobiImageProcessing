#!/bin/bash


# This prevents error messages when looping over files with certain given extensions
# (see "for" loop below) when one or more of these listed extensions to not exist.
shopt -s nullglob

origpath=$1
tifpath=$2

# Create tif path if it does not already exist
mkdir -p $tifpath

# Remove all files in tif path if so that we can start with a clean folder
for file in "$tifpath/"* ; do
        rm $file;
done

# Copy images to folder with low resolution tifs
/usr/bin/rsync -a $origpath/ $tifpath/

# Convert copied images to tifs. If it is already a file with the file extension "tif", do NOT convert it.
# The reason is: we remove the original image after conversion. If the original AND the converted image have
# both the same filename and extension (tif), both would be deleted.
for file in "$tifpath/"*.{tiff,TIF,TIFF,jpg,jpeg,JPG,JPEG} ; do
        mogrify -format tif $file
        rm $file
done


# Rename files to Goobi standard
# Loop over files that are sorted by file name with "ls -v". Only use image files with tif extension.
for file in `ls -v "$tifpath/"*.tif` ; do
        # Create a counter for the filenames
        let counter++

        # Get the file extension
        #extension="${file##*.}"

        # Create the new filename
        newFilename=`printf "%08d\n" $counter`
        #newFilename=$newFilename.$extension

        # Rename the file
        mv $file "$tifpath/$newFilename.tif"
done

# Compress the images in the folder for the low resolution tifs
for file in "$tifpath/"*.tif ; do
        # WORX - with JPEG compression
    #convert -density 72 $file -units PixelsPerInch -compress JPEG $file 

    # WORX - with Zip compression
    # IMPORTANT:    To use ZIP compression, compile libtiff with ZIP enabled from source and install it.
    #               After installing libtiff enabled ZIP, compile ImageMagick with this libtiff again.
    #               See Goobi-Wiki from AK Bibliothek Wien for instructions.
        filename=$(basename "$file")
        filename="${filename%.*}"
        #extension="${file##*.}"
        convert -density 72 -units PixelsPerInch $file -compress ZIP -resize 1920x1080\> "$tifpath/$filename.tif"
done

echo "Bilder wurden bearbeitet. Images were processed."