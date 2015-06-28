{Emitter, Notification} = require("atom")
PythonCoverage = require("./python.coffee")


class Coverage
    constructor: ->
        console.log(atom)
        @languages = {}
        @add("python", PythonCoverage)

        path = "zm/pipeline.py"

        onError = (error) ->
            atom.notifications.addError(
                "Error collecting coverage data with
                **#{PythonCoverage}** for `#{path}`",
                {
                    dismissable: true,
                    detail: error,
                }
            )

        emitter = new Emitter
        emitter.on("error", onError)

        @languages["python"].cover(emitter, path)
    add: (language, constructor) ->
        @languages[language] = new constructor(
            atom.config.get("coverage-python.pythonExecutable"))


module.exports = Coverage
