FROM ubuntu
MAINTAINER shaposhnikoff

RUN apt-get update && apt-get install -y -f software-properties-common \
  && add-apt-repository ppa:openjdk-r/ppa \
  && apt-get update \
  && apt-get install --allow-change-held-packages -y \
  wget \
  unzip \
  git \
  make \
  srecord \
  bc \
  xz-utils \
  gcc \
  curl \
  xvfb \
  mc \
  vim \
  python python-pip python-dev build-essential \
  libncurses-dev flex bison gperf python-serial \
  libxrender1 libxtst6 libxi6 openjdk-8-jdk


WORKDIR /tmp
RUN curl https://downloads.arduino.cc/arduino-1.8.9-linux64.tar.xz > ./arduino-1.8.9-linux64.tar.xz 
RUN unxz ./arduino-1.8.9-linux64.tar.xz
RUN tar -xvf arduino-1.8.9-linux64.tar
RUN rm -rf arduino-1.8.9-linux64.tar
RUN pwd && ls 
RUN mv /tmp/arduino-1.8.9 /root/arduino

#RUN mkdir -p ${ARDUINO_INSTALL_DIR}/hardware/espressif \
# && cd ${ARDUINO_INSTALL_DIR}/hardware/espressif \
# && git clone https://github.com/espressif/arduino-esp32.git esp32 \
# && cd esp32 \
# && git submodule update --init --recursive \
# && cd tools \
# && python get.py

#RUN cd ${ARDUINO_INSTALL_DIR}/hardware/espressif \
#  && git clone https://github.com/esp8266/Arduino.git esp8266 \
#  && cd esp8266 \
#  && git checkout tags/2.5.0 \
#  && cd ./tools \
#  && python get.py \
#  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add boards manager URL (warning, mismatch in boardsmanager vs. boards_manager in 2.6.0 coming up)
#RUN /opt/arduino/arduino --pref "boardsmanager.additional.urls=http://arduino.esp8266.com/stable/package_esp8266com_index.json" --save-prefs 


RUN /root/arduino/arduino --pref "board=esp32" --save-prefs
RUN /root/arduino/arduino --pref "boardsmanager.additional.urls=https://dl.espressif.com/dl/package_esp32_index.json" --save-prefs
RUN /root/arduino/arduino --install-boards esp32:esp32 --save-prefs


WORKDIR /root

COPY preferences.txt  /root/.arduino15/preferences.txt

COPY src/ /root/src/
COPY lib/ /root/lib/

COPY cmd.sh /root/
CMD /root/cmd.sh


#USER root
#ENTRYPOINT ["/bin/bash"]
