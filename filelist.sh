#! /bin/bash
#
# Automatic resource file list generation
# Created by Dimok

outFile="./src/resources/filelist.cpp"
count_old=$(cat $outFile 2>/dev/null | tr -d '\n\n' | sed 's/[^0-9]*\([0-9]*\).*/\1/')

count=0
if [[ $OSTYPE == darwin* ]];
then

for i in $(gfind ./data/images/ ./data/sounds/ ./data/fonts/ -maxdepth 1 -type f  \( ! -printf "%f\n" \) | sort -f)
do
	files[count]=$i
	count=$((count+1))
done

else

for i in $(find ./data/images/ ./data/sounds/ ./data/fonts/ -maxdepth 1 -type f  \( ! -printf "%f\n" \) | sort -f)
do
	files[count]=$i
	count=$((count+1))
done

fi

if [ "$count_old" != "$count" ] || [ ! -f $outFile ]
then

echo "Generating filelist.c for $count files." >&2
cat <<EOF > $outFile
/****************************************************************************
 * Resource files.
 * This file is generated automatically.
 * Includes $count files.
 *
 * NOTE:
 * Any manual modification of this file will be overwriten by the generation.
 *****************************************************************************/
#include <resources/filelist.h>

EOF

for i in ${files[@]}
do
	filename=${i%.*}
	extension=${i##*.}
	echo 'extern const u8 '$filename'_'$extension'[];' >> $outFile
	echo 'extern const u32 '$filename'_'$extension'_size;' >> $outFile
	echo '' >> $outFile
done

echo 'static ResourceFile ResourceList[] =' >> $outFile
echo '{' >> $outFile

for i in ${files[@]}
do
	filename=${i%.*}
	extension=${i##*.}
	echo -e '\t{"'$i'", '$filename'_'$extension', '$filename'_'$extension'_size, NULL, 0},' >> $outFile
done

echo -e '\t{NULL, NULL, 0, NULL, 0}' >> $outFile
echo '};' >> $outFile
echo '' >> $outFile
echo 'ResourceFile * getResourceList(){ return ResourceList; }' >> $outFile
echo '' >> $outFile
fi
