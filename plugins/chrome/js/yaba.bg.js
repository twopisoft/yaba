var icons = {
    ok:     "img/yaba19_ok.png",
    err:    "img/yaba19_err.png",
    normal: "img/yaba19.png",
    saving: "img/yaba19_up.png"  
};

var titles = {
    ok:     "Bookmark Saved", 
    err:    "Error Saving Bookmark!",
    normal: "YABA",
    saving: "Saving Bookmark.."
}

var yaba_url = 'http://getyaba-staging.herokuapp.com/'

chrome.browserAction.onClicked.addListener(function(tab) {
    saveBookmark(tab);
});

chrome.contextMenus.create({type: 'normal', title: 'Save to YABA', id: 'save_to_yaba', contexts: ['page','frame', 'link', 'image', 'video', 'audio']})
chrome.contextMenus.create({type: 'normal', title: 'Goto to YABA', id: 'go_to_yaba', contexts: ['page','frame', 'link', 'image', 'video', 'audio']})

chrome.contextMenus.onClicked.addListener(function(info, tab) {
    if (info.menuItemId == 'save_to_yaba') {
        saveBookmark(tab)
    } else if (info.menuItemId == 'go_to_yaba') {
        openHomePage()
    }
})

function saveBookmark(tab) {
    setTitle(titles.saving)
    setIcon(icons.saving)
    chrome.cookies.get({url: yaba_url,
                        name: 'csrftoken'}, function(cookie) {
                            if (cookie) {
                               chrome.tabs.sendMessage(tab.id, {type: "yaba_getVideoTime", url: tab.url, title: tab.title}, function(qparams) {
                                //console.log(qparams)
                                if (qparams) {
                                    tab.title = qparams.title
                                    tab.url = qparams.url
                                }

                                sendData(tab, cookie)

                               })
                            } else {
                                setError()
                                revertToNormal(5000)
                                openHomePage()
                            }
                        })
    
};

function setIcon(icon) {
    chrome.browserAction.setIcon({path: icon})
};

function setTitle(msg) {
    chrome.browserAction.setTitle({title: msg})
}

function sendData(tab, cookie, qparams) {
    var xhr = new XMLHttpRequest()
    var params = {
        added: new Date(),
        updated: new Date(),
        name:  tab.title,
        url:   tab.url,
        description: '',
        tags: '',
        has_notify: false,
        notify_on: ""

    }
    var url = yaba_url+'.json'
    xhr.open('POST', url, true)
    xhr.setRequestHeader('Content-type', 'application/json')
    xhr.setRequestHeader('X-CSRFToken', cookie.value)

    xhr.onreadystatechange = function() {
        if (xhr.readyState == 4) {
            if (xhr.status == 201) {
                setOk()
                revertToNormal(5000)
            } else if (xhr.status == 403) {
                setNormal()
                openHomePage()
            } else {
                setError()
                revertToNormal(5000)
            }
        }
    }

    setSaving()
    xhr.send(JSON.stringify(params))
}

function openHomePage() {
    chrome.tabs.create({url: yaba_url})
}

function revertToNormal(millis) {
    if (millis > 0) {
        //chrome.alarms.create('revert', {delayInMinutes: mins})
        setTimeout(setNormal, millis)
    } else {
        setNormal()
    }
}

function setOk() {
    setTitle(titles.ok)
    setIcon(icons.ok)
}

function setNormal() {
    setTitle(titles.normal)
    setIcon(icons.normal)
}

function setError() {
    setTitle(titles.err)
    setIcon(icons.err)
}

function setSaving() {
    setTitle(titles.saving)
    setIcon(icons.saving)
}

//chrome.alarms.onAlarm.addListener(function(alarm) {
//    if (alarm.name === 'revert') {
//        setNormal()
//    }
//})
