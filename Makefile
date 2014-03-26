CC	= gcc
CFLAGS	+= $(shell pkg-config --cflags opencv)
LDFLAGS	+=
LIBS 	+= $(shell pkg-config --libs opencv) -ljpeg
SOURCES	=  hw1.c
OUTPUT	=  hw1

all: clean build

build: $(SOURCES)
	$(CC) $(SOURCES) $(CFLAGS) $(LDFLAGS) -o $(OUTPUT) $(LIBS)

clean:
	$(RM) -rf *.jpg *.o $(OUTPUT)
