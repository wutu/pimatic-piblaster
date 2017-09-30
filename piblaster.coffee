module.exports = (env) ->

  piblaster = require 'pi-blaster.js'
  Promise = env.require 'bluebird'
  fs = require 'fs'
  _ = env.require 'lodash'

  PI_BLASTER_PATH = "/dev/pi-blaster"

  cie1931 = []

  fs.readFile __dirname + "/cie1931.txt", (err, data) ->
    throw err if err
    cie1931 = data.toString().split("\, ")

  linear = (_.range(0, 1, 0.001))

  class PiblasterPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>

      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("PiblasterPWM", {
        configDef: deviceConfigDef.PiblasterPWM,
        createCallback: (@config) ->
          device = new PiblasterPWM(@config)
          return device
      })

  class PiblasterPWM extends env.devices.DimmerActuator

    constructor: (@config, lastState) ->
      @id = @config.id
      @name = @config.name
      @gpio = @config.gpio
      @mode = @config.mode
      @correction = @config.correction
      @delay = (@config.delay / 10)
      @_state = lastState?.state?.value or off
      @_dimlevel = lastState?.dimlevel?.value or 0
      super()

    changeDimlevelTo: (dimlevel) ->
      if @_dimlevel is dimlevel then return 
      else
        actlevel = @_dimlevel * 10
        level = dimlevel * 10
        if @config.mode is "direct"
          if @config.correction is "linear"
            piblaster.setPwm(@gpio + ", " + (dimlevel / 100))
          if @config.correction is "cie1931"
            piblaster.setPwm(@gpio + ", " + (i for i, index in cie1931 when index == level))
        else if @config.mode is "fade"
          if @config.correction is "cie1931"
            if @_dimlevel < dimlevel
              slice = cie1931.slice(actlevel, level)
              @_pwm(slice, @gpio, @delay)
            if @_dimlevel > dimlevel
              slice = cie1931.slice(level, actlevel).reverse()
              @_pwm(slice, @gpio, @delay)
          else if @config.correction is "linear"
            if @_dimlevel < dimlevel
              slice = linear.slice(actlevel, level)
              @_pwm(slice, @gpio, @delay)
            if @_dimlevel > dimlevel
              slice = linear.slice(level, actlevel).reverse()
              @_pwm(slice, @gpio, @delay)
          else
            env.logger.error("Error pwm on #{@config.name}")
        @_setDimlevel dimlevel
      return Promise.resolve()

    _pwm: (arr, gpio, delay) ->
      loop_ = (i) ->
        setTimeout (->
          piblaster.setPwm(gpio, arr[i])
          loop_ i + 1  if i < arr.length - 1
          return
        ), delay
      loop_ 0

    destroy: () ->
      # I'm waiting with this for version 1.2 on npmjs.com
      # piblaster.releasePwm(@gpio)
      super()

  plugin = new PiblasterPlugin

  return plugin
