# -*- coding: utf-8 -*-
from south.utils import datetime_utils as datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding model 'BookMark'
        db.create_table(u'yaba0_bookmark', (
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('added', self.gf('django.db.models.fields.DateTimeField')(auto_now_add=True, blank=True)),
            ('updated', self.gf('django.db.models.fields.DateTimeField')(auto_now_add=True, blank=True)),
            ('name', self.gf('django.db.models.fields.CharField')(default='', max_length=200, blank=True)),
            ('url', self.gf('django.db.models.fields.CharField')(max_length=1024, blank=True)),
            ('image_url', self.gf('django.db.models.fields.CharField')(max_length=400, blank=True)),
            ('description', self.gf('django.db.models.fields.TextField')(default='', blank=True)),
            ('has_notify', self.gf('django.db.models.fields.BooleanField')(default=False)),
            ('notify_on', self.gf('django.db.models.fields.DateTimeField')(null=True, blank=True)),
            ('tags', self.gf('django.db.models.fields.TextField')(default='', blank=True)),
            ('user', self.gf('django.db.models.fields.related.ForeignKey')(related_name='bm', to=orm['auth.User'])),
        ))
        db.send_create_signal(u'yaba0', ['BookMark'])

        # Adding model 'UserProfile'
        db.create_table('user_profile', (
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('user', self.gf('django.db.models.fields.related.OneToOneField')(related_name='profile', unique=True, to=orm['auth.User'])),
            ('paginate_by', self.gf('django.db.models.fields.PositiveSmallIntegerField')(default=10)),
            ('email_notify', self.gf('django.db.models.fields.BooleanField')(default=False)),
            ('push_notify', self.gf('django.db.models.fields.BooleanField')(default=False)),
            ('notify_max', self.gf('django.db.models.fields.SmallIntegerField')(default=5)),
            ('notify_current', self.gf('django.db.models.fields.SmallIntegerField')(default=0)),
            ('auto_summarize', self.gf('django.db.models.fields.BooleanField')(default=True)),
            ('del_pending', self.gf('django.db.models.fields.BooleanField')(default=False)),
            ('del_on', self.gf('django.db.models.fields.DateTimeField')(default='1970-01-01T0:0:0Z')),
            ('updated', self.gf('django.db.models.fields.DateTimeField')(default='1970-01-01T0:0:0Z')),
        ))
        db.send_create_signal(u'yaba0', ['UserProfile'])


    def backwards(self, orm):
        # Deleting model 'BookMark'
        db.delete_table(u'yaba0_bookmark')

        # Deleting model 'UserProfile'
        db.delete_table('user_profile')


    models = {
        u'auth.group': {
            'Meta': {'object_name': 'Group'},
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '80'}),
            'permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': u"orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'})
        },
        u'auth.permission': {
            'Meta': {'ordering': "(u'content_type__app_label', u'content_type__model', u'codename')", 'unique_together': "((u'content_type', u'codename'),)", 'object_name': 'Permission'},
            'codename': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'content_type': ('django.db.models.fields.related.ForeignKey', [], {'to': u"orm['contenttypes.ContentType']"}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'})
        },
        u'auth.user': {
            'Meta': {'object_name': 'User'},
            'date_joined': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'email': ('django.db.models.fields.EmailField', [], {'max_length': '75', 'blank': 'True'}),
            'first_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'groups': ('django.db.models.fields.related.ManyToManyField', [], {'symmetrical': 'False', 'related_name': "u'user_set'", 'blank': 'True', 'to': u"orm['auth.Group']"}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_active': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'is_staff': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'is_superuser': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'last_login': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'last_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'password': ('django.db.models.fields.CharField', [], {'max_length': '128'}),
            'user_permissions': ('django.db.models.fields.related.ManyToManyField', [], {'symmetrical': 'False', 'related_name': "u'user_set'", 'blank': 'True', 'to': u"orm['auth.Permission']"}),
            'username': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '30'})
        },
        u'contenttypes.contenttype': {
            'Meta': {'ordering': "('name',)", 'unique_together': "(('app_label', 'model'),)", 'object_name': 'ContentType', 'db_table': "'django_content_type'"},
            'app_label': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'model': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '100'})
        },
        u'yaba0.bookmark': {
            'Meta': {'ordering': "('-added',)", 'object_name': 'BookMark'},
            'added': ('django.db.models.fields.DateTimeField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            'description': ('django.db.models.fields.TextField', [], {'default': "''", 'blank': 'True'}),
            'has_notify': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'image_url': ('django.db.models.fields.CharField', [], {'max_length': '400', 'blank': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'default': "''", 'max_length': '200', 'blank': 'True'}),
            'notify_on': ('django.db.models.fields.DateTimeField', [], {'null': 'True', 'blank': 'True'}),
            'tags': ('django.db.models.fields.TextField', [], {'default': "''", 'blank': 'True'}),
            'updated': ('django.db.models.fields.DateTimeField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            'url': ('django.db.models.fields.CharField', [], {'max_length': '1024', 'blank': 'True'}),
            'user': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'bm'", 'to': u"orm['auth.User']"})
        },
        u'yaba0.userprofile': {
            'Meta': {'object_name': 'UserProfile', 'db_table': "'user_profile'"},
            'auto_summarize': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'del_on': ('django.db.models.fields.DateTimeField', [], {'default': "'1970-01-01T0:0:0Z'"}),
            'del_pending': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'email_notify': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'notify_current': ('django.db.models.fields.SmallIntegerField', [], {'default': '0'}),
            'notify_max': ('django.db.models.fields.SmallIntegerField', [], {'default': '5'}),
            'paginate_by': ('django.db.models.fields.PositiveSmallIntegerField', [], {'default': '10'}),
            'push_notify': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'updated': ('django.db.models.fields.DateTimeField', [], {'default': "'1970-01-01T0:0:0Z'"}),
            'user': ('django.db.models.fields.related.OneToOneField', [], {'related_name': "'profile'", 'unique': 'True', 'to': u"orm['auth.User']"})
        }
    }

    complete_apps = ['yaba0']