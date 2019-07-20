fs = require("fs")
{BufferedProcess, Directory, File} = require("atom")


class PythonCoverage

    constructor: (editor) ->
        @editor = editor
        @emitter = editor.emitter
        @data_file = editor.getProjectDirectory().getFile(".coverage")
        @executable = "python"
        @readCoverageData()
        fs.watchFile(@data_file.path, {interval: 1000}, =>
            @readCoverageData()
        )

    @toString: ->
        return "coverage-python"

    readCoverageData: (path) ->
        if not @data_file.existsSync()
            @editor.setCoverage()
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
                @editor.setCoverage(JSON.parse(full_stdout))
            else
                @editor.error("Exited with non-zero
                              status #{status}\n#{full_stderr}")

        process = new BufferedProcess({
            command: @executable,
            args: [script.path, @data_file.path, @editor.getPath().path],
            stdout: onStdout,
            stderr: onStderr,
            exit: onExit,
        })


module.exports = PythonCoverage
