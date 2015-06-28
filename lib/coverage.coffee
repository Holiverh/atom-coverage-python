{Emitter, Notification, Directory, File} = require("atom")
PythonCoverage = require("./python.coffee")


class Coverage

    constructor: ->
        @plugins = {}  # scope : constructor
        @editors = {}  # Editor : instance
        @register("source.python", PythonCoverage)

        atom.workspace.observeTextEditors (editor) =>
            @addEditor(editor)

    rootDirectoryForEditor: (editor) ->
        path = new File(editor.getPath())
        for raw_project_path in atom.project.getPaths()
            project_path = new Directory(raw_project_path)
            if project_path.contains(path.path)
                return project_path

    getEmitter: (editor, constructor) ->
        emitter = new Emitter()

        emitter.on "error", (error) =>
            atom.notifications.addError(
                "Error collecting coverage data with
                **#{constructor}**",
                {
                    dismissable: true,
                    detail: error,
                }
            )

        emitter.on "no-data", () ->
            atom.notifications.addInfo(
                "No coverage data for #{editor.getPath()}",
                {
                    dismissable: true,
                }
            )

        return emitter

    addEditor: (editor) ->
        directory = @rootDirectoryForEditor(editor)
        for scope, constructor of @plugins
            if scope == editor.getGrammar().scopeName
                emitter = @getEmitter(editor, constructor)
                coverage = new constructor(directory, editor, emitter)
                @editors[editor] = emitter

    register: (scope, constructor) ->
        console.log("Registering #{constructor} for #{scope}")
        @plugins[scope] = constructor


module.exports = Coverage
