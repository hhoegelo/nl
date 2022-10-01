"use strict";
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
exports.__esModule = true;
exports.DeclarationsParser = void 0;
var yaml_1 = require("../yaml");
exports.DeclarationsParser = new yaml_1.Parser(new yaml_1.Type("declarations", {
    kind: "mapping",
    keys: [
        "sound_type", "layer_id", "return_behavior",
        "parameter_properties", "parameter_type", "parameter_signal", "parameter_unit",
        "parameter_rounding", "parameter_reference", "parameter_infinity", "parameter_group",
        "smoother_section", "smoother_clock", "smoother_scale",
        "display_scaling_type"
    ],
    resolve: function (declarations) {
        return this.keys.reduce(function (out, key) { return out && (key in declarations); }, true);
    },
    construct: function (declarations) {
        var enums = {
            sound_type: Object.keys(declarations.sound_type).join(",\n"),
            layer_id: __spreadArray(__spreadArray([], Object.keys(declarations.layer_id), true), ["_LENGTH_"], false).join(",\n"),
            return_behavior: Object.keys(declarations.return_behavior).join(",\n"),
            parameter_type: Object.keys(declarations.parameter_type).join(",\n"),
            parameter_signal: Object.keys(declarations.parameter_signal).join(",\n"),
            parameter_unit: Object.keys(declarations.parameter_unit).join(",\n"),
            parameter_rounding: Object.keys(declarations.parameter_rounding).join(",\n"),
            parameter_infinity: Object.keys(declarations.parameter_infinity).join(",\n"),
            parameter_group: Object.keys(declarations.parameter_group).join(",\n"),
            smoother_section: Object.keys(declarations.smoother_section).join(",\n"),
            smoother_clock: Object.keys(declarations.smoother_clock).join(",\n"),
            smoother_scale: Object.keys(declarations.smoother_scale).join(",\n"),
            display_scaling_type: Object.keys(declarations.display_scaling_type).join(",\n")
        };
        return { declarations: declarations, enums: enums };
    }
}));
