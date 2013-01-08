# @description A class to manage Chrome tabs's APIs
# @author shallker.wang@profero.com

class ChromeTabs

  constructor: ->

  @open: (url)->
    chrome.tabs.create url: url

  @listenUpdate: (listener)->
     chrome.tabs.onUpdated.addListener listener

  @listenCreate: (listener)->
    chrome.tabs.onCreated.addListener listener

  @listenActive: (listener)->
    chrome.tabs.onActivated.addListener listener

  @listenRemove: (listener)->
    chrome.tabs.onRemoved.addListener listener

  @getSelected: (listener)->
    chrome.tabs.getSelected null, listener

  @getCurrent: ->
    chrome.tabs.getCurrent()

  @injectScript: (tabId = null, file)->
    chrome.tabs.executeScript tabId, file: file

  @injectStyle: (tabId = null, file)->
    chrome.tabs.insertCSS tabId, file: file

module.exports = ChromeTabs