#!/bin/bash

show_help(){
        echo "Usage example:

# sample uses
./wallpaper.sh -p 20 -b '#264e70' -t '#f9b4ab' -o weather.jpg --weather
./wallpaper.sh --input art/tiger.txt -o default.jpg --background=#FFC1C1 --pointsize 35 --textcolor white

# for random background color and text color
./wallpaper.sh --random

# for weather wallpaper
./wallpaper.sh --weather"
}

mkdir -p art/

#default values
SIZE="1920x1080"
POINTSIZE="48"
BACKGROUND="lightblue"
TEXTCOLOR="black"
INPUT="art/defaultArt.txt"
OUTPUT="default.jpg"
FONT='./SpaceMono-Regular.ttf'

#get options
options=$(getopt -l "help,size:,font:,pointsize:,background:,input:,output:,textcolor:,random,weather" -o "hs:f:p:b:i:o:t:r" -a -- "$@")
eval set -- "$options"

while true; do
    case $1 in
        -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
            show_help
            exit
            ;;
        -f|--font)       # Takes an option argument, ensuring it has been specified.
            FONT=$2
            shift
            ;;
        -o|--output)
            OUTPUT=$2
            shift
            ;;
        -i|--input)
            INPUT=$2
            shift
            ;;
        -p|--pointsize)
            POINTSIZE=$2
            shift
            ;;
        -b|--background)
            BACKGROUND=$2
            shift
            ;;
        -s|--size)
            SIZE=$2
            shift
            ;;
        -r|--random)
            BACKGROUND="#$(openssl rand -hex 3)"
            TEXTCOLOR="#$(openssl rand -hex 3)"
            shift
            ;;
        -t|--textcolor)
            TEXTCOLOR=$2
            shift
            ;;
        --weather)
            curl "wttr.in/?0T" > art/weather.txt
            INPUT="art/weather.txt"
            shift
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: If no more options then break out of the loop.
            break
    esac

    shift
done

IMAGE="$(cat ${INPUT})"

# create blank image with color
convert -size ${SIZE} \
        xc:"${BACKGROUND}" \
        ${OUTPUT}

# put the ascii art blurred shadows on the image
# replace all single '\' with '\\'
convert ${OUTPUT} \
        \( -background none -fill ${TEXTCOLOR} -font ${FONT} -pointsize ${POINTSIZE} label:"${IMAGE//\\/\\\\}" -blur 0x5 \) \
        -gravity center \
        -compose over \
        -composite ${OUTPUT}

# unblurred text
convert ${OUTPUT} \
        \( -background none -fill ${TEXTCOLOR} -font ${FONT} -pointsize ${POINTSIZE} label:"${IMAGE//\\/\\\\}" \) \
        -gravity center \
        -compose over \
        -composite ${OUTPUT}


if [ -e art/weather.txt ]
then
    rm art/weather.txt
fi

