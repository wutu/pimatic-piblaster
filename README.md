pimatic-piblaster
================

Support for the <a href="https://github.com/sarfata/pi-blaster">pi-blaster daemon</a>.

Install the pi-blaster daemon (<a href="https://github.com/sarfata/pi-blaster">instructions</a>).

Usable pins:

      GPIO number   Pin in P1 header
          4              P1-7
          17             P1-11
          18             P1-12
          21             P1-13
          22             P1-15
          23             P1-16
          24             P1-18
          25             P1-22

### Example config

Add the plugin to the plugin section:

```json
{ 
  "plugin": "piblaster"
}
```

Then add a device to the devices section:

```json
{
  "id": "led-sw-pwm",
  "name": "LED SW PWM",
  "class": "PiblasterDimmer",
  "gpio": 18,
  "dimlevel": 0
}
```
