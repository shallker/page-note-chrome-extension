Spine  = @Spine or require('spine')
$      = Spine.$
Model  = Spine.Model

Ajax =
  getURL: (object) ->
    object and object._url?() or object._url

  enabled:  true
  pending:  false
  requests: []

  disable: (callback) ->
    if @enabled
      @enabled = false
      try
        do callback
      catch e
        throw e
      finally
        @enabled = true
    else
      do callback

  requestNext: ->
    next = @requests.shift()
    if next
      @request(next)
    else
      @pending = false

  request: (callback) ->
    (do callback).complete(=> do @requestNext)

  queue: (callback) ->
    return unless @enabled
    if @pending
      @requests.push(callback)
    else
      @pending = true
      @request(callback)
    callback

class Base
  defaults:
    contentType: 'application/json'
    dataType: 'json'
    processData: false
    headers: {'X-Requested-With': 'XMLHttpRequest'}

  ajax: (params, defaults) ->
    $.ajax($.extend({}, @defaults, defaults, params))

  queue: (callback) ->
    Ajax.queue(callback)

class Collection extends Base
  constructor: (@model) ->

  find: (id, params) ->
    record = new @model(id: id)
    @ajax(
      params,
      type: 'GET',
      url:  Ajax.getURL(record)
    ).success(@recordsResponse)
     .error(@errorResponse)

  all: (params) ->
    db = Ajax.getURL(@model)
    db_all = db + '/_all_docs?include_docs=true'
    @ajax(
      params,
      type: 'GET',
      # url:  Ajax.getURL(@model)
      # @s
      url:  db_all
    ).success(@recordsResponse)
     .error(@errorResponse)

  fetch: (params = {}, options = {}) ->
    if id = params.id
      delete params.id
      @find(id, params).success (record) =>
        @model.refresh(record, options)
    else
      @all(params).success (records) =>
        # @model.refresh(records, options)
        # @s
        rcs = []
        rcs.push row.doc for row in records.rows
        @model.refresh(rcs, options)

  # Private

  recordsResponse: (data, status, xhr) =>
    @model.trigger('ajaxSuccess', null, status, xhr)

  errorResponse: (xhr, statusText, error) =>
    @model.trigger('ajaxError', null, xhr, statusText, error)

class Singleton extends Base
  constructor: (@record) ->
    @model = @record.constructor

  reload: (params, options) ->
    @queue =>
      console.log Ajax.getURL(@record)
      @ajax(
        params,
        type: 'GET'
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  create: (params, options) ->
    @queue =>
      url = Ajax.getURL(@model) + '/' + @record.id
      console.log 'create', @record
      @ajax(
        params,
        type: 'PUT'
        data: JSON.stringify(@record)
        url: url
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  update: (params, options) ->
    @queue =>
      console.log 'update', @record
      @ajax(
        params,
        type: 'PUT'
        data: JSON.stringify(@record)
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  destroy: (params, options) ->
    @queue =>
      @ajax(
        params,
        type: 'DELETE'
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  # Private

  recordResponse: (options = {}) =>
    (data, status, xhr) =>
      if Spine.isBlank(data)
        data = false
      else
        # @s, update local record '_rev' column after a new revision
        @record._rev = data.rev if data.rev 
        data = @model.fromJSON(data)

      Ajax.disable =>
        if data
          # ID change, need to do some shifting
          if data.id and @record.id isnt data.id
            @record.changeID(data.id)

          # Update with latest data
          @record.updateAttributes(data.attributes())

      @record.trigger('ajaxSuccess', data, status, xhr)
      options.success?.apply(@record)

  errorResponse: (options = {}) =>
    (xhr, statusText, error) =>
      @record.trigger('ajaxError', xhr, statusText, error)
      options.error?.apply(@record)

# Ajax endpoint
Model.host = ''

Include =
  ajax: -> new Singleton(this)

  _url: (args...) ->
    url = Ajax.getURL(@constructor)
    url += '/' unless url.charAt(url.length - 1) is '/'
    url += encodeURIComponent(@id)
    args.unshift(url)
    args.join('/')

Extend =
  ajax: -> new Collection(this)

  _url: (args...) ->
    args.unshift(@className.toLowerCase() + 's')
    # @s allows you to define a "@host = 'http://...'" in your model
    args.unshift(Model.host || @host)
    args.join('/')

Model.Ajax =
  extended: ->
    @fetch @ajaxFetch
    @change @ajaxChange

    @extend Extend
    @include Include

  # Private

  ajaxFetch: ->
    @ajax().fetch(arguments...)

  ajaxChange: (record, type, options = {}) ->
    return if options.ajax is false
    record.ajax()[type](options.ajax, options)

Model.Ajax.Methods =
  extended: ->
    @extend Extend
    @include Include

# Globals
Ajax.defaults   = Base::defaults
Spine.Ajax      = Ajax
module?.exports = Ajax