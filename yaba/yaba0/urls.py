from django.conf.urls import patterns, url, include
from rest_framework.urlpatterns import format_suffix_patterns
from yaba0 import views

from django.views.decorators.csrf import csrf_exempt
from yaba0.allauthext.providers.google.views import login_by_token

urlpatterns = patterns('',
    url(r'^$', views.BookmarksList.as_view()),
    url(r'^about/$', views.AboutView.as_view()),
    url(r'^mobile/$', views.MobileView.as_view()),
    url(r'^(?P<pk>[0-9]+)/$', views.BookmarkDetail.as_view()),
    url(r'^userprofile/(?P<pk>[0-9]+)/$', views.UserProfileList.as_view()),
    url(r'^social/(?P<pk>[0-9]+)/$', views.SocialAccountDetail.as_view()),
    url(r'^allauthext/accounts/google/login/token/$',csrf_exempt(login_by_token)),
    #url(r'^yaba0/api/$', views.BookmarksList.as_view()),
    #url(r'^yaba0/api/(?P<pk>[A-Fa-f0-9]+)/$', views.BookmarkDetail.as_view()),
    #url(r'^yaba0/api/search/', views.BookmarksSearch.as_view()),
    #url(r'^users/$', views.UserList.as_view()),
    #url(r'^users/(?P<pk>[0-9]+)/$', views.UserDetail.as_view()),
)

urlpatterns = format_suffix_patterns(urlpatterns)
