if (typeof jQuery == 'undefined') {
    throw new Error("jQuery not loaded")
}

$(document).ready(function() {
    setup()
});

function setup () {
    setupDate();
    setupCheckBoxes()
    setupSaveButtons()
    setupDeleteButtons()
}

function setupDate() {
    $('#content').on('show.bs.collapse', function(event) {
        var id = event.target.id
        if (id.lastIndexOf("bm_details_") == 0) {
            var seq=id.substring(id.lastIndexOf("_"))
            var bm_date_added_id="#bm_date_added"+seq
            var bm_date_updated_id="#bm_date_updated"+seq
            $(bm_date_added_id).text(utcToLocal($(bm_date_added_id).text()))
            $(bm_date_updated_id).text(utcToLocal($(bm_date_updated_id).text()))
        }
    })
}

function setupCheckBoxes () {
    // Set select all checkbox
    $('#bm_selectall').change(function() {
        $('[id^=bm_select_]').prop('checked', this.checked)
        toggleGlobalButtons(this.checked)
    });

    // For individual checkbox. When all checkboxes are checked, check the select all one as well
    $('[id^=bm_select]').change(function() {
        var buttonsChecked=$('[id^=bm_select_]').filter(':checked').length
        var check= (buttonsChecked == $('[id^=bm_select_]').length)
        $('#bm_selectall').prop('checked', check)
        toggleGlobalButtons(buttonsChecked > 0)
    });
}

function setupSaveButtons() {
    $("input:text").change(function() {
        enableSaveButton(getId(this.id))
    });
    $('textarea').change(function() {
        enableSaveButton(getId(this.id))
    });
    $('[id^=bm_save_]').click(function() {
        saveBookmark(getId(this.id))
    });
}

function setupDeleteButtons () {
    // body...
}

function enableSaveButton(id) {
    assert (id != null, "enableSaveButton: Id is null");
    $('#bm_save_'+id).prop('disabled', false)
}

function toggleGlobalButtons(check) {
    $('#bm_shareall').prop('disabled', !check);
    $('#bm_deleteall').prop('disabled', !check)
}

function saveBookmark(id) {
    assert (id != null, "saveBookmark: Id is null");
    var curDate = new Date().toString()
    data = { 
        added       : localToUtc($('#bm_date_added_'+id).text()),
        updated     : localToUtc(curDate),
        name        : $('#bm_name_'+id).val().trim(),
        url         : $('#bm_url_'+id).val().trim(),
        description : $('#bm_synopsis_'+id).val().trim(),
        tags        : $('#bm_tags_'+id).val().trim(),
        has_notify  : false
    };

    $.ajax({
        url: "/yaba0/api/"+$('#bm_id_'+id).val()+"/.json",
        type: "put",
        data: data,
        success: function(d, stat, xhr) {
            $('#bm_save_'+id).prop('disabled', true)
            $('#bm_date_updated_'+id).text(curDate)
        },
        error: function(xhr, stat, err) {
            alert("Error: "+err)
        },
        beforeSend: function(xhr, settings) {
            xhr.setRequestHeader("X-CSRFToken", getCookie('csrftoken'))
        },
    });
    
}

function getId(targetId) {
    assert (targetId != null, "getId: Id is null");
    var id = /^.*?_(\d+)$/.exec(targetId);
    if (id != null) {
        return id[1]
    }
    return null
}

function utcToLocal(utcDate) {
    assert (utcDate != null, "utcDate is null")

    var localDate=(new Date(utcDate)).toString()
    if (localDate == "Invalid Date") {
        localDate = utcDate
    }
    return localDate
}

function localToUtc(localDate) {
    assert (localDate != null, "localDate is null")
    var utcDate = new Date(localDate)
    return utcDate.getUTCFullYear()+"-"+
           (utcDate.getUTCMonth()+1)+"-"+
           utcDate.getUTCDate()+"T"+
           utcDate.getUTCHours()+":"+
           utcDate.getUTCMinutes()+":"+
           utcDate.getUTCSeconds()+"Z"
}

function assert(condition, message) {
    if (!condition) throw message || "Assertion Failure"
}

// From Django help pages
function getCookie(name) {
    var cookieValue = null;
    if (document.cookie && document.cookie != '') {
        var cookies = document.cookie.split(';');
        for (var i = 0; i < cookies.length; i++) {
            var cookie = jQuery.trim(cookies[i]);
            // Does this cookie string begin with the name we want?
            if (cookie.substring(0, name.length + 1) == (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}
