#!/usr/bin/env bash

export PATH=$PATH:/root/arduino/:/root/arduino/java/bin/

chmod +x /root/arduino/arduino

parse_yaml() {
    local prefix=$2
    local s
    local w
    local fs
    s='[[:space:]]*'
    w='[a-zA-Z0-9_]*'
    fs="$(echo @|tr @ '\034')"
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
    awk -F"$fs" '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, $3);
        }
    }' | sed 's/_=/+=/g'
}

set +e # skip errors

# Config options you may pass via Docker like so 'docker run -e "<option>=<value>"':
# - KEY=<value>

if [ -z "$WORKDIR" ]; then
  cd $WORKDIR
else
  echo "No custom working directory given, using current..."
  WORKDIR=$(PWD)
fi

#cd /opt/workspace


# Build


# Parse thinx.yml config
#BOARD="esp32"
#SOURCE=.
#F_CPU=80
#FLASH_SIZE="4M"

#YMLFILE=$(find /opt/workspace -name "thinx.yml" | head -n 1)

#if [[ ! -f $YMLFILE ]]; then
#  echo "No thinx.yml found"
#  exit 1
#else
#  echo "Reading thinx.yml:"
#  cat "$YMLFILE"
#  echo
#  eval $(parse_yaml "$YMLFILE" "")
#  BOARD=${arduino_platform}:${arduino_arch}:${arduino_board}

#  if [ ! -z "${arduino_flash_size}" ]; then
#    FLASH_SIZE="${arduino_flash_size}"
#  fi

#  if [ ! -z "${arduino_f_cpu}" ]; then
#    F_CPU="${arduino_f_cpu}"
#  fi

#  if [ ! -z "${arduino_source}" ]; then
#    SOURCE="${arduino_source}"
#  fi

#  echo "- board: ${BOARD}"
#  echo "- libs: ${arduino_libs}"
#  echo "- flash_ld: ${arduino_flash_ld}"
#  echo "- f_cpu: $F_CPU"
#  echo "- flash_size: $FLASH_SIZE"
#  echo "- source: $SOURCE"
#fi

# TODO: if platform = esp8266 (dunno why but this lib collides with ESP8266Wifi)
rm -rf /root/arduino/libraries/WiFi

BUILD_DIR="/tmp/build"
if [[ -d "$BUILD_DIR" ]]; then
  echo "Deleting: "
  ls $BUILD_DIR
  rm -vrf $BUILD_DIR
fi
mkdir $BUILD_DIR

RESULT=1

if [ -z "$DISPLAY" ]; then
  echo "Simulating screen in headless mode, use socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" "
  Xvfb :99 &
  export DISPLAY=:99
  #Xvfb :1 -ac -screen 0 1280x800x24 &
  #xvfb="$!"
#  socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"
#  export DISPLAY=:0.0
fi

cd $SOURCE

# Install own libraries (overwriting managed libraries)


if [ -d "/root/workspace/lib" ]; then
    echo "Copying user libraries (1)..."
    cp -fR /root/workspace/lib/** /root/arduino/libraries
fi




#if [ -d "../lib" ]; then
#    echo "Copying user libraries (2)..."
#    cp -fR ../lib/** /root/arduino/libraries
#fi

## Use default library if none set in thinx.yml
#if [ -z "${arduino_libs}" ]; then
#    arduino_libs="THiNX"
#fi

# Install managed libraries from thinx.yml
for lib in ${arduino_libs}; do
  echo "Installing library $lib..."
	/root/arduino/arduino --install-library $lib
done


# Locate nearest .ino file and enter its folder of not here
INO=$(find /root/workspace/src -maxdepth 1 -name '*.ino')
if [ ! -f $INO ]; then
   echo "Finding sketch folder in " $(pwd)
   FOLDER=$(find . -maxdepth 4 -name '*.ino' -printf '%h' -quit | head -n 1)
   echo "Folder: " $FOLDER
   FILE=$(find $FOLDER -maxdepth 4 -name '*.ino' -quit | head -n 1)
   echo "Finding sketch file:"
   echo "File: " $FILE
   INO=$FOLDER/$FILE
   echo "INO:" $INO
   #pushd $FOLDER
fi

echo "***********"
echo $INO
echo "***********"

mkdir /tmp/build

/root/arduino/arduino --verify --verbose --verbose-build --pref build.path=/tmp/build --pref board=esp32 $INO

ls -l /tmp/build










