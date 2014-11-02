NAME   = lpc-2103Blinky-flash

CC      = arm-none-eabi-gcc
LD      = arm-none-eabi-ld -v
AR      = arm-none-eabi-ar
AS      = arm-none-eabi-as
CP      = arm-none-eabi-objcopy
OD	= arm-none-eabi-objdump
  
CFLAGS  = -I./ -c -Wall -fno-common -O0
AFLAGS  = -ahls -mapcs-32
LFLAGS  = -Map main.map -Tflash.ld
CPFLAGS = -O binary
ODFLAGS	= -x --syms

all: test

clean:
	@ echo ".cleaning"
	-rm -rf *.o *.lst main.out main.hex main.map main.dmp main.bin

test: main.out
	@ echo "...copying"
	$(CP) $(CPFLAGS) main.out main.bin
	$(OD) $(ODFLAGS) main.out > main.dmp
	$(OD) -S main.out > main.lst
	$(CP) -O ihex main.out main.hex

main.out: crt.o main.o flash.ld
	@ echo "..linking"
	$(LD) $(LFLAGS) -o main.out crt.o main.o

crt.o: crt.s
	@ echo ".assembling"
	$(AS) $(AFLAGS) -o crt.o crt.s > crt.lst

main.o: main.c
	@ echo ".compiling"
	$(CC) $(CFLAGS) main.c
