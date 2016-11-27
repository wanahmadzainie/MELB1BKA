CC	= gcc
CFLAGS  += -I/usr/include/opencv -DJPEG_QUALITY=30 -DMSG_LENGTH=300*1024
LDFLAGS	+= -lopencv_core -lopencv_highgui -lopencv_imgproc -ljpeg -lpthread


all: clean hw1 hw2_server hw2_client

hw1:
	$(CC) $(CFLAGS) -o hw1 hw1.c $(LDFLAGS)

hw2_server:
	$(CC) $(CFLAGS) -o hw2_server hw2_server.c $(LDFLAGS)

hw2_client:
	$(CC) $(CFLAGS) -o hw2_client hw2_client.c $(LDFLAGS)

clean:
	$(RM) -rf *.jpg *.o hw1 hw2_server hw2_client
