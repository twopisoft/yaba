from yaba0.models import BookMark, UserProfile
from django.contrib.auth.models import User
from threading import Timer
from yaba.settings import REMINDER_FROM_EMAIL, REMINDER_SUBJECT_EMAIL
from datetime import datetime
from django.core.mail import send_mass_mail, BadHeaderError
import logging

logger = logging.getLogger('yaba.yaba0.reminders')

def find_reminders():
    bookmarks = BookMark.objects.filter(has_notify=True, notify_on__lte=datetime.utcnow()).order_by('user')
    uid = None
    reminders = {}
    user = None
    profile = None
    for bm in bookmarks:
        if (bm.user != uid):
            uid = bm.user
            user = User.objects.filter(username=uid)[0]
            profile = UserProfile.objects.filter(user=uid)[0]

        if (not profile.email_notify):
            continue


        user_entry = reminders.get(uid,(None,[]))
        (prof,bmlist) = user_entry
        bmlist.append(bm)
        prof = profile if (prof == None) else prof
        reminders[uid] = (prof,bmlist)

    return reminders

def send_reminders(reminders):
    messages = ()
    for user in reminders.keys():
        (_,bookmarks) = reminders[user]
        messages = messages + ((REMINDER_SUBJECT_EMAIL, get_message_text(user.username,bookmarks), REMINDER_FROM_EMAIL, [user.email]),)

    if (len(messages) > 0):
        try:
            send_mass_mail(messages)
        except BadHeaderError:
            logger.error('BadHeaderError while sending emails')

    reset_reminders(reminders)
    
def get_message_text(username,bookmarks):
    msg = ''
    n = len(bookmarks)
    words = ['is','reminder','Bookmark']
    if (n > 1):
        words = ['are','reminders','Bookmarks']
    if (n > 0):
        msg = "Hello,\n\nAs promised here {} the {} for the {} that you requested:\n\n".format(words[0],words[1],words[2])
        for i in range(n):
            msg += str(i+1) + '.\t' + bookmarks[i].name + '\n\t' + bookmarks[i].url + '\n\n'

    msg += '\nThank You for using YABA :)\n\n(N.B.: Do not reply to this email. If you have any questions, please contact YABA support at http://getyaba.com)'
    return msg

def reset_reminders(reminders):
    for (profile,bmlist) in reminders.values():
        for bm in bmlist:
            bm.has_notify=False
            bm.notify_on = '1970-01-01T00:00:00Z'
            bm.save()
            if (profile.notify_current > 0):
                profile.notify_current -= 1
        profile.save()


if __name__ == '__main__':
    send_reminders(find_reminders())




