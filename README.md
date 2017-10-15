pimatic-piblaster
================

Support for the <a href="https://github.com/sarfata/pi-blaster">pi-blaster daemon</a>.

First install and run the pi-blaster daemon (<a href="https://github.com/sarfata/pi-blaster#how-to-build-and-install">instructions</a>).

<a href="https://github.com/sarfata/pi-blaster#how-to-use">Usable pins</a>

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
  "id": "pi-blaster-pwm",
  "name": "Pi blaster PWM",
  "class": "PiblasterPWM",
  "gpio": 18,
  "mode": "fade",
  "delay": 100,
  "correction": "cie1931"
}
```

Thank you <a href="https://github.com/sarfata">sarfata</a> for <a href="https://github.com/sarfata/pi-blaster.js">pi-blaster.js</a> and <a href="https://github.com/sweetpi">sweet pi</a> for inspiration and his work on best automatization software <a href="http://pimatic.org/">Pimatic</a>.