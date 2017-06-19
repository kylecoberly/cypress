_ = require("lodash")

$Cypress = require("../cypress")

class $Chainer
  constructor: (@cy) ->
    @id        = _.uniqueId("chainer")
    @firstCall = true

  @remove = (key) ->
    delete $Chainer.prototype[key]

  @inject = (key, fn) ->
    ## when our instance methods are invoked
    ## we know we are chaining on an existing series
    $Chainer.prototype[key] = (args...) ->
      ## dont enqueue / inject any new commands if
      ## onInjectCommand returns false
      onInjectCommand = @cy.state("onInjectCommand")

      if _.isFunction(onInjectCommand)
        return if onInjectCommand.call(@cy, key, args...) is false

      ## call back the original function with our new args
      ## pass args an as array and not a destructured invocation
      fn.call(@cy, @id, @firstCall, args)

      ## no longer the first call
      @firstCall = false

      ## return the chainer so additional calls
      ## are slurped up by the chainer instead of cy
      return @

  ## creates a new chainer instance
  @create = (cy, key, args) ->
    chainer = new $Chainer(cy)

    ## since this is the first function invocation
    ## we need to pass through onto our instance methods
    chainer[key].apply(chainer, args)

module.exports = $Chainer