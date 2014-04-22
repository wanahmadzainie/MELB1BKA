CC	= gcc
#CFLAGS	+= $(shell pkg-config --cflags opencv)
CFLAGS  += -I/usr/include/opencv
LDFLAGS	+= -lopencv_core -lopencv_highgui -lopencv_imgproc -ljpeg -lpthread
LIBS 	+= $(shell pkg-config --libs opencv) -ljpeg

all: clean hw1 hw2_server hw2_client

hw1:
	$(CC) $(CFLAGS) -o hw1 hw1.c $(LDFLAGS)

hw2_server:
	$(CC) $(CFLAGS) -o hw2_server hw2_server.c $(LDFLAGS)

hw2_client:
	$(CC) $(CFLAGS) -o hw2_client hw2_client.c $(LDFLAGS)
		
clean:
	$(RM) -rf *.jp *.o hw1 hw2_server hw2_client
