"use strict";
exports.__esModule = true;
exports.DefinitionsParser = void 0;
var yaml_1 = require("../yaml");
exports.DefinitionsParser = new yaml_1.Parser(new yaml_1.Type("definitions", {
    kind: "mapping",
    keys: ["group", "parameters"],
    resolve: function (definitions) {
        return this.keys.reduce(function (out, key) { return out && (key in definitions); }, true);
    }
}));
