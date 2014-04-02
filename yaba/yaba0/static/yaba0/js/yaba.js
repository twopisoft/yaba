if (typeof jQuery == 'undefined') {
    throw new Error("jQuery not loaded")
}

$(document).ready(function() {
    setup()
});

var errorMessages= {
    FORBIDDEN: "No enough permission"
}

var base_url='/yaba0/api/'

function setup () {
    setupDate();
    setupCheckBoxes()
    setupSaveButtons()
    setupDeleteButtons()
    setupRestoreButtons()
    setupNotify()
    setupLogin()
}

function setupDate() {

    $('[id^=bm_details_]').on('show.bs.collapse', function() {
        var id = getId(this.id)
        $('#bm_date_added_'+id).text(utcToLocal($('#bm_date_added_'+id).text()))
        $('#bm_date_updated_'+id).text(utcToLocal($('#bm_date_updated_'+id).text()))
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
    $(".bm-form-required").unbind('keydown').keydown(function(e) {
        enableSaveButton(getId(e.target.id), true)
    });

    $(".bm-form-required").unbind('keyup').keyup(function(e) {
        var val=$('#'+e.target.id).val().trim()
        if (val == '') {
            $('#'+e.target.id).parent().addClass('has-error')
            enableSaveButton(getId(e.target.id), false)
        } else {
            $('#'+e.target.id).parent().removeClass('has-error')
            enableSaveButton(getId(e.target.id), true)
        }
    });

    $(".bm-form-optional").unbind('keydown').keydown(function(e) {
        enableSaveButton(getId(e.target.id), true)
    });
    
    $('[id^=bm_save_]').unbind('click').click(function() {
        saveBookmark(getId(this.id))
    });
}

function setupDeleteButtons () {
    $('[id^=bm_delete_]').unbind('click').click(function() {
        deleteBookmark(getId(this.id))
    })
    $('#bm_deleteall').unbind('click').click(function() {
        deleteSelected()
    })
}

function setupRestoreButtons() {
    $('[id^=bm_restore_]').unbind('click').click(function() {
        restoreBookmark(getId(this.id))
    })
}

function setupNotify() {
    $('[id^=bm_notify_date_]').datepicker({
        format: "MM dd, yyyy",
        startDate: '+1d',
        endDate: '+30d',
        autoclose: true,
        todayHighlight: true,
        orientation: "bottom left",
    })

    $('[id^=bm_has_notify_]').unbind('change').change(function() {
        var nd = $('#bm_notify_date_'+getId(this.id))
        nd.prop('disabled',!this.checked)
        nd.val("")
        if (this.checked) {
            nd.datepicker('setDate', '+1d')
        } 
        enableSaveButton(getId(this.id), true)
    })

    $.each($('[id^=bm_notify_date_]'), function(index, e) {
        if ($('#bm_has_notify_'+index).prop('checked')) {
            $(e).datepicker('setDate', new Date(utcToLocal($(e).val())))
        } else {
            $(e).val("")
        }
    })

    // careful when updating this method. Can cause problem with datepicker
    $('[id^=bm_notify_date_]').unbind('change').change(function() {
        enableSaveButton(getId(this.id), true)
    })
}

function setupLogin() {
    $('#bm_btn_login').unbind('click').click(function() {
        $('#login_modal').modal('show')
    })
}

function restoreBookmark(id) {
    $.ajax({
        url: base_url+$('#bm_id_'+id).val()+"/.json",
        type: "get",
        success: function(d, stat, xhr) {
            $('#bm_name_'+id).val(d.name)
            $('#bm_url_'+id).val(d.url)
            $('#bm_synopsis_'+id).val(d.description)
            $('#bm_tags_'+id).val(d.tags)
            $('#bm_has_notify_'+id).prop('checked',d.has_notify)

            var nd = $('#bm_notify_date_'+id)
            nd.datepicker('setDate',new Date(d.notify_on))
            if (d.has_notify) {
                nd.prop('disabled', false)
            } else {
                $('#bm_has_notify_'+id).trigger('change')
            }

            enableSaveButton(id, false)
        }
    })
}

function deleteBookmark(id) {
    var name=$('#bm_name_'+id).val().trim()
    $('#deleteConfirmMsg').text('This will Delete the following Bookmark:')
    $('#deleteConfirmText').text("'"+name+"'")
    $('#deleteOkButton').unbind('click').click(function() {
        executeDelete([id])
    })
    $('#deleteConfirm').modal('show')
}

function deleteSelected() {
    var selected = $('[id^=bm_select_]').filter(':checked')
    if (selected.length > 0) {
        var ids = []
        for (i=0; i<selected.length; i++) {
            ids.push(getId(selected[i].id))
        }
        var n = (selected.length > 4) ? 4 : selected.length
        var text = ""
        for (i=0; i<n; i++) {
            text += $('#bm_name_'+ids[i]).val().trim()+ "<br/>"
        }
        $('#deleteConfirmMsg').text('This will Delete the following Bookmark'+(selected.length>1?"s:":":"))
        $('#deleteConfirmText').html(text)
        $('#deleteOkButton').unbind('click').click(function() {
            executeDelete(ids)
        })
        $('#deleteConfirm').modal('show')
    }
}

function executeDelete(ids) {
    $('#deleteConfirm').modal('hide')
    var success=[]
    var error=[]
    $.each(ids, function(index, id) {       
        var name=$('#bm_name_'+id).val().trim()
        $.ajax({
            url: base_url+$('#bm_id_'+id).val()+"/.json",
            type: "delete",
            success: function(d, stat, xhr) {
                success.push(id)
                
            },
            error: function(xhr, stat, err) {
                error.push({id: id, name: name, error: error})
            },
            complete: function(xhr, stat) {
                if ((success.length + error.length) == ids.length) {
                    for (i=0; i < success.length; i++) {
                        $('#bm_row_'+success[i]).remove()
                    }

                    if (error.length > 0) {
                        var n = error.length > 4 ? 4 : error.length
                        var bodyText=""
                        for (i=0; i<n; i++) {
                            bodyText += error[i].name + "<br/>"
                        }
                        $('#resultTitle').text('Bookmark Deletion Failed')
                        $('#resultMsg').text("Error while Deleting following Bookmark"+(error.length>1?"s:":":"))
                        $('[id^=bm_select_').prop('checked', false)
                        $('#bm_selectall').prop('checked', false)
                        $('#resultText').html(bodyText)
                        $('#result').modal('show')
                    }
                }
            },
            beforeSend: function(xhr, settings) {
                xhr.setRequestHeader("X-CSRFToken", getCookie('csrftoken'))
            },
        })
    })
}

function enableSaveButton(id, flag) {
    assert (id != null, "enableSaveButton: Id is null");
    $('#bm_save_'+id).prop('disabled', !flag)
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
        has_notify  : $('#bm_has_notify_'+id).prop('checked'),
        notify_on   : (function() {
                        var flag = $('#bm_has_notify_'+id).prop('checked')
                        if (flag) return localToUtc($('#bm_notify_date_'+id).val())
                        else return null
                      })(),
    };

    $('#bm_title_'+id).text(data.name)
    $('#bm_title_'+id).attr('href',data.url)

    $.ajax({
        url: base_url+$('#bm_id_'+id).val()+"/.json",
        type: "put",
        data: data,
        success: function(d, stat, xhr) {
            $('#bm_save_'+id).prop('disabled', true)
            $('#bm_date_updated_'+id).text(curDate)
            $('#bm_save_success_'+id).show()
            $('#bm_save_success_'+id).fadeOut(5000)
        },
        error: function(xhr, stat, err) {
            reloadDataAndShowError(id)
        },
        beforeSend: function(xhr, settings) {
            xhr.setRequestHeader("X-CSRFToken", getCookie('csrftoken'))
        },
    });
    
}

function reloadDataAndShowError(id) {
    $.ajax({
        url: base_url+$('#bm_id_'+id).val()+"/.json",
        type: "get",
        success: function(d, stat, xhr) {
            $('#bm_name_'+id).val(d.name)
            $('#bm_url_'+id).val(d.url)
            $('#bm_synopsis_'+id).val(d.description)
            $('#bm_tags_'+id).val(d.tags)
            $('#bm_title_'+id).text(d.name)
            $('#bm_title_'+id).attr('href',d.url)
            $('#bm_has_notify_'+id).prop('checked',d.has_notify)
            $('#bm_notify_date_'+id).datepicker('setDate',new Date(d.notify_on))
            if (d.has_notify) {
                $('#bm_notify_date_'+id).prop('disabled', false)
            } else {
                $('#bm_has_notify_'+id).trigger('change')
            }

            $('#resultMsg').text("Error while updating following Bookmark:")
            $('#resultText').text("'"+d.name+"'")
            $('#resultTitle').text('Bookmark Update Failed')
            $('#result').modal('show')
            $('#bm_save_'+id).prop('disabled', true)
        }
    })
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

function addDays(date, days) {
    return new Date(date.getFullYear(),date.getMonth(),date.getDate()+days)
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
