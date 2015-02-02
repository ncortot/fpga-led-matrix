# fpga-led-matrix
HDMI decoder and LED matrix controller.


Hardware
========

  * [miniSpartan6+](http://www.scarabhardware.com/minispartan6/).
  * [32x32 LED matrix panels](https://www.sparkfun.com/products/12584).
  * RaspberryPi B+ for generating the HDMI signal.

Wiring:

| FPGA | LED matrix |
|---   |---         |
| A0   | R0         |
| A1   | R1         |
| A2   | G0         |
| A3   | G1         |
| A4   | B0         |
| A5   | B1         |
| A6   | A          |
| A7   | B          |
| A8   | C          |
| A9   | D          |
| A10  | N/C        |
| A11  | N/C        |
| B0   | CLK        |
| B1   | STB        |
| B2   | OE         |
| GND  | GND        |

HDMI input signal should be VGA (640x480) @ 60Hz.


References
==========

HDMI in/out code from [hamsterworks.co.nz](http://hamsterworks.co.nz/mediawiki/index.php/MiniSpartan6%2B_DVID_Logo).

LED matrix controller inspired by [Adafruit's version](https://github.com/adafruit/rgbmatrix-fpga).
