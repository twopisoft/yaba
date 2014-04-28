from django.forms import widgets
from rest_framework import serializers
from django.contrib.auth.models import User
from .models import BookMark, UserProfile

class BmSerializer(serializers.Serializer):
    id = serializers.Field()
    added = serializers.DateTimeField()
    updated = serializers.DateTimeField()
    name = serializers.CharField(max_length=200)
    url = serializers.CharField(max_length=1024)
    image_url = serializers.CharField(max_length=1024, required=False)
    description = serializers.CharField(max_length=10000, required=False)
    has_notify = serializers.BooleanField()
    notify_on = serializers.DateTimeField(required=False)
    tags = serializers.CharField(max_length=10000, required=False)
    user = serializers.Field(source='user.username')

    def restore_object(self, attrs, instance=None):
        if instance is not None:
            for k, v in attrs.iteritems():
                setattr(instance, k, v)
            return instance

        return BookMark(**attrs)

    def save_object(self, obj, **kwargs):
        obj.save()

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ('paginate_by','email_notify','push_notify','auto_summarize','del_pending','del_on')
        
class UserSerializer(serializers.ModelSerializer):
    bm = serializers.PrimaryKeyRelatedField(many=True)

    #def get_default_fields(self):
        #print("get_default_fields")
        #super(UserSerializer, self).get_default_fields()

    class Meta:
        model = User
        #fields = ('id', 'username', 'email', 'bm')

