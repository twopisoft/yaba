
self.port.on('yaba_getVideoTime_request', function(request) {
    var timeStr=''
    var url = request.url
    var title = request.title

    var elem = $(self.options.selector)
    if (elem && elem.length > 0) {
        var timeElems = $(elem).first().text().split(':')
        if (timeElems.length==3) {
            timeStr = timeElems[0]+'h'+timeElems[1]+'m'+timeElems[2]+'s'
        } else if (timeElems.length==2) {
            timeStr = timeElems[0]+'m'+timeElems[1]+'s'
        }

        var regex_title = new RegExp(/\((\d{0,3}h)*\d{0,3}m\d{0,3}s\)/)
        var regex_url = new RegExp(/#t=(\d{0,3}h)*\d{0,3}m\d{0,3}s/)
        console.error(timeStr)
        if (timeStr != '') {
            title = (regex_title.test(title) ? title.replace(regex_title,'('+timeStr+')') : (title + ' ('+timeStr+')'))
            url = (regex_url.test(url) ? url.replace(regex_url,'#t='+timeStr) : (url + self.options.query_param+timeStr))
        } else {
            title = title.replace(regex_title,'')
            url = url.replace(regex_url,'')
        }

        self.port.emit('yaba_getVideoTime_response', {url: url, title: title})
    } else {
        self.port.emit('yaba_getVideoTime_response', {url: url, title: title})
    }
})


