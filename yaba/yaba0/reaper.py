from yaba0.models import BookMark, UserProfile
from django.contrib.auth.models import User
from datetime import datetime
import logging
from django.utils.timezone import utc

logger = logging.getLogger('yaba.yaba0.reaper')

def remove_accounts():
    del_users = UserProfile.objects.filter(del_pending=True, del_on__lte=datetime.utcnow().replace(tzinfo=utc))

    logger.info('Found {} Users to be deleted'.format(len(del_users)))

    for du in del_users:
        user = du.user
        name = user.username
        user.delete()
        logger.info('User {} deleted!!!'.format(name))
