Coverage = require("./coverage.coffee")


module.exports =
    config:
        pythonExecutable:
            type: "string"
            default: "python"
            description: "The Python executable used to invoke coverage.py."
    activate: ->
        @coverage = new Coverage();
