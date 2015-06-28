{BufferedProcess} = require "atom"


class PythonCoverage

    constructor: (executable) ->
        @executable = executable

    @toString: ->
        return "coverage-python"

    cover: (emitter, path) ->
        console.log("#{path}")

        stdout = []
        stderr = []

        onStdout = (string) ->
            stdout.push(string);

        onStderr = (string) ->
            stderr.push(string);

        onExit = (status) ->
            full_stdout = stdout.join("")
            full_stderr = stderr.join("")

            if status == 0
                coverage = JSON.parse(full_stdout)
            else
                emitter.emit("error", "Exited with non-zero status
                             #{status}\n#{full_stderr}")

        process = new BufferedProcess({
            command: @executable,
            args: ["/home/oliver/wc/atom-coverage-python/read-coverage.py"],
            stdout: onStdout,
            stderr: onStderr,
            exit: onExit,
        })


module.exports = PythonCoverage
