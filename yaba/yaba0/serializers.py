from django.forms import widgets
from rest_framework import serializers
from django.contrib.auth.models import User
from .models import BookMark

class BmSerializer(serializers.Serializer):
    id = serializers.Field()
    added = serializers.DateTimeField()
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
                setattr(instance, k, v)
            return instance
        return BookMark(**attrs)

class UserSerializer(serializers.ModelSerializer):
    bm = serializers.PrimaryKeyRelatedField(many=True)

    class Meta:
        model = User
        fields = ('id', 'username', 'bm')

