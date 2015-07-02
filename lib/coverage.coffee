{Emitter, Directory, File, TextEditor} = require("atom")
PythonCoverage = require("./python.coffee")
StatusBarView = require("./status-view.coffee")


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

    statistics: ->
        lines = {
            total: @coverage.covered.length + @coverage.missing.length + @coverage.excluded.length,
            covered: @coverage.covered.length,
            missing: @coverage.missing.length,
            excluded: @coverage.excluded.length,
        }
        return {
            lines: lines,
            covered: lines.covered / (lines.total - lines.excluded) or 0,
            missing: lines.missing / (lines.total - lines.excluded) or 0,
            excluded: lines.excluded / lines.total or 0,
        }

    setCoverage: (data) ->
        if data
            for field in ["covered", "missing", "excluded", "warning"]
                @coverage[field].length = 0
                field_data = data[field] or []
                for line in field_data
                    @coverage[field].push(line)
            @emitter.emit("update")
        else
            atom.notifications.addInfo(
                "No coverage data for #{@editor.getPath()}",
                {dismissable: true},
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
        @tile = null
        @status = new StatusBarView()
        @register("source.python", PythonCoverage)

        atom.workspace.observeTextEditors (editor) =>
            @addEditor(editor)

        atom.workspace.observeActivePaneItem (pane) =>
            if pane not instanceof TextEditor or pane.id not of @editors
                @status.clear()
                return
            @status.set(@editors[pane.id])

    addEditor: (editor) ->
        for scope, constructor of @plugins
            if scope == editor.getGrammar().scopeName
                @editors[editor.id] = new EditorCoverage(editor, constructor)

    register: (scope, constructor) ->
        console.log("Registering #{constructor} for #{scope}")
        @plugins[scope] = constructor

    attachStatusBar: (statusbar) ->
        atom.config.observe("coverage-python.statusBarLocation", (location) =>
            @tile.destroy() if @tile
            @tile = statusbar["add#{location}Tile"](
                item: @status,
                priority: 100,
            )

            atom.config.observe("coverage-python.statusBarFormat", (format) =>
                @tile.item.setFormat(format)
            )
        )


module.exports = Coverage
