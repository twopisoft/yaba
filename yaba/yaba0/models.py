from django.db import models
from yaba import settings
from djangotoolbox.fields import ListField
from django.contrib.auth.models import User
from allauth.account.models import EmailAddress
from allauth.socialaccount.models import SocialAccount
import hashlib
from datetime import datetime

# Create your models here.

class BookMark(models.Model):
    added = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now_add=True)
    name = models.CharField(max_length=200, blank=True, default='', db_index=True)
    url = models.CharField(max_length=1024, blank=True)
    image_url = models.CharField(max_length=400, blank=True)
    description = models.TextField(blank=True, default='')
    has_notify = models.BooleanField(default=False)
    notify_on = models.DateTimeField(blank=True, null=True)
    tags = models.TextField(blank=True, default='', db_index=True)
    user = models.ForeignKey('auth.User', related_name='bm')

    class Meta:
        ordering = ('-added',)

from django.contrib.auth.models import User
from django.db import models

 
class UserProfile(models.Model):
    user = models.OneToOneField(User, related_name='profile')
    paginate_by = models.PositiveSmallIntegerField(default=10)
    email_notify = models.BooleanField(default=False)
    push_notify = models.BooleanField(default=False)
    notify_max = models.SmallIntegerField(default=5)
    notify_current = models.SmallIntegerField(default=0)
    auto_summarize = models.BooleanField(default=True)
    del_pending = models.BooleanField(default=False)
    del_on = models.DateTimeField(default='1970-01-01T0:0:0Z')
    updated = models.DateTimeField(default='1970-01-01T0:0:0Z')
 
    def __unicode__(self):
        return "{}'s profile".format(self.user.username)
 
    class Meta:
        db_table = 'user_profile'
 
    def account_verified(self):
        if self.user.is_authenticated:
            result = EmailAddress.objects.filter(email=self.user.email)
            if len(result):
                return result[0].verified
        return False

    def profile_image_url(self):
        profile = SocialAccount.objects.filter(user_id=self.user.id)
        #print("profile=%s"%profile[0].extra_data)
        if len(profile):
            provider = profile[0].provider
            if (provider == 'facebook'):
                return "https://graph.facebook.com/{}/picture?width=40&height=40".format(profile[0].uid)
            elif (provider == 'google'):
                return profile[0].extra_data['picture']
     
        return "http://www.gravatar.com/avatar/{}?s=40".format(hashlib.md5(self.user.email).hexdigest())

    def profile_fullname(self):
        profile = SocialAccount.objects.filter(user_id=self.user.id)

        if len(profile):
            return profile[0].extra_data['name']

        return ''

    def socialaccount_provider(self):
        profile = SocialAccount.objects.filter(user_id=self.user.id)

        ret = [{'name': p.provider.lower(), 'id': p.id} for p in profile]
        return sorted(ret, key=lambda x: x['name'])
 
User.profile = property(lambda u: UserProfile.objects.get_or_create(user=u)[0])


