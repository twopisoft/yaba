from yaba0.models import BookMark
from yaba0.serializers import BmSerializer, UserSerializer
from rest_framework import generics
from django.contrib.auth.models import User
from rest_framework import permissions
from rest_framework.renderers import JSONRenderer
from yaba0.permissions import IsOwner
from yaba0.renderers import YabaBrowsableAPIRenderer
from yaba0.paginators import BmPaginator
from yaba0.document import Document
import utils

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
            return BookMark.objects.filter(owner=user)

        return utils.search(self.request, BookMark, ['tags','name'])

    def pre_save(self, obj):
        obj.owner = self.request.user

        try:
            other = BookMark.objects.get(owner=obj.owner,url=obj.url)
            obj.id = other.id
            obj.added = other.added
            obj.description = other.description
            obj.image_url = other.image_url
            obj.tags = other.tags
            obj.has_notify = other.has_notify
            obj.notify_on = other.notify_on
        except BookMark.DoesNotExist:
            self.set_obj_attrs(obj)

    def set_obj_attrs(self, obj):
        doc = Document(obj.url).load()
        if (doc.loaded):
            obj.image_url = doc.image_url()
            tags = ', '.join([doc.doctype(),doc.site()])
            if (tags.strip() != ','):
                obj.tags = tags

            if (doc.doctype() == 'article' and doc.lang() == 'en'):
                summary = doc.summary()
                obj.description = summary if (summary and len(summary) > 10) else doc.description()
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
        obj.owner = self.request.user


class UserList(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class UserDetail(generics.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

