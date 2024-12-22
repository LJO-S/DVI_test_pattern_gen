# DVI Test Pattern Generator

This design creates a DVI driver (HDMI without audio) with 4 different selectable test patterns.
The design is implemented on the Zybo Z7-10, using only PL and the onboard 125MHz oscillator.

VHDL files are found in /src/
vunit files are found in /test/
Constraint files are found in /constr/

```bash
--DVI_TPG
 |
 |--src/
 |--test/
 |--cnstr/
```

The implementation uses 8b/10b encoding, illustrated in the figure below and each step is extensively commented on in /src/TMDS_encoder.vhd. Here's a short breakdown of the encoding:

1. The input data consists of 8-bit RGB data.
2. The encoder checks how many 1s and 0s are in said data and thus determines whether to use XOR or XNOR to encode said data. It adds a bit onto the data vector which signals to the receiver if XOR or XNOR was used.
3. The next steps involve a bunch of smaller steps to counter any DC bias in the transmission. It checks if the number of 0s in the encoded data match the number of 1s, and if not, by how much is it differing? More 1s than 0s? More 0s than 1s? How many 1s did we have last transmission? And so on... In this step it adds another bit to the data vector called the parity bit, signalling to the receiver if we have flipped data to counter DC bias.
** In case video is not enabled, instead of sending encoded 0s out to the receiver the transmitter will send control signals. Said control signals are illustrated in the figure below.
  

After those steps we now have 10 bits instead of the 8 bits we started with, hence the name 8b/10b. NOTE: This encoding protocol is different from IBM's 8b/10b. This design uses a 25 MHz clock to achieve 60 Hz refresh rate with a 640x480p image, but the entire 10-bit data vector needs to be sent to the HDMI/DVI receiver during one 25 MHz clock tick. Therefore, we use a 250 MHz clock to left-shift the entire 10-bit data vector out during one clock tick of the slower 25 MHz clock.

To obtain differential signals (LVDS33) the design uses OBUFDS primitives which Xilinx Vivado correctly infers. I believe Altera's Quartus software automatically infers an optional diff I/O signal when pin-mapping, but I'm not sure.

The design uses both a ROM, inferred as BRAM, and a single-port memory, inferred as DRAM. 

![alt text](https://github.com/LJO-S/HDMI_TPG/blob/main/diagram.png)


Four (4) test-patterns are generated and can be switched between using the 4 push-buttons on the Zybo Z710 dev board. The following test-patterns can be displayed:
1. Random noise created with a 32-bit Galois LFSR.
![alt text](https://github.com/LJO-S/DVI_test_pattern_gen/blob/main/images/IMG_5132.jpg)


2. A smiley face stored in block RAM.
![alt text](https://github.com/LJO-S/DVI_test_pattern_gen/blob/main/images/IMG_5135.jpg)

3. The Swedish flag
![alt text](https://github.com/LJO-S/DVI_test_pattern_gen/blob/main/images/IMG_5136.jpg)

4. Text stored in distributed RAM.
![alt text](https://github.com/LJO-S/DVI_test_pattern_gen/blob/main/images/IMG_5134.jpg)



