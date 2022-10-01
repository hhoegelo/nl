"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
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
var process = require("process");
var fs = require("fs");
var yaml_1 = require("./yaml");
var config_1 = require("./tasks/config");
var declarations_1 = require("./tasks/declarations");
var definitions_1 = require("./tasks/definitions");
var indent = " ".repeat(4);
function validateToken(token) {
    return /^\w+$/.test(token);
}
function replaceResultInFiles(result, sourceDir, outDir) {
    var files = [];
    for (var _i = 3; _i < arguments.length; _i++) {
        files[_i - 3] = arguments[_i];
    }
    files.forEach(function (infile) {
        var outfile = infile.replace(sourceDir, outDir).replace(/.in$/, "");
        (0, yaml_1.generateOutputFile)(infile, outfile, result);
    });
}
// validate (essential sanity checks) and transform parsed yaml output
function processDefinitions(result) {
    var errmsg = "processDefinitions error", 
    // parameter validation: unique id/token
    params = [], 
    // parameterID collection (resulting in enum)
    pid = [], 
    // parameterType collection (resulting in enum)
    parameterType = Object.entries(result.declarations.parameter_type).reduce(function (out, _a) {
        var type = _a[0], props = _a[1];
        if (type !== "None") {
            // every type !== None can collect tokens
            if (!props.includes("parameter_id_none")) {
                out["".concat(type, "s")] = [];
            }
            else {
                out["".concat(type, "s")] = ["None"];
            }
        }
        return out;
    }, {}), 
    // smootherType collection (resulting in enum)
    smootherType = Object.keys(result.declarations.smoother_section).reduce(function (out, section) {
        if (section !== "None") {
            Object.keys(result.declarations.smoother_clock).forEach(function (clock) {
                out["".concat(section, "_").concat(clock)] = [];
            });
        }
        return out;
    }, {}), 
    // signalType collection (resulting in enum)
    signalType = Object.keys(result.declarations.parameter_signal).reduce(function (out, type) {
        if (type !== "None")
            out["".concat(type, "s")] = [];
        return out;
    }, {});
    // automatic detection of number of params (highest parameter id)
    result.config.params = 1 + result.definitions.reduce(function (max, definition) {
        return Math.max(max, Math.max.apply(Math, definition.parameters.map(function (parameter) {
            if (!Number.isInteger(parameter.id)) {
                throw new Error("".concat(errmsg, " in ").concat(definition.filename, ": parameter id \"").concat(parameter.id, "\" is invalid"));
            }
            if (parameter.id < 0 || parameter.id > 16382) {
                throw new Error("".concat(errmsg, " in ").concat(definition.filename, ": parameter id ").concat(parameter.id, " is out of tcd range [0 ... 16382]"));
            }
            return parameter.id;
        })));
    }, 0);
    // parameterList collection
    var processedGroups = [], parameterList = new Array(result.config.params).fill("{None}");
    // for every yaml resource of ./src/definitions, providing a parameter group
    result.definitions.sort(function () {
        var defs = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            defs[_i] = arguments[_i];
        }
        return defs.reduce(function (out, _a, index) {
            var filename = _a.filename, group = _a.group;
            var err = "".concat(errmsg, " in ").concat(filename), found = result.declarations.parameter_group[group];
            if (found === undefined) {
                throw new Error("".concat(err, ": unknown group token \"").concat(group, "\""));
            }
            if (found === null) {
                return Infinity;
            }
            return out + ([1, -1][index] * found.index);
        }, 0);
    }).forEach(function (_a) {
        var filename = _a.filename, definition = __rest(_a, ["filename"]);
        var err = "".concat(errmsg, " in ").concat(filename), group = {
            name: definition.group,
            data: result.declarations.parameter_group[definition.group]
        };
        // group sanity checks
        if (processedGroups.includes(group.name)) {
            throw new Error("".concat(err, ": group \"").concat(group.name, "\" is already defined"));
        }
        processedGroups.push(group.name);
        // for every parameter of the group
        definition.parameters.forEach(function (parameter, index) {
            var type = { name: parameter.type, data: result.declarations.parameter_type[parameter.type] }, 
            // required
            token = parameter.token, id = parameter.id, label_long = parameter.label_long, label_short = parameter.label_short, control_position = parameter.control_position, info = parameter.info, availability = parameter.availability, 
            // optional
            return_behavior = parameter.return_behavior, modulation_aspects = parameter.modulation_aspects, rendering_args = parameter.rendering_args;
            // type sanity checks
            if (type.data === undefined) {
                throw new Error("".concat(err, ": unknown parameter type \"").concat(type.name, "\""));
            }
            type.data.forEach(function (property) {
                if (!result.declarations.parameter_properties.includes(property)) {
                    throw new Error("".concat(err, ": unknown parameter type property \"").concat(property, "\""));
                }
            });
            // global/local sanity checks
            var isGlobalParam = type.data.includes("global_parameter");
            if (group.data.global_group) {
                if (!isGlobalParam) {
                    throw new Error("".concat(err, ": global group \"").concat(group.name, "\" cannot contain non-global parameter id ").concat(id));
                }
            }
            else {
                if (isGlobalParam) {
                    throw new Error("".concat(err, ": non-global group \"").concat(group.name, "\" cannot contain global parameter id ").concat(id));
                }
            }
            // property sanity checks
            [token, label_long, label_short, control_position, info, availability].forEach(function (property) {
                if (property === undefined) {
                    throw new Error("".concat(err, ": insufficient parameter definition in group \"").concat(group.name, "\" element ").concat(index + 1));
                }
            });
            if (!validateToken(token)) {
                throw new Error("".concat(err, ": invalid parameter token \"").concat(token, "\" in parameter id ").concat(id));
            }
            // token and descriptor generation
            var tokenStr = type.data.includes("group_label") ? "".concat(group.name, "_").concat(token) : token, typeStr = "".concat(type.name, "s"), smootherDescriptor = [], playgroundDescriptor = [];
            // parameterId sanity checks
            if (params.includes(id)) {
                throw new Error("".concat(err, ": parameter id ").concat(id, " is already defined"));
            }
            if (params.includes(tokenStr)) {
                throw new Error("".concat(err, ": parameter token ").concat(tokenStr, " is already defined"));
            }
            // feed relevant enum buffers
            params.push(id, tokenStr);
            pid[id] = "".concat(tokenStr, " = ").concat(id);
            parameterType[typeStr].push(tokenStr);
            // controlPosition properties
            var coarse = control_position.coarse, fine = control_position.fine, scale = control_position.scale, initial = control_position.initial, inactive = control_position.inactive, displayScalingType = result.declarations.display_scaling_type[scale];
            // controlPosition sanity checks
            [coarse, fine, scale, initial].forEach(function (property) {
                if (property === undefined) {
                    throw new Error("".concat(err, ": insufficient control_position definition in paramter id ").concat(id));
                }
            });
            // displayScalingType sanity checks
            if (displayScalingType === undefined) {
                throw new Error("".concat(err, ": unknown DisplayScalingType \"").concat(scale, "\" in parameter id ").concat(id));
            }
            var bipolar = displayScalingType.bipolar;
            var displayScaling = {
                cp: "Properties::DisplayScalingType::".concat(scale),
                ma: "Properties::DisplayScalingType::None"
            };
            // feed playgroundDescriptor
            playgroundDescriptor.push(coarse.toString(), fine.toString());
            // optional returnBehavior - currently unused
            if (type.data.includes("return_behavior")) {
                // returnBehavior sanity checks
                if (return_behavior === undefined) {
                    throw new Error("".concat(err, ": parameter id ").concat(id, " of type \"").concat(type.name, "\" requires return_behavior"));
                }
            }
            // optional modulationAspects, feeding playgrounDescriptor
            if (type.data.includes("modulation_aspects")) {
                // modulationAspects sanity checks
                if (modulation_aspects === undefined) {
                    throw new Error("".concat(err, ": parameter id ").concat(id, " of type \"").concat(type.name, "\" requires modulation_aspects"));
                }
                // modulationAspects properties
                var coarse_1 = modulation_aspects.coarse, fine_1 = modulation_aspects.fine, scale_1 = modulation_aspects.scale, displayScalingType_1 = result.declarations.display_scaling_type[scale_1];
                // modulationAspect property sanity checks
                [coarse_1, fine_1, scale_1].forEach(function (property) {
                    if (property === undefined) {
                        throw new Error("".concat(err, ": insufficient modulation_aspects definition in paramter id ").concat(id));
                    }
                });
                if (displayScalingType_1 === undefined) {
                    throw new Error("".concat(err, ": unknown DisplayScalingType \"").concat(scale_1, "\" in modulation_aspects of parameter id ").concat(id));
                }
                if (displayScalingType_1.bipolar !== true) {
                    throw new Error("".concat(err, ": DisplayScalingType \"").concat(scale_1, "\" in modulation_aspects of parameter id ").concat(id, " can only be bipolar"));
                }
                displayScaling.ma = "Properties::DisplayScalingType::".concat(scale_1);
                playgroundDescriptor.push(coarse_1.toString(), fine_1.toString());
            }
            else {
                playgroundDescriptor.push("None", "None");
            }
            // feed playgroundDescriptor with parameter labels and info strings
            playgroundDescriptor.push.apply(playgroundDescriptor, __spreadArray(__spreadArray([], [
                inactive || "", group.data.label_long, group.data.label_short, label_long, label_short,
                info.trim().replace(/\n/g, "\\n")
            ].map(function (entry) { return "\"".concat(entry, "\""); }), false), [displayScaling.cp, displayScaling.ma], false));
            // optional renderingArgs (relevant for C15Synth only)
            if (type.data.includes("rendering_args")) {
                // renderingArgs sanity checks
                if (rendering_args === undefined) {
                    throw new Error("".concat(err, ": parameter id ").concat(id, " of type \"").concat(type.name, "\" requires rendering_args"));
                }
                // renderingArgs properties
                var scaling = rendering_args.scaling, factor = rendering_args.factor, offset = rendering_args.offset, section = rendering_args.section, clock = rendering_args.clock, signal = rendering_args.signal, sectionType = "".concat(section, "_").concat(clock);
                // optional smootherSection handling
                if (section !== "None") {
                    // clock sanity checks
                    if (clock === "None") {
                        throw new Error("".concat(err, ": invalid smoother clock \"").concat(clock, "\" in parameter id ").concat(id));
                    }
                    // renderingArgs property sanity checks
                    if (!smootherType[sectionType]) {
                        throw new Error("".concat(err, ": invalid smoother \"").concat(sectionType, "\" in parameter id ").concat(id));
                    }
                    // feed SmootherDescriptor
                    smootherDescriptor.push("Smoothers::".concat(sectionType, "::").concat(tokenStr));
                    // smootherType
                    smootherType[sectionType][id] = tokenStr;
                }
                else {
                    smootherDescriptor.push("None");
                }
                // optional parameterSignal, feeding SmootherDescriptor
                if (signal) {
                    if (signal !== "None") {
                        var signalStr = "".concat(signal, "s");
                        // signalType sanity checks
                        if (signalType[signalStr] === undefined) {
                            throw new Error("".concat(err, ": unknown signal \"").concat(signal, "\" in parameter id ").concat(id));
                        }
                        if (signalType[signalStr].includes(tokenStr)) {
                            throw new Error("".concat(err, ": signal \"").concat(signal, "\" in parameter id ").concat(id, " is already defined"));
                        }
                        signalType[signalStr].push(tokenStr);
                        smootherDescriptor.push("Signals::".concat(signalStr, "::").concat(tokenStr));
                    }
                    else {
                        smootherDescriptor.push("None");
                    }
                }
                // parameter scaling
                smootherDescriptor.push("Properties::SmootherScale::".concat(scaling), factor, offset, bipolar.toString());
            }
            // final parameterDescriptor
            var descriptor = [
                "Parameters::".concat(typeStr, "::").concat(tokenStr),
                "PID::".concat(tokenStr),
                initial,
                (rendering_args === undefined ? "{}" :
                    "{\n".concat(indent.repeat(2)).concat(smootherDescriptor.join(",\n".concat(indent.repeat(2))), "\n").concat(indent, "}")),
                "{\n".concat(indent.repeat(2)).concat(playgroundDescriptor.join(",\n".concat(indent.repeat(2))), "\n").concat(indent, "}")
            ];
            // feed parameterList
            parameterList[id] = [
                "{",
                descriptor.map(function (entry) { return "".concat(indent).concat(entry); }).join(",\n"),
                "}"
            ].join("\n");
        });
        // collect explicitly defined signals of parameter group
        if (definition.signals !== undefined) {
            Object.entries(definition.signals).forEach(function (_a) {
                var key = _a[0], value = _a[1];
                var signalGroup = "".concat(key, "s");
                if (signalType[signalGroup] === undefined) {
                    throw new Error("".concat(err, ": unknown signal type \"").concat(key, "\" in group \"").concat(group.name, "\""));
                }
                value.forEach(function (signal) {
                    if (!validateToken(signal)) {
                        throw new Error("".concat(err, ": invalid explicit signal token \"").concat(signal, "\""));
                    }
                    var signalStr = "".concat(group.name, "_").concat(signal);
                    if (signalType[signalGroup].includes(signalStr)) {
                        throw new Error("".concat(err, ": signal \"").concat(signalStr, "\" in in group \"").concat(group.name, "\" is already defined"));
                    }
                    // append explicit signal
                    signalType[signalGroup].push(signalStr);
                });
            });
        }
    });
    // provide string replacements
    result.parameter_list = parameterList.join(",\n");
    result.parameter_units = Object.values(result.declarations.parameter_unit).map((function (entry) { return "\"".concat(entry, "\""); })).join(",\n");
    result.display_scaling_types = Object.entries(result.declarations.display_scaling_type).reduce(function (out, _a) {
        var key = _a[0], props = _a[1];
        out.push("{\n".concat(indent).concat([
            "Properties::DisplayScalingType::".concat(key),
            "Properties::ParameterRounding::".concat(props.round),
            "Properties::ParameterUnit::".concat(props.unit),
            "Properties::ParameterInfinity::".concat(props.inf),
            props.bipolar.toString()
        ].join(",\n".concat(indent)), "\n}"));
        return out;
    }, new Array()).join(",\n");
    result.parameter_groups = Object.entries(result.declarations.parameter_group).reduce(function (out, _a) {
        var key = _a[0], props = _a[1];
        if (props === null) {
            out.push("{\n".concat(indent, "Descriptors::ParameterGroup::").concat(key, "\n}"));
        }
        else {
            out.push("{\n".concat(indent).concat([
                "Descriptors::ParameterGroup::".concat(key),
                "{".concat(props.color.join(", "), "}"),
                "\"".concat(props.label_long, "\""),
                "\"".concat(props.label_short, "\""),
                (props.global_group || false).toString()
            ].join(",\n".concat(indent)), "\n}"));
        }
        return out;
    }, new Array()).join(",\n");
    result.parameters = Object.entries(parameterType).reduce(function (out, _a) {
        var key = _a[0], entries = _a[1];
        out.push("enum class ".concat(key, " {\n").concat(indent).concat(__spreadArray(__spreadArray([], entries, true), ["_LENGTH_"], false).join(",\n".concat(indent)), "\n};"));
        return out;
    }, []).join("\n");
    result.smoothers = Object.entries(smootherType).reduce(function (out, _a) {
        var key = _a[0], entries = _a[1];
        out.push("enum class ".concat(key, " {\n").concat(indent).concat(__spreadArray(__spreadArray([], entries.filter((function (entry) { return entry !== undefined; })), true), ["_LENGTH_"], false).join(",\n".concat(indent)), "\n};"));
        return out;
    }, []).join("\n");
    result.signals = Object.entries(signalType).reduce(function (out, _a) {
        var key = _a[0], entries = _a[1];
        out.push("enum class ".concat(key, " {\n").concat(indent).concat(__spreadArray(__spreadArray([], entries, true), ["_LENGTH_"], false).join(",\n".concat(indent)), "\n};"));
        return out;
    }, []).join("\n");
    result.enums.pid = __spreadArray(["None = -1"], pid.filter(function (id) { return id !== undefined; }), true).join(",\n");
}
function generateOverview(result, sourceDir, outDir) {
    var timestamp = result.timestamp, config = result.config, parameter_list = result.definitions.reduce(function (out, _a) {
        var group = _a.group, parameters = _a.parameters;
        out.push.apply(out, parameters.map(function (p) { return __assign(__assign({}, p), { group: group }); }));
        return out;
    }, new Array()).sort(function (a, b) { return a.id - b.id; }).reduce(function (out, _a) {
        var group = _a.group, id = _a.id, type = _a.type, label_long = _a.label_long;
        var group_label = result.declarations.parameter_group[group].label_long, rgb = result.declarations.parameter_group[group].color.join(",");
        out[id] = [
            "<div class=\"parameter\" title=\"".concat(group_label, " / ").concat(label_long, "\" style=\"background-color: rgb(").concat(rgb, ");\">"),
            "".concat(indent, "<code class=\"parameter-type\">").concat(type, "</code>"),
            "".concat(indent, "<div class=\"group-label\">").concat(group_label, "</div>"),
            "".concat(indent, "<code class=\"parameter-id\">").concat(id, "</code>"),
            "".concat(indent, "<div class=\"parameter-label\">").concat(label_long, "</div>"),
            "</div>"
        ].join("\n");
        return out;
    }, new Array(result.config.params).fill('<div title="unused"></div>')).join("\n"), parameterCountColumns = Object.keys(result.declarations.parameter_type).filter(function (pt) { return pt !== "None"; }).length, parameter_count = Object.keys(result.declarations.parameter_type).reduce(function (out, paramType) {
        if (paramType !== "None") {
            out[1].push("<div class=\"hdr\">".concat(paramType.replace("_", "<br>"), "</div>"));
            var params_1 = result.definitions.reduce(function (out, _a) {
                var parameters = _a.parameters;
                out.push.apply(out, parameters.filter(function (_a) {
                    var type = _a.type;
                    return type === paramType;
                }));
                return out;
            }, new Array());
            Object.keys(result.declarations.sound_type).filter(function (st) { return st !== "None"; }).forEach(function (soundType, index) {
                var countSimple = params_1.reduce(function (count, _a) {
                    var availability = _a.availability;
                    return count + (availability[soundType].count === 0 ? 0 : 1);
                }, 0), countDual = params_1.reduce(function (count, _a) {
                    var availability = _a.availability;
                    return count + availability[soundType].count;
                }, 0);
                if (countSimple === countDual) {
                    out[2 + index].push("<div>".concat(countSimple, "</div>"));
                }
                else {
                    out[2 + index].push("<div>".concat(countSimple, " (").concat(countDual, ")</div>"));
                }
            });
        }
        return out;
    }, __spreadArray(__spreadArray([
        ["<div class=\"parameter-count\" style=\"grid-template-columns: repeat(".concat(1 + parameterCountColumns, ", max-content);\">")],
        ['<div class="hdr">Sound<br>Type</div>']
    ], Object.keys(result.declarations.sound_type).filter(function (st) { return st !== "None"; }).map(function (soundType) {
        return ["<div class=\"hdr\">".concat(soundType, "</div>")];
    }), true), [
        ["</div>"]
    ], false)).map(function (row) { return row.join("\n"); }).join("\n"), parameter_groups = Object.entries(result.declarations.parameter_group).reduce(function (out, _a) {
        var _ = _a[0], groupProps = _a[1];
        if (groupProps !== null) {
            out.push("<li>".concat(groupProps.label_long, "</li>"));
        }
        return out;
    }, new Array()).join("\n");
    (0, yaml_1.generateOutputFile)(sourceDir + "/src/overview.html.in", outDir + "/overview.html", { timestamp: timestamp, config: config, parameter_list: parameter_list, parameter_count: parameter_count, parameter_groups: parameter_groups });
}
// main function
function main(outDir, sourceDir) {
    var 
    // scan definitions folder to collect contained yaml resources for automatical parsing
    definitionsPath = sourceDir + "/src/definitions", definitions = fs.readdirSync(definitionsPath).map(function (filename) {
        return "".concat(definitionsPath, "/").concat(filename);
    }).filter(function (filename) {
        return fs.statSync(filename).isFile();
    }), 
    // yaml parsing
    result = __assign(__assign(__assign({ timestamp: new Date(), parameters: "", smoothers: "", signals: "", pid: "", parameter_list: "", parameter_units: "", display_scaling_types: "", parameter_groups: "" }, config_1.ConfigParser.parse(sourceDir + "/src/c15_config.yaml")), declarations_1.DeclarationsParser.parse(sourceDir + "/src/parameter_declarations.yaml")), { definitions: definitions_1.DefinitionsParser.parseAll.apply(definitions_1.DefinitionsParser, definitions).map(function (definition, index) {
            return __assign(__assign({}, definition), { filename: definitions[index] });
        }) });
    // validate declaration tokens
    Object.keys(result.declarations).forEach(function (enumeration) {
        if (!validateToken(enumeration)) {
            throw new Error("declarations error: invalid enumeration token \"".concat(enumeration, "\""));
        }
        Object.keys(result.declarations[enumeration]).forEach(function (token) {
            if (!validateToken(token)) {
                throw new Error("declarations error: invalid token \"".concat(token, "\" in enumeration ").concat(enumeration));
            }
        });
    });
    // order ParameterGroups
    Object.entries(result.declarations.parameter_group).forEach(function (_a, index) {
        var groupName = _a[0], groupProps = _a[1];
        if (groupProps !== null) {
            Object.assign(result.declarations.parameter_group[groupName], { index: index });
        }
    });
    // processing of parsed yaml (sanity checks, enum sorting/filtering, providing strings for replacements)
    processDefinitions(result);
    // transformations of ./src/*.in.* files into usable resources in ./generated via string replacements
    replaceResultInFiles(result, sourceDir, outDir, 
    // transformations covered by g++ and therefore safe
    sourceDir + "/src/c15_config.h.in", sourceDir + "/src/parameter_declarations.h.in", sourceDir + "/src/parameter_list.h.in", sourceDir + "/src/parameter_descriptor.h.in", sourceDir + "/src/display_scaling_type.h.in", sourceDir + "/src/parameter_group.h.in", sourceDir + "/src/main.cpp.in", 
    // transformations not covered by g++ and therefore unsafe
    sourceDir + "/src/placeholder.h.in", sourceDir + "/src/ParameterFactory.java.in", sourceDir + "/src/MacroIds.js.in", 
    // validation
    sourceDir + "/src/validate.h.in", sourceDir + "/src/validate.cpp.in");
    // overview
    generateOverview(result, sourceDir, outDir);
}
function createDirectorys(dir) {
    fs.mkdir(dir, function (err) {
        console.error(err);
    });
}
// process
try {
    var myArgs = process.argv.slice(1);
    var sourceDirectoryParts = myArgs[0].split("/");
    sourceDirectoryParts.pop();
    sourceDirectoryParts.pop();
    var sourceDirectoryPath = "/" + sourceDirectoryParts.join("/");
    var outDirectory = myArgs[1];
    createDirectorys(outDirectory);
    main(outDirectory, sourceDirectoryPath);
    process.exit(0);
}
catch (err) {
    console.error(err);
    process.exit(1);
}
