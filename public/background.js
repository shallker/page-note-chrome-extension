chrome.tabs.onCreated.addListener(function(tab) {
    console.log(tab);
})

chrome.commands.onCommand.addListener(function(command) {
    console.log('command:', command);
    if (command == 'toggle-pinned') {
        chrome.tabs.getSelected(null, function(tab) {
            // Toggle the pinned status
            chrome.tabs.update(tab.id, {'pinned': !tab.pinned}); 
       });
    }
})

chrome.commands.getAll(function(a) {
    console.log('getAll:', a);
})

chrome.browserAction.onClicked.addListener(function(click) {
    console.log('click:', click);
})

// chrome.browserAction.onClicked.addListener

chrome.extension.onMessage.addListener(function(request, sender, sendResponse) {
    console.log('message:', request, sender, sendResponse);
    sendResponse(localStorage);
    // if (request.greeting == "hello") sendResponse({farewell: "goodbye"});
});
