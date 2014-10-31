module.exports = (env) ->

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  piblaster = require 'pi-blaster.js'
  Promise.promisifyAll(piblaster)

  class PiblasterPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>

      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("PiblasterDimmer", {
        configDef: deviceConfigDef.PiblasterDimmer,
        createCallback: (config) ->
          device = new PiblasterDimmer(config)
          return device
      })

  class PiblasterDimmer extends env.devices.DimmerActuator
    _dimlevel: null

    constructor: (@config, lastState) ->
      @id = config.id
      @name = config.name
      @gpio = config.gpio
      @dimlevel = config.lastDimlevel
      super()

    changeDimlevelTo: (dimlevel) ->
      @_setDimlevel(dimlevel)
      pilevel = (parseFloat(dimlevel) / 100)
      piblaster.setPwmAsync(@gpio, pilevel)
      return Promise.resolve()

  plugin = new PiblasterPlugin

  return plugin