#!/bin/bash
# let's make the script a little more robust
set -u			# exit if the script tries to use an unbound variable
set -e			# exit we a command fails 
set -o pipefail # exit if a command in a pipe fails

# check and read the parameters
##f [[ $1 -eq "--help" ]]; then 
##  	echo "usage: flac2mp3.sh <VBRQUALITY> <FLACFILE> <MP3FILE> [mtime]"
##  	echo ""
##  	echo "When using 'mtime' at the end the conversion will only take"
##  	echo "place, if the mp3 file does not exist yet or the flac file"
##  	echo "is newer, which indicates that the mp3 file is out of date."  
## exit 1
##

function encode {
for f in *.flac; do
  for tag in TITLE ARTIST ALBUM DATE COMMENT TRACKNUMBER TRACKTOTAL GENRE; do
    eval "$tag=\"`metaflac --show-tag=$tag "$f" | sed 's/.*=//'`\""; 
  done; 
  flac -cd "$f"|lame -b 320 --tt "$TITLE" --ta "$ARTIST" --tl "$ALBUM" --ty "$DATE" --tc "$COMMENT" --tn "$TRACKNUMBER/9" --tg "$GENRE" - "${f%.*}".mp3; 
done
}

DIR="${1}"

NEWDIR="${DIR/FLAC/MP3\ 320}"

mkdir -p "$NEWDIR"

cd "$DIR"

for dir in */; do
  if [ -d "${dir}" ]
  then
    cd "${dir%*/}";
    if [ `find . -ipath "*.flac" -exec ls -1 {} \; | wc -l` -gt 0 ]
    then
      pwd
      SUBDIR=../../"$NEWDIR"/"${dir%*/}"
      encode
      mkdir -p "$SUBDIR"
      mv *.mp3 "$SUBDIR"
      if [ `find . -iregex ".*\.jpe*g" -exec ls -1 {} \; | wc -l` -gt 0 ]
      then
        find . -iregex ".*\.jpe*g" -exec cp {} "$SUBDIR" \;
      fi
    fi
    cd ..
  else
    encode
    mv *.mp3 ../"$NEWDIR"/
  fi

  if [ `find . -iregex ".*\.jpe*g" -exec ls -1 {} \; | wc -l` -gt 0 ]
  then
    find . -iregex ".*\.jpe*g" -exec cp {} ../"$NEWDIR" \;
  fi
done

