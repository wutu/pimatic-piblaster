module.exports = {
  title: "pimatic-piblaster device config schemas"
  PiblasterDimmer: {
    title: "PiblasterDimmer config options"
    type: "object"
    extensions: ["xLink"]
    properties:
      gpio:
        description: "The gpio pin"
        type: "number"
      dimlevel:
        description: "Initial dimlevel"
        type: "number"
        default: 0
  }
}