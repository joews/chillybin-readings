# chillybin-readings

Takes temperature readings from an Arduino and sends to a free cloud-hosted time series database at [tempo-db.com](https://tempo-db.com).

The Arduino part uses the [Dino](https://github.com/austinbv/dino) library. Use the Arduino IDE to upload `arduino/du/du.ino` to the board.

# Circuit

_Maybe I will do a schematic one day._

 * Arduino Uno
 * TMP-36 temperature sensor on pin A0
 * Optional LED with suitable resistor on pin 13


