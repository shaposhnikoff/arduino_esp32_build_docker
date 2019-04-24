#!/usr/bin/env bash

export PATH=$PATH:/root/arduino/:/root/arduino/java/bin/

chmod +x /root/arduino/arduino


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










