module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  fs = require 'fs'
  _ = env.require 'lodash'

  PI_BLASTER_PATH = "/dev/pi-blaster"

  cie1931 = []

  fs.readFile "/home/pi/pimatic-app/node_modules/pimatic-piblaster/cie1931.txt", (err, data) ->
    throw err if err
    cie1931 = data.toString().split("\, ")

  linear = (_.range(0, 1, 0.001))

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

    constructor: (@config, lastState) ->
      @id = config.id
      @name = config.name
      @gpio = config.gpio
      @mode = config.mode
      @correction = config.correction
      @delay = (config.delay / 10)
      if config.lastDimlevel?
        @_dimlevel = config.lastDimlevel or 0
      @_state = (config.lasDtimlevel > 0)
      if @_dimlevel > 0
        if @correction is "cie1931"
          writeCommand @gpio + "=" + (i for i, index in cie1931 when index == @_dimlevel * 10)
        if @correction is "linear"
          writeCommand @gpio + "=" + (@_dimlevel / 100)
      super()

    changeDimlevelTo: (dimlevel) ->
      if @_dimlevel is dimlevel then return 
      else
        actlevel = @_dimlevel * 10
        level = dimlevel * 10
        if @config.mode is "skip"
          if @config.correction is "linear"
            writeCommand @gpio + "=" + (dimlevel / 100)
          if @config.correction is "cie1931"
            writeCommand @gpio + "=" + (i for i, index in cie1931 when index == level)
        else if @config.mode is "dim"
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

    _setDimlevel: (dimlevel) ->
      super dimlevel
      @config.lastDimlevel = dimlevel
      plugin.framework.saveConfig()

    writeCommand = (cmd) ->
      buffer = new Buffer(cmd + "\n")
      fd = fs.open(PI_BLASTER_PATH, "w", `undefined`, (err, fd) ->
        if err
          env.logger.error("Error opening file: " + err)
        else
          fs.write fd, buffer, 0, buffer.length, -1, (error, written, buffer) ->
            if error
              env.logger.error("Error occured writing to " + PI_BLASTER_PATH + ": " + error)
            else
              fs.close fd
            return
        return
      )
      return

    _pwm: (arr, gpio, delay) ->
      loop_ = (i) ->
        setTimeout (->
          # console.log arr[i]
          writeCommand gpio + "=" + arr[i]
          loop_ i + 1  if i < arr.length - 1
          return
        ), delay
      loop_ 0

  plugin = new PiblasterPlugin

  return plugin
