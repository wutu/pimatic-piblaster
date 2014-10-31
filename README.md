pimatic-piblaster
================

Support for the <a href="https://github.com/sarfata/pi-blaster">pi-blaster daemon</a>.

Install the pi-blaster daemon (<a href="https://github.com/sarfata/pi-blaster#how-to-build-and-install">instructions</a>).

Usable pins:

      GPIO number   Pin in P1 header
          4              P1-7
          17             P1-11
          18             P1-12
          21             P1-13 (only for model A/B)
          27             P1-13 (only for model B+)
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

Thank you <a href="https://github.com/sarfata">sarfata</a> for <a href="https://github.com/sarfata/pi-blaster.js">pi-blaster.js</a> and <a href="https://github.com/sweetpi">sweet pi</a> for inspiration and his work on best automatization software <a href="http://pimatic.org/">Pimatic</a>.