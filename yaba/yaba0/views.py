from yaba0.models import BookMark, UserProfile
from yaba0.serializers import BmSerializer, UserSerializer, UserProfileSerializer
from rest_framework import generics
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from rest_framework import permissions
from rest_framework.renderers import JSONRenderer
from yaba0.permissions import IsOwner
from yaba0.renderers import YabaBrowsableAPIRenderer, UserProfileRenderer, SocialAccountRenderer
from yaba0.paginators import BmPaginator
from yaba0.document import Document
import utils
from allauth.socialaccount.models import SocialAccount
from django.views.generic import TemplateView
from yaba0 import VERSION

class BookmarksList(generics.ListCreateAPIView):
    renderer_classes = (YabaBrowsableAPIRenderer,JSONRenderer)
    serializer_class = BmSerializer
    permission_classes = (permissions.IsAuthenticated,)
    paginator_class = BmPaginator

    def get_queryset(self):
        user = self.request.user
        query_param="q"

        query_string = self.request.GET.get(query_param,"").strip()

        if not query_string:
            return BookMark.objects.filter(user=user)

        return utils.search(self.request, BookMark, ['tags','name'])

    def pre_save(self, obj):
        obj.user = self.request.user

        try:
            other = BookMark.objects.get(user=obj.user,url=obj.url)
            obj.id = other.id
            obj.added = other.added
            obj.description = other.description
            obj.image_url = other.image_url
            obj.tags = other.tags
            obj.has_notify = other.has_notify
            obj.notify_on = other.notify_on
        except BookMark.DoesNotExist:
            self.set_obj_attrs(obj)

    def get_paginate_by(self, queryset=None):
        profile = UserProfile.objects.filter(user=self.request.user)
        if (len(profile) > 0):
            if (profile[0].paginate_by == 0):
                return None
            return profile[0].paginate_by
        else:
            return self.paginate_by

    def set_obj_attrs(self, obj):
        profile = UserProfile.objects.filter(user=self.request.user)[0]
        doc = Document(obj.url).load()
        if (doc.loaded):
            obj.image_url = doc.image_url()
            tags = ', '.join([doc.doctype(),doc.site()])
            if (tags.strip() != ','):
                obj.tags = tags

            if (profile.auto_summarize):
                if (doc.doctype() == 'article' and doc.lang() == 'en'):
                    summary = doc.summary()
                    obj.description = summary if (summary and len(summary) > 10) else doc.description()
                else:
                    obj.description = doc.description()
            else:
                obj.description = doc.description()

class BookmarksSearch(generics.ListAPIView):
    renderer_classes = (YabaBrowsableAPIRenderer,JSONRenderer)
    serializer_class = BmSerializer
    permission_classes = (permissions.IsAuthenticated,)
    paginator_class = BmPaginator

    def get_queryset(self):
        user = self.request.user
        return utils.search(self.request, BookMark, ['tags','name'])

class BookmarkDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = BookMark.objects.all()
    serializer_class = BmSerializer
    permission_classes = (permissions.IsAuthenticated,IsOwner,)
    renderer_classes = (YabaBrowsableAPIRenderer,JSONRenderer)

    def pre_save(self, obj):
        obj.user = self.request.user

        bm = BookMark.objects.filter(id=obj.id)
        if len(bm) > 0:
            old_has_notify = bm[0].has_notify
            if (obj.has_notify and not old_has_notify):
                profile = UserProfile.objects.filter(user=obj.user)[0]
                if (profile.notify_current < profile.notify_max):
                    profile.notify_current = profile.notify_current + 1
                    profile.save(update_fields=['notify_current'])
                else:
                    raise ValidationError({'err_msg' : 'Reminder Limit has reached'})
            elif (not obj.has_notify and old_has_notify):
                profile = UserProfile.objects.filter(user=obj.user)[0]
                if (profile.notify_current > 0):
                    profile.notify_current = profile.notify_current - 1
                    profile.save(update_fields=['notify_current'])


class UserProfileList(generics.RetrieveUpdateAPIView):
    #queryset = UserProfile.objects.all()
    model = UserProfile
    renderer_classes = (UserProfileRenderer,JSONRenderer)
    permission_classes = (permissions.IsAuthenticated,IsOwner,)
    serializer_class = UserProfileSerializer

    def get_queryset(self):
        return self.model.objects.filter(user=self.request.user)
        
    def pre_save(self, obj):
        obj.user = self.request.user

        #print('obj.del_pending={}, obj.del_on={}, obj.updated={}'.format(obj.del_pending,obj.del_on,obj.updated))
        user_obj = User.objects.filter(username=self.request.user)[0]
        user_email = user_obj.email
        req_email = self.request.DATA.get('email', None)
        if (req_email and len(req_email) > 0 and req_email != user_email):
            if (User.objects.filter(email=req_email).exists()):
                raise ValidationError({'err_msg': 'Email address is already in use'})
            else:
                user_obj.email = req_email
                user_obj.save(update_fields=['email'])

class SocialAccountDetail(generics.ListAPIView):
    model = SocialAccount
    permission_classes = (permissions.IsAuthenticated,)
    renderer_classes = [SocialAccountRenderer,]

    def get_queryset(self):
        return self.model.objects.filter(user=self.request.user, id=self.kwargs['pk'])

class AboutView(TemplateView):
    template_name = "yaba0/about.html"

    def get_context_data(self, **kwargs):
        context = super(AboutView, self).get_context_data(**kwargs)
        context['version'] = VERSION
        return context

