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
    BYTE=33
    BEGINNING=$(echo $(xxd -s 19 -l 14 "Songs/$FOLDER/$FILE") | sed -re 's,\s+, ,g' | cut -d $' ' -f 9-)
    AUDIOBEGINNING="AudioFilename:"
    REALCHAR=""
    READCHAR=""

    while [[ !($BEGINNING == $AUDIOBEGINNING) ]]
    do
      XXDOUT=$(xxd -s $BYTE -l 1 "Songs/$FOLDER/$FILE")
      REALCHAR=$(echo $XXDOUT | awk '{print $2}')
      READCHAR=$(echo $XXDOUT | awk '{print $3}')
      if [[ $REALCHAR == "20" ]]
      then
        BEGINNING="$BEGINNING "
      else
        BEGINNING="$BEGINNING$READCHAR"
      fi
      BEGINNING=$(echo $BEGINNING | sed -n 's/.//p')
      ((BYTE++))
    done
    
    REALCHAR=""
    READCHAR=""
    SONGFILE=""
    while [[ !($REALCHAR == "0d") && !($REALCHAR == "0a") ]]
    do
      XXDOUT=$(xxd -s $BYTE -l 1 "Songs/$FOLDER/$FILE")
      if [[ $REALCHAR == "20" ]]
      then
        SONGFILE="$SONGFILE "
      else
        SONGFILE="$SONGFILE$READCHAR"
      fi
      REALCHAR=$(echo $XXDOUT | awk '{print $2}')
      READCHAR=$(echo $XXDOUT | awk '{print $3}')
      ((BYTE++))
    done

    SONGFILE=$(echo $SONGFILE | sed -n -e 's/[ ]*//p')

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

