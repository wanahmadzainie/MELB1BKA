MEL1123
=======

Placeholder for MEL1123

For the purpose of this subject, I use  
* Keil uVision for the IDE and simulator
* GNU Tools for ARM Embedded Processor for the toolchain
* lpc21isp for programming the board

All can be downloaded from their respective website,  
* http://www.keil.com/uvision/
* https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q2-update
* http://sourceforge.net/projects/lpc21isp/

To program the board, connect the RS232 cable, and make sure that the BSL and the JRST pins are shorted.
```
lpc21isp -control -verify <hex file> <COM port> 115200 147456
```

