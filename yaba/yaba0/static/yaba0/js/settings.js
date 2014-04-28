if (typeof jQuery == 'undefined') {
    throw new Error("jQuery not loaded")
}

$(document).ready(function() {
    setup()
});

var base_url='/'

function setup () {
    setupVerify()
    setupSave()
    setupSocial()
    setupRemove()
}

function setupVerify() {
    var vb = $('#bm_settings_btn_verify')
    if (vb) {
        $(vb).unbind('click').click(function() {
            var email = $('#bm_settings_email').val().trim()
            if (email) {
                data = {
                    email: email,
                    action_send: ''
                }
                $.ajax({
                    url: base_url+'accounts/email/',
                    type: "post",
                    data: data,
                    success: function(d, stat, xhr) {
                        showDialog(
                        {
                            title: 'Email Confirmation Sent',
                            line1: 'An email is sent to the address "'+email+'"',
                            line2: 'Please check your email and confirm your email address'
                        })
                    },
                    error: function(xhr, stat, err) {
                        showDialog({
                            title: 'Failed to send Email Confirmation',
                            line1: 'An error occured while sending an email confirmation message:',
                            line2: '"('+stat+') '+err+'"'
                        })
                    },
                    beforeSend: function(xhr, settings) {
                        xhr.setRequestHeader("X-CSRFToken", getCookie('csrftoken'))
                    },
                });
            }
        })
    }
}

function setupSave() {
    $('#bm_settings_save').unbind('click').click(function(e) {
        e.preventDefault()

        var email = $('#bm_settings_email').val().trim()
        if (email == '') {
            displayEmailError('Email address is missing')
        } else {
            var data = {
                paginate_by: (function() {
                    var v = $('#bm_settings_paginate').val()
                    if (v=='nopage') {
                        v = "0"
                    }
                    return v
                    })(),
                email_notify: $('#bm_settings_notify').prop('checked'),
                push_notify: $('#bm_settings_notify').prop('checked'),
                notify_max: "-1",
                notify_current: "0",
                auto_summarize: $('#bm_settings_summarize').prop('checked'),
                email: encodeURI(email),
            }
            $.ajax({
                url: $('#bm_settings_save').attr('href')+'/.json',
                type: "put",
                data: data,
                success: function(d, stat, xhr) {
                    showDialog(
                    {
                        title: 'Settings Updated',
                        line1: 'Settings were updated successfully',
                        line2: ''
                    }, true)
                },
                error: function(xhr, stat, err) {
                    var err = JSON.parse(xhr.responseText)
                    displayEmailError(err.err_msg.join(""))
                    
                },
                beforeSend: function(xhr, settings) {
                    xhr.setRequestHeader("X-CSRFToken", getCookie('csrftoken'))
                },
            });
        }
    })
}

function setupSocial() {
    $('[id^=bm_prov_').unbind('click').click(function() {
        var id = getId(this.id)
        var name = $(this).attr('name')
        showSocialInfo(id, name)
    })
}

function setupRemove() {
    var rem = $('#bm_settings_remove')
    if ($(rem).length > 0) {
        $(rem).unbind('click').click(function(e) {
            e.preventDefault()
            showConfirmModal({
                title: 'Account Removal',
                line1: 'This action will queue your account for deletion.<br/>Actual removal will take place after 48 hours.',
                line2: 'All your Bookmarks, Reminders, and Summaries will be deleted.<br/>'+
                       'If you change your mind, you can come back to Settings page and Cancel Deletion.<br/>'+
                       '<b>Do you want to proceed?</b>',
                callback: function() {
                    var del_on = localToUtc(addHours(new Date(),48).toString())
                    $.ajax({
                        url: $(rem).attr('href')+'/.json',
                        type: "put",
                        data: { del_pending: true,
                                del_on:  del_on },
                        success: function(d, stat, xhr) {
                            showDialog(
                            {
                                title: 'Account Removal',
                                line1: 'Account Removal request submitted.',
                                line2: 'This account will be removed after 48 hours.'
                            }, true)
                        },
                        error: function(xhr, stat, err) {
                            showDialog(
                            {
                                title: 'Account Removal',
                                line1: 'Account Removal request could not be submitted. Please try again or contact support.',
                                line2: '('+err+') '+stat
                            }, true)
                            
                        },
                        beforeSend: function(xhr, settings) {
                            xhr.setRequestHeader("X-CSRFToken", getCookie('csrftoken'))
                        },
                    });
                }

            })
        })
    } else {
        rem = $('#bm_settings_cancel_remove')
        $(rem).unbind('click').click(function(e) {
            e.preventDefault()
            showConfirmModal({
                title: 'Cancel Remove Account',
                line1: 'Proceed to Cancel Account Delete?',
                callback: function() {
                    $.ajax({
                        url: $(rem).attr('href')+'/.json',
                        type: "put",
                        data: { del_pending: false,
                                del_on:  '1970-01-01 00:00:00'},
                        success: function(d, stat, xhr) {
                            showDialog(
                            {
                                title: 'Cancel Account Removal',
                                line1: 'Account Removal Cancelled.',
                                line2: ''
                            }, true)
                        },
                        error: function(xhr, stat, err) {
                            showDialog(
                            {
                                title: 'Cancel Account Removal',
                                line1: 'Account Removal could not be Cancelled. Please try again or contact support.',
                                line2: '('+err+') '+stat
                            }, true)
                        },
                        beforeSend: function(xhr, settings) {
                            xhr.setRequestHeader("X-CSRFToken", getCookie('csrftoken'))
                        },
                    });
                }

            })
        })
    }
}

