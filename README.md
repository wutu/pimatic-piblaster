pimatic-piblaster
================

Support for the [pi-blaster daemon][pi-blaster].

Install the pi-blaster daemon ([instructions][pi-blaster]).

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
  "gpio": "18",
  "dimlevel": 0
}
```
