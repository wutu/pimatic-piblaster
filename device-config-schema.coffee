module.exports = {
  title: "pimatic-piblaster device config schemas"
  PiblasterPWM: {
    title: "PiblasterPWM config options"
    type: "object"
    extensions: ["xLink"]
    properties:
      gpio:
        description: "The GPIO number (https://github.com/sarfata/pi-blaster#how-to-use)"
        type: "number"
      mode:
        description: "Mode (fade or direct)"
        type: "string"
        default: "fade"
        enum: ["fade", "linear"]
      delay:
        description: "Delay between steps (ms)"
        type: "integer"
        default: 100
      correction:
        description: "Linear or cie1931 (http://jared.geek.nz/2013/feb/linear-led-pwm)"
        type: "string"
        default: "cie1931"
        enum: ["cie1931", "linear"]
  }
}