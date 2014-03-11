from django.db import models
from yaba import settings
from djangotoolbox.fields import ListField

# Create your models here.

class BookMark(models.Model):
    added = models.DateTimeField(auto_now_add=True)
    name = models.CharField(max_length=200, blank=True, default='')
    url = models.URLField(max_length=400)
    description = models.TextField(blank=True, default='')
    has_notify = models.BooleanField(default=False)
    notify_on = models.DateTimeField(blank=True, null=True)
    tags = models.TextField(blank=True, default='')
    owner = models.ForeignKey('auth.User', related_name='bm')

    class Meta:
        ordering = ('added',)
