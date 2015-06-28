{Emitter, Directory, File} = require("atom")
PythonCoverage = require("./python.coffee")


class EditorCoverage

    constructor: (editor, constructor) ->
        @editor = editor
        @emitter = new Emitter()
        @constructor = constructor
        @instance = new constructor(@)
        @coverage = {
            covered: [],
            missing: [],
            excluded: [],
            warning: [],
        }

    getProjectDirectory: () ->
        path = new File(@editor.getPath())
        for raw_project_path in atom.project.getPaths()
            project_path = new Directory(raw_project_path)
            if project_path.contains(path.path)
                return project_path

    getPath: () ->
        return new File(@editor.getPath())

    setCoverage: (data) ->
        if data
            {covered, excluded, missing, warning} = data
        else
            atom.notifications.addInfo(
                "No coverage data for #{@editor.getPath()}",
                {
                    dismissable: true,
                }
            )

    error: (error) ->
        atom.notifications.addError(
            "Error collecting coverage data with
            **#{@constructor}** for #{@editor.getPath()}",
            {
                dismissable: true,
                detail: error,
            }
        )


class Coverage

    constructor: ->
        @plugins = {}  # scope : constructor
        @editors = {}  # Editor : instance
        @register("source.python", PythonCoverage)

        atom.workspace.observeTextEditors (editor) =>
            @addEditor(editor)

    addEditor: (editor) ->
        for scope, constructor of @plugins
            if scope == editor.getGrammar().scopeName
                @editors[editor] = new EditorCoverage(editor, constructor)

    register: (scope, constructor) ->
        console.log("Registering #{constructor} for #{scope}")
        @plugins[scope] = constructor


module.exports = Coverage
