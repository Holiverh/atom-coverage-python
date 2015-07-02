{$, View} = require("space-pen")


class StatusBarView extends View

    @content: ->
        @div =>
            @span "coverage-python", outlet: "formatted"

    initialize: ->
        @coverage = null
        @watch = null
        @format = ""
        $(@.element).addClass("coverage")
        @clear()

    clear: ->
        @coverage = null
        $(@.element).addClass("coverage-hidden")

    set: (coverage) ->
        if @watch
            @watch.dispose()
        @coverage = coverage
        @watch = @coverage.emitter.on("update", => @interpolate())
        @interpolate()
        $(@.element).removeClass("coverage-hidden")

    interpolate: ->
        if not @coverage
            return
        stats = @coverage.statistics()
        values = {
            "c": stats.lines.covered,
            "m": stats.lines.missing,
            "e": stats.lines.excluded,
            "C": Math.round(stats.covered * 100),
            "M": Math.round(stats.missing * 100),
            "E": Math.round(stats.excluded * 100),
        }
        string = @format
        for key, value of values
            string = string.replace(new RegExp("%#{key}"), value)
        @formatted.text(string)

    setFormat: (format) ->
        @format = format
        @interpolate()


module.exports = StatusBarView
