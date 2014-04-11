from yaba0.models import BookMark
from yaba0.serializers import BmSerializer, UserSerializer
from rest_framework import generics
from django.contrib.auth.models import User
from rest_framework import permissions
from rest_framework.renderers import JSONRenderer
from yaba0.permissions import IsOwner
from yaba0.renderers import YabaBrowsableAPIRenderer
from yaba0.paginators import BmPaginator
from yaba0 import utils

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
            return BookMark.objects.filter(owner=user).order_by('-added')

        return utils.search(self.request, BookMark, ['tags','name']).order_by('-added')
        #return BookMark.objects.all()

    def pre_save(self, obj):
        obj.owner = self.request.user

        try:
            other = BookMark.objects.get(owner=obj.owner,url=obj.url)
            obj.id = other.id
            obj.added = other.added
            obj.description = other.description
            obj.tags = other.tags
            obj.has_notify = other.has_notify
            obj.notify_on = other.notify_on
        except BookMark.DoesNotExist:
            pass

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
        obj.owner = self.request.user


class UserList(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class UserDetail(generics.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

