from django.conf.urls import patterns, url, include
from rest_framework.urlpatterns import format_suffix_patterns
from yaba0 import views

urlpatterns = patterns('',
    url(r'^$', views.BookmarksList.as_view()),
    url(r'^(?P<pk>[0-9]+)/$', views.BookmarkDetail.as_view()),
    url(r'^userprofile/(?P<pk>[0-9]+)/$', views.UserProfileList.as_view()),
    #url(r'^yaba0/api/$', views.BookmarksList.as_view()),
    #url(r'^yaba0/api/(?P<pk>[A-Fa-f0-9]+)/$', views.BookmarkDetail.as_view()),
    #url(r'^yaba0/api/search/', views.BookmarksSearch.as_view()),
    #url(r'^users/$', views.UserList.as_view()),
    #url(r'^users/(?P<pk>[0-9]+)/$', views.UserDetail.as_view()),
)

urlpatterns = format_suffix_patterns(urlpatterns)
