"use strict";
var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        if (typeof b !== "function" && b !== null)
            throw new TypeError("Class extends value " + String(b) + " is not a constructor or null");
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
exports.__esModule = true;
exports.generateOutputFile = exports.performReplacement = exports.Parser = exports.Type = void 0;
var fs = require("fs");
var yaml = require("js-yaml");
var namespace = "tag:nonlinear-labs.de,2022:js-yaml";
function fsTestFile(filename) {
    if (!fs.existsSync(filename))
        throw new Error("fs error: file ".concat(filename, " doesn't exist"));
    if (!fs.statSync(filename).isFile())
        throw new Error("fs error: ".concat(filename, " is not a file"));
}
var Type = /** @class */ (function (_super) {
    __extends(Type, _super);
    function Type(name, options) {
        return _super.call(this, "".concat(namespace, ":").concat(name), {
            kind: options.kind,
            resolve: function (data) {
                if ([null, undefined].includes(data))
                    return false;
                if (options.resolve)
                    return options.resolve(data);
                return true;
            },
            construct: function (data) {
                if (options.construct)
                    return options.construct(data);
                return data;
            }
        }) || this;
    }
    return Type;
}(yaml.Type));
exports.Type = Type;
var Parser = /** @class */ (function () {
    function Parser() {
        var schema = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            schema[_i] = arguments[_i];
        }
        this.schema = yaml.DEFAULT_SCHEMA.extend(schema);
    }
    Parser.prototype.parse = function (filename) {
        fsTestFile(filename);
        return yaml.load(fs.readFileSync(filename, "utf-8"), { filename: filename, schema: this.schema });
    };
    Parser.prototype.parseAll = function () {
        var _this = this;
        var filenames = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            filenames[_i] = arguments[_i];
        }
        return filenames.map(function (filename) { return _this.parse(filename); });
    };
    return Parser;
}());
exports.Parser = Parser;
function performReplacement(str, result, filename) {
    return str.replace(/([ \t]*)\$\{([^\}]*)\}/g, function (_, ws, keys) {
        if (ws === void 0) { ws = ""; }
        var known = result;
        keys.split(".").forEach(function (key) {
            if (key in known) {
                known = known[key];
            }
            else {
                var msg = "unknown key \"".concat(key, "\" in ").concat(keys);
                if (filename) {
                    throw new Error("generateOutputFile error in ".concat(filename, ": ").concat(msg));
                }
                else {
                    throw new Error("generateOutputFile error: ".concat(msg));
                }
            }
        });
        return ws + known.toString().split("\n").join("\n".concat(ws));
    });
}
exports.performReplacement = performReplacement;
function createDirectoryStructure(file) {
    var path = file.split('/');
    path.splice(path.length - 1, 1);
    var directory = path.join('/');
    fs.mkdir(directory, function (err) {
        console.error(err);
    });
}
function generateOutputFile(infile, outfile, result) {
    fsTestFile(infile);
    createDirectoryStructure(outfile);
    fs.writeFileSync(outfile, performReplacement(fs.readFileSync(infile, "utf-8"), result, infile));
}
exports.generateOutputFile = generateOutputFile;
