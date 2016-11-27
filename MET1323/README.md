MET1323
=======

Placeholder for MET1323

Tested on Ubuntu 14.04 LTS.
```
$ make
$ ./hw2_server &
$ ./hw2_client 127.0.0.1 8888 640 480
```
Press q to exit.   
   
The image on the left is uncompressed image from the webcam, and the image on   
the right is decompressed image stream.  
   
To change the compression ratio, edit the Makefile and change the value of   
JPEG_QUALITY in the range of 1 to 100. Default value is 25.   
   
The value of MSG_LENGTH is the size of frame to be sent over the socket.   
   
Deprecated   
----------   
Homework #1   
Tested on Ubuntu 12.04 LTS.
```
$ make
$ ./hw1
```
Press escape to exit.   
   
Requirements:-   
1. OpenCV 2.4   
2. libjpeg8
