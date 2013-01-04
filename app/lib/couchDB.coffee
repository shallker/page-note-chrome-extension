# @description A coffee class to manage CouchDB APIs
# @author shallker.wang@profero.com

class CouchDB

    host: ''  # http://couchdb.com, database host
    name: ''  # database name
    db: ''

    constructor: (host, name)->
        @host = host
        @name = name
        @db = @host + @name

        
    insert: (docId, doc, en, un)->
        compete = (ev)->
            if @.status is 201
            then en.call @, @.responseText
            else un.call @, @.responseText
        @xhr
            method: 'PUT'
            url: @db + '/' + docId
            headers: 'Content-Type': 'application/json'
            listeners: load: compete
            requests: JSON.stringify doc

    add: (doc, en, un)->
        compete = (ev)->
            if @.status is 201
            then en.call @, @.responseText
            else un.call @, @.responseText
        @xhr
            method: 'POST'
            url: @db
            headers: 'Content-Type': 'application/json'
            listeners: load: compete
            requests: JSON.stringify doc

    get: (docId, en, un)->
        compete = (ev)->
            if @.status is 200
            then en.call @, @.responseText
            else un.call @, @.responseText
        @xhr
            method: 'GET'
            url: @db + '/' + docId
            headers:
                'Content-Type': 'application/json'
                'Accept': 'application/json'
            listeners: load: compete

    del: ()->

    has: (docId, en, un)->
        compete = (ev)->
            if @.status is 200
            then en.call @
            else un.call @, @.responseText
        @xhr
            method: 'HEAD'
            url: @db + '/' + docId
            headers: 'Content-Type': 'application/json'
            listeners: load: compete
    
    conflict: ->

    xhr: (options)->
        xhr = new XMLHttpRequest
        xhr.addEventListener ev, ls for ev, ls of options.listeners
        # xhr.addEventListener 'load', compete
        xhr.open(options.method, options.url, true)
        xhr.setRequestHeader(na, va) for na, va of options.headers
        xhr.send(options.requests)
        xhr.responseText

module.exports = CouchDB