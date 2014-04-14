var data = require("sdk/self").data
var widget = require("sdk/widget")
var tabs = require("sdk/tabs")
var request = require("sdk/request")
var timer = require("sdk/timers")
var pageMod = require("sdk/page-mod")
var cm = require("sdk/context-menu")

var yaba_url = 'http://getyaba-staging.herokuapp.com/'

var {Cc, Ci} = require("chrome");
var cookieSvc = Cc["@mozilla.org/cookieService;1"].getService(Ci.nsICookieService);
var ios = Cc["@mozilla.org/network/io-service;1"].getService(Ci.nsIIOService)

var titles = {
    ok:     "Bookmark Saved", 
    err:    "Error Saving Bookmark!",
    normal: "YABA",
    saving: "Saving Bookmark.."
}

var icons = {
    ok:     data.url("yaba19_ok.png"),
    err:    data.url("yaba19_err.png"),
    normal: data.url("yaba19.png"),
    saving: data.url("yaba19_up.png") 
};

var yaba_action = widget.Widget({
    id: "yaba_action",
    label: "YABA",
    tooltip: "YABA",
    contentURL: data.url("yaba19.png"),
    onClick: function() {
        saveBookmark()
    }
});

var workers = {}

function detachWorker(worker, workerDict) {
    var key = null
    for (k in workerDict) {
        if (workerDict[k] == worker) {
            key = k
            break
        }
    }
    if (key) {
        delete workerDict[key]
    }
}

pageMod.PageMod({
    include: "*.youtube.com",
    contentScriptFile: [data.url("jquery.min.js"), data.url("video.js")],
    contentScriptOptions: {
        selector: "#movie_player span.ytp-time-current",
        query_param: "&#t="
    },
    contentScriptWhen: "end",
    onAttach: function(worker) {
        workers[tabs.activeTab.id] = worker
        worker.on('detach', function() {
            detachWorker(this, workers)
        })
    }
})

pageMod.PageMod({
    include: "*.vimeo.com",
    contentScriptFile: [data.url("jquery.min.js"), data.url("video.js")],
    contentScriptOptions: {
        selector: "div.timecode > div.box",
        query_param: "#t="
    },
    contentScriptWhen: "end",
    onAttach: function(worker) {
        workers[tabs.activeTab.id] = worker
        worker.on('detach', function() {
            detachWorker(this, workers)
        })
    }
})

var menuItem = cm.Menu({
    label: "YABA",
    image: data.url("yaba19.png"),
    items: [
        cm.Item({
            label: "Save to YABA",
            data: "save",
            contentScript: 'self.on("click", function(node, data) { self.postMessage(data); })',
            onMessage: function(data) {
                saveBookmark()
            }
        }),
        cm.Item({
            label: "Goto YABA",
            data: "goto",
            contentScript: 'self.on("click", function(node, data) { self.postMessage(data); })',
            onMessage: function(data) {
                openHomePage()
            }
        }),
    ]
})

menuItem.context.add()

function saveBookmark() {
    setTitle(titles.saving)
    setIcon(icons.saving)
    var csrftoken = getCookie('csrftoken')
    if (csrftoken) {
        var data = {title: tabs.activeTab.title, url: tabs.activeTab.url}
        var worker = workers[tabs.activeTab.id]
        if (worker) {
            worker.port.emit("yaba_getVideoTime_request", data)
            worker.port.on("yaba_getVideoTime_response", function(response) {
                sendData(response, csrftoken)
            })
        } else {
            sendData(data, csrftoken)
        }
    } else {
        setError()
        revertToNormal(5000)
        openHomePage()
    }
}

function sendData(tab, cookie) {
    console.error('cookie='+cookie)
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

    var headers = {
        'X-CSRFToken': cookie
    }

    setSaving()

    request.Request ({
        url: yaba_url+'.json',
        content: JSON.stringify(params),
        contentType: 'application/json',
        headers: headers,
        onComplete: function(response) {
            if (response.status == 201) {
                setOk()
                updateTab()
                revertToNormal(5000)
            } else if (response.status == 403) {
                setNormal()
                openHomePage()
            } else {
                setError()
                revertToNormal(5000)
            }
        }

    }).post();
}

function openHomePage() {
    tabs.open({
        url: yaba_url,
    });
}

function updateTab() {
    for each(var tab in tabs) {
        if (tab.url == yaba_url) {
            tab.reload()
            break
        }
    }
}

function setTitle(label) {
    yaba_action.tooltip = label
}

function setIcon(icon) {
    yaba_action.contentURL = icon
}

function revertToNormal(millis) {
    if (millis > 0) {
        timer.setTimeout(setNormal, millis)
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

function getCookie(name) {
    var uri = ios.newURI(yaba_url, null, null)
    var cookies = cookieSvc.getCookieString(uri, null)

    var cookie_pairs = cookies.split('&')
    var c = {}
    
    for (i=0; i<cookie_pairs.length; i++) {
        var pair = cookie_pairs[i].split('=')
        c[pair[0]] = pair[1].split(';')[0]
    }

    return c[name]
}