function showSocialInfo(id, name) {
    $('#bm_social_info_title').text('Social Account: '+name)
    $('#bm_social_info').show()
    $('#bm_ajax_loader').hide()
    $('#bm_social_info_body_text').hide()
    $('#bm_social_info_cancel').unbind('click').click(function() {
        $('#bm_social_info').hide()
    })
    $('#bm_social_info_disconnect').unbind('click').click(function() {
        $('#bm_social_info').hide()
    })

    var extra = 'Other Basic Info: '
    if (name == 'Facebook') {
        $('#bm_social_info_basic_extra').text(extra+'Friends List, Information you choose to share')
    } else if (name == 'Google+') {
        $('#bm_social_info_basic_extra').text(extra+'None')
    }

    $('#bm_ajax_loader').show()
    $.ajax({
        url: base_url+'social/'+id+"/.json",
        type: "get",
        success: function(d, stat, xhr) {
            var email = 'Email: '
            var json = JSON.parse(d[0].extra_data)
            $('#bm_social_info_email').html(email+'<b>'+json.email+'</b>')
            $('#bm_social_info_body_text').show()
            $('#bm_ajax_loader').hide()
        },
        error: function(xhr, stat, err) {
            $('#bm_ajax_loader').hide()
        }
    })

    var unlink = $('#bm_social_info_disconnect')
    if (unlink) {
        $(unlink).unbind('click').click(function() {
                showConfirmModal({
                title: 'Disconnect '+name+' Account',
                line1: 'This will unlink your YABA and '+ name +' Account. Proceed?',
                line2: "<b>Note: This action will NOT revoke YABA's permissions in your "+name+" account</b>",
                callback : function() {
                    $.ajax({
                        url: base_url+'accounts/social/connections/',
                        type: 'post',
                        data: {account: id},
                        success: function(d, stat, xhr) {
                            showDialog({
                                title: 'Social Account Disconnected',
                                line1: name+' Account disconnected successfully'
                            },true)
                        },
                        error: function(xhr, stat, err) {
                            showDialog({
                                title: 'Social Account Disconnection failed',
                                line1: name+' Account could not be disconnected',
                                line2: '('+err+') '+stat
                            })
                        },
                        beforeSend: function(xhr, settings) {
                            xhr.setRequestHeader("X-CSRFToken", getCookie('csrftoken'))
                        },
                    })
                }
            })
        })
    }
}

function displayEmailError(msg) {
    var email_input_group = $('#bm_email_input_group')
    var email_verified_span = $('#bm_email_verified_span')
    $(email_input_group).addClass('has-error')
    if (email_verified_span) {
        $(email_verified_span).addClass('glyphicon-remove')
    }
    $(email_input_group).tooltip({title: msg}).tooltip('show')    
}

function showDialog(msg, reload) {
    $('#resultTitle').text(msg.title)
    $('#resultTextLine1').text(msg.line1)
    $('#resultTextLine2').text(msg.line2)
    $('#result').modal('show')
    $('#result').unbind('hidden.bs.modal').on('hidden.bs.modal', function() {
        if (reload) location.reload()
    })
}

function assert(condition, message) {
    if (!condition) throw message || "Assertion Failure"
}

function getId(targetId) {
    assert (targetId != null, "getId: Id is null");
    var id = /^.*?_(\d+)$/.exec(targetId);
    if (id != null) {
        return id[1]
    }
    return null
}

function showConfirmModal(config, reload) {
    $('#confirmTitle').text(config.title)
    $('#confirmTextLine1').html(config.line1)
    $('#confirmTextLine2').html(config.line2)
    $('#confirmOk').unbind('click').click(function() {
        config.callback()
        //$('#confirm').modal('hide')
        if (reload) {
            location.reload()
        }
    })
    $('#confirm').modal('show')
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

function addHours(date, hours) {
    return new Date(date.getFullYear(),date.getMonth(),date.getDate(),date.getHours()+hours,date.getMinutes(),date.getSeconds())
}