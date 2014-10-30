pimatic-piblaster
================

Support for the <a href="https://github.com/sarfata/pi-blaster">pi-blaster daemon</a>.

Install the pi-blaster daemon (<a href="https://github.com/sarfata/pi-blaster">instructions</a>).

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
