
chrome.extension.onMessage.addListener(function(request, sender, response) {
    if (request.type == "yaba_getVideoTime") {
        var timeStr=''
        var url = request.url
        var title = request.title

        var elem = $(".ytp-time-current")
        console.log('elem='+$(elem))
        if (elem && elem.length > 0) {
            var timeElems = $(elem).first().text().split(':')
            if (timeElems.length==3) {
                timeStr = timeElems[0]+'h'+timeElems[1]+'m'+timeElems[2]+'s'
            } else if (timeElems.length==2) {
                timeStr = timeElems[0]+'m'+timeElems[1]+'s'
            }

            var regex_title = new RegExp(/\((\d{0,3}h)*\d{0,3}m\d{0,3}s\)/)
            var regex_url = new RegExp(/#t=(\d{0,3}h)*\d{0,3}m\d{0,3}s/)
            //console.log(timeStr)
            if (timeStr != '') {
                title = (regex_title.test(title) ? title.replace(regex_title,'('+timeStr+')') : (title + ' ('+timeStr+')'))
                url = (regex_url.test(url) ? url.replace(regex_url,'#t='+timeStr) : (url + '&#t='+timeStr))
            } else {
                title = title.replace(regex_title,'')
                url = url.replace(regex_url,'')
            }

            response(
                {
                    url: url,
                    title: title
                }
            )
        } else {
            response({url: request.url, title: request.title})
        }
    }
})


