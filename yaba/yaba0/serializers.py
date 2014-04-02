from django.forms import widgets
from rest_framework import serializers
from django.contrib.auth.models import User
from .models import BookMark

class BmSerializer(serializers.Serializer):
    id = serializers.Field()
    added = serializers.DateTimeField()
    updated = serializers.DateTimeField()
    name = serializers.CharField(max_length=200)
    url = serializers.URLField(max_length=400)
    description = serializers.CharField(max_length=10000, required=False)
    has_notify = serializers.BooleanField()
    notify_on = serializers.DateTimeField(required=False)
    tags = serializers.CharField(max_length=10000, required=False)
    owner = serializers.Field(source='owner.username')

    def restore_object(self, attrs, instance=None):
        if instance is not None:
            for k, v in attrs.iteritems():
                print("k=%s, v=%s"%(k,v))
                setattr(instance, k, v)
            return instance
        return BookMark(**attrs)

class UserSerializer(serializers.ModelSerializer):
    bm = serializers.PrimaryKeyRelatedField(many=True)

    #def get_default_fields(self):
        #print("get_default_fields")
        #super(UserSerializer, self).get_default_fields()

    class Meta:
        model = User
        #fields = ('id', 'username', 'email', 'bm')

