var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = function(env) {
  var PI_BLASTER_PATH, PiblasterDimmer, PiblasterPlugin, Promise, assert, cie1931, fs, linear, plugin, _;
  Promise = env.require('bluebird');
  assert = env.require('cassert');
  fs = require('fs');
  _ = env.require('lodash');
  PI_BLASTER_PATH = "/dev/pi-blaster";
  cie1931 = [];
  fs.readFile("/home/pi/pimatic-app/node_modules/pimatic-piblaster/cie1931.txt", function(err, data) {
    if (err) {
      throw err;
    }
    return cie1931 = data.toString().split("\, ");
  });
  linear = _.range(0, 1, 0.001);
  PiblasterPlugin = (function(_super) {
    __extends(PiblasterPlugin, _super);

    function PiblasterPlugin() {
      this.init = __bind(this.init, this);
      return PiblasterPlugin.__super__.constructor.apply(this, arguments);
    }

    PiblasterPlugin.prototype.init = function(app, framework, config) {
      var deviceConfigDef;
      this.framework = framework;
      this.config = config;
      deviceConfigDef = require("./device-config-schema");
      return this.framework.deviceManager.registerDeviceClass("PiblasterDimmer", {
        configDef: deviceConfigDef.PiblasterDimmer,
        createCallback: function(config) {
          var device;
          device = new PiblasterDimmer(config);
          return device;
        }
      });
    };

    return PiblasterPlugin;

  })(env.plugins.Plugin);
  PiblasterDimmer = (function(_super) {
    var writeCommand;

    __extends(PiblasterDimmer, _super);

    function PiblasterDimmer(config, lastState) {
      var i, index;
      this.config = config;
      this.id = config.id;
      this.name = config.name;
      this.gpio = config.gpio;
      this.mode = config.mode;
      this.correction = config.correction;
      this.delay = config.delay / 10;
      if (config.lastDimlevel != null) {
        this._dimlevel = config.lastDimlevel || 0;
      }
      this._state = config.lasDtimlevel > 0;
      if (this._dimlevel > 0) {
        if (this.correction === "cie1931") {
          writeCommand(this.gpio + "=" + ((function() {
            var _i, _len, _results;
            _results = [];
            for (index = _i = 0, _len = cie1931.length; _i < _len; index = ++_i) {
              i = cie1931[index];
              if (index === this._dimlevel * 10) {
                _results.push(i);
              }
            }
            return _results;
          }).call(this)));
        }
        if (this.correction === "linear") {
          writeCommand(this.gpio + "=" + (this._dimlevel / 100));
        }
      }
      PiblasterDimmer.__super__.constructor.call(this);
    }

    PiblasterDimmer.prototype.changeDimlevelTo = function(dimlevel) {
      var actlevel, i, index, level, slice;
      if (this._dimlevel === dimlevel) {
        return;
      } else {
        actlevel = this._dimlevel * 10;
        level = dimlevel * 10;
        if (this.config.mode === "skip") {
          if (this.config.correction === "linear") {
            writeCommand(this.gpio + "=" + (dimlevel / 100));
          }
          if (this.config.correction === "cie1931") {
            writeCommand(this.gpio + "=" + ((function() {
              var _i, _len, _results;
              _results = [];
              for (index = _i = 0, _len = cie1931.length; _i < _len; index = ++_i) {
                i = cie1931[index];
                if (index === level) {
                  _results.push(i);
                }
              }
              return _results;
            })()));
          }
        } else if (this.config.mode === "dim") {
          if (this.config.correction === "cie1931") {
            if (this._dimlevel < dimlevel) {
              slice = cie1931.slice(actlevel, level);
              this._pwm(slice, this.gpio, this.delay);
            }
            if (this._dimlevel > dimlevel) {
              slice = cie1931.slice(level, actlevel).reverse();
              this._pwm(slice, this.gpio, this.delay);
            }
          } else if (this.config.correction === "linear") {
            if (this._dimlevel < dimlevel) {
              slice = linear.slice(actlevel, level);
              this._pwm(slice, this.gpio, this.delay);
            }
            if (this._dimlevel > dimlevel) {
              slice = linear.slice(level, actlevel).reverse();
              this._pwm(slice, this.gpio, this.delay);
            }
          } else {
            env.logger.error("Error pwm on " + this.config.name);
          }
        }
        this._setDimlevel(dimlevel);
      }
      return Promise.resolve();
    };

    PiblasterDimmer.prototype._setDimlevel = function(dimlevel) {
      PiblasterDimmer.__super__._setDimlevel.call(this, dimlevel);
      this.config.lastDimlevel = dimlevel;
      return plugin.framework.saveConfig();
    };

    writeCommand = function(cmd) {
      var buffer, fd;
      buffer = new Buffer(cmd + "\n");
      fd = fs.open(PI_BLASTER_PATH, "w", undefined, function(err, fd) {
        if (err) {
          env.logger.error("Error opening file: " + err);
        } else {
          fs.write(fd, buffer, 0, buffer.length, -1, function(error, written, buffer) {
            if (error) {
              env.logger.error("Error occured writing to " + PI_BLASTER_PATH + ": " + error);
            } else {
              fs.close(fd);
            }
          });
        }
      });
    };

    PiblasterDimmer.prototype._pwm = function(arr, gpio, delay) {
      var loop_;
      loop_ = function(i) {
        return setTimeout((function() {
          writeCommand(gpio + "=" + arr[i]);
          if (i < arr.length - 1) {
            loop_(i + 1);
          }
        }), delay);
      };
      return loop_(0);
    };

    return PiblasterDimmer;

  })(env.devices.DimmerActuator);
  plugin = new PiblasterPlugin;
  return plugin;
};
