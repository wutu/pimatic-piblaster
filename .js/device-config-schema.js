module.exports = {
  title: "pimatic-piblaster device config schemas",
  PiblasterDimmer: {
    title: "PiblasterDimmer config options",
    type: "object",
    extensions: ["xLink"],
    properties: {
      gpio: {
        description: "The gpio pin",
        type: "number"
      },
      mode: {
        description: "Mode (dim or skip)",
        type: "string",
        "default": "skip"
      },
      correction: {
        description: "Linear or non-linear run (cie1931 or linear)",
        type: "string",
        "default": "cie1931"
      },
      delay: {
        description: "Delay between steps (ms)",
        type: "integer",
        "default": 100
      },
      lastDimlevel: {
        description: "",
        type: "number",
        "default": 0,
        options: {
          hidden: true
        }
      }
    }
  }
};
