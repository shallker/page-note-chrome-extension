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

  @lisenActive: (listener)->
    chrome.tabs.onActivated.addListener listener

  @getSelected: (listener)->
    chrome.tabs.getSelected null, listener

  @getCurrent: ->
    chrome.tabs.getCurrent()

  @injectScript: (tabId = null, file)->
    console.log tabId, file
    chrome.tabs.executeScript tabId, file: file

  @injectStyle: (tabId = null, file)->
    console.log tabId, file
    chrome.tabs.insertCSS tabId, file: file

module.exports = ChromeTabs