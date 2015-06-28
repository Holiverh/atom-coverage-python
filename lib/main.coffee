Coverage = require("./coverage.coffee")


module.exports =

    config:
        pythonExecutable:
            type: "string"
            default: "python"
            description: "The Python executable used to invoke coverage.py."
        statusBarFormat:
            type: "string"
            default: "%C% coverage"
            description: "How to display coverage statistics in the status
                bar. The following format characters are available: %c
                covered lines, %m missing lines, %e excluded lines. Uppercase
                variants are available for percentages."
        statusBarLocation:
            type: "string"
            default: "Right"
            enum: ["Left", "Right"]

    activate: ->
        @coverage = new Coverage();

    consumeStatusBar: (statusbar) ->
        @coverage.attachStatusBar(statusbar)
