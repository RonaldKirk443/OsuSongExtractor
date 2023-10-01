#!/usr/bin/env bash

FOLDERS=$(ls "Songs")
OUTPUTFOLDER="Extracted Songs"
NEWLINE='\n'
IFS=$'\n'
COUNTER=1
START=$SECONDS

if [[ ! -d "Extracted Songs" ]]
then
  mkdir "Extracted Songs"
fi

for FOLDER in $FOLDERS
do
  FILES=$(ls "Songs/$FOLDER" | sed -n '/.osu$/p')
  COPIEDFILES=""
  for FILE in $FILES
  do
    LINECOUNT=1
    while read -r LINE
    do
      if [[ $LINECOUNT -eq 4 ]]
      then
        # echo $LINE | xxd
        SONGFILE=$(echo $LINE | sed -n -e 's/AudioFilename:[ ]*//p' | sed -e 's/\r//')
        # echo $SONGFILE | xxd
        break
      fi
      ((LINECOUNT++))
    done < "Songs/$FOLDER/$FILE"

    HASBEENCOPIED=0
    for LINE in $COPIEDFILES
    do
      if [[ $LINE == $SONGFILE ]]
      then
        HASBEENCOPIED=1
        break
      fi
    done

    if [[ HASBEENCOPIED -eq 0 ]]
    then
      if [[ $SONGFILE =~ audio.* ]]
      then
        EXTENTION=$(echo $SONGFILE | sed -n 's/audio//p')
        NAME=$(echo "$FOLDER$EXTENTION" | sed -n 's/[0-9]*[ ]*//p')
        cp "Songs/$FOLDER/$SONGFILE" "$OUTPUTFOLDER/$NAME"
      else
        NAME=$(echo $SONGFILE)
        cp "Songs/$FOLDER/$SONGFILE" "$OUTPUTFOLDER/$NAME"
      fi
      COPIEDFILES="$SONGFILE"$'\n'"$COPIEDFILES"
      echo "$COUNTER: $NAME copied"
      ((COUNTER++))
    fi
  done
done

DURATION=$(( SECONDS - start ))

echo "Done in $DURATION sec"
