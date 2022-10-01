"use strict";
exports.__esModule = true;
exports.ConfigParser = void 0;
var yaml_1 = require("../yaml");
exports.ConfigParser = new yaml_1.Parser(new yaml_1.Type("config", {
    kind: "mapping",
    construct: function (config) { return { config: config }; }
}));
