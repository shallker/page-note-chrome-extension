# @description A class to manage chrome.extension's APIs
# @author shallker.wang@profero.com

class ChromeExtension

  constructor: ->

  # call = (response)->
  @sendMessage: (msg, call)->
    chrome.extension.sendMessage msg, call

  # listener = (request, sender, sendResponse)->
  @listenMessage: (listener)->
    chrome.extension.onMessage.addListener listener

  # mesg = {}
  # call = (msg)->
  @postMessage: (msg, call)->
    port = @connect()
    port.postMessage msg
    port.onMessage.addListener call

  @connect: (name = '')->
    chrome.extension.connect name: name
    
module.exports = ChromeExtension