{$, View} = require("space-pen")


class StatusBarView extends View

    @content: ->
        @div =>
            @span "coverage-python"

    initialize: ->
        @format = ""
        $(@.element).addClass("coverage")

    interpolate: ->
        $(@.element).find("span").text(@format)

    setFormat: (format) ->
        @format = format
        @interpolate()


module.exports = StatusBarView
