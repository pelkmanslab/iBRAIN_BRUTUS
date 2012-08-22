#! /bin/sh

TIFFDIR=$1

echo "running imagestatistics.sh on input file $TIFFDIR"

IFS=$'\n'

# loop over present png files and remove corresponding tiff files if present...
for TIFFFILE in $( find ${TIFFDIR} -name "*.png" ); do

echo $(identify -verbose ${TIFFFILE})
echo $(convert ${TIFFFILE}: -format "%[colorspace]\n%[fx:mean.r]\n%[fx:mean.g]\n%[fx:mean.b]\n%[fx:mean]" info:)

#channel_statistics=GetImageChannelStatistics(image,exception);
#red_mean=channel_statistics[RedChannel].mean;

done

unset IFS
echo "finished image statistics"

