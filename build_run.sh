sudo docker stop `sudo docker ps -a -q`
sudo docker build . -t xxx

exit 0
sudo chmod -R 777 lib src build


sudo docker run -it \
-v `pwd`/lib:/root/workspace/lib \
-v `pwd`/tmp:/tmp/build \
-v `pwd`/src:/root/workspace/src xxx







