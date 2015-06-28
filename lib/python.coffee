{BufferedProcess, Directory, File} = require "atom"


class PythonCoverage

    constructor: (directory, editor, emitter) ->
        @emitter = emitter
        @editor = editor
        @data_file = directory.getFile(".coverage")
        @executable = "/home/oliver/miniconda3/envs/zpp/bin/python"
        @readCoverageData()

    @toString: ->
        return "coverage-python"

    readCoverageData: (path) ->
        if not @data_file.existsSync()
            @emitter.emit("no-data")
            return
        package_path = new Directory(
            atom.packages.resolvePackagePath("coverage-python"))
        script = package_path.getFile("read-coverage.py")
        stdout = []
        stderr = []

        onStdout = (string) ->
            stdout.push(string);

        onStderr = (string) ->
            stderr.push(string);

        onExit = (status) =>
            full_stdout = stdout.join("")
            full_stderr = stderr.join("")

            if status == 0
                coverage = JSON.parse(full_stdout)
            else
                @emitter.emit("error", "Exited with non-zero status
                             #{status}\n#{full_stderr}")

        process = new BufferedProcess({
            command: @executable,
            args: [script.path, @data_file.path, @editor.getPath()],
            stdout: onStdout,
            stderr: onStderr,
            exit: onExit,
        })


module.exports = PythonCoverage
