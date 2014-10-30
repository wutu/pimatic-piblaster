pimatic-piblaster
================

Support for the pi-blaster.js - Soft PWM.

### Example config

Add the plugin to the plugin section:

```json
{ 
  "plugin": "piblaster"
}
```

Then add a sensor for your device to the devices section:

```json
{
  "id": "led-sw-pwm",
  "name": "LED SW PWM",
  "class": "PiblasterDimmer",
  "gpio": "18",
  "dimlevel": 0
}
```
