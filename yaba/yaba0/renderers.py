from rest_framework.renderers import BrowsableAPIRenderer, JSONRenderer
from django.conf import settings
from yaba0 import VERSION
from json import loads

class YabaBrowsableAPIRenderer(BrowsableAPIRenderer):
    template = 'yaba0/bm.html'

    def get_context(self, data, accepted_media_type, renderer_context):
        context = super(YabaBrowsableAPIRenderer, self).get_context(data,accepted_media_type,renderer_context)
        context['version'] = VERSION
        content = context['content']
        content_json = loads(content)

        # Check if output is paged
        if ('count' in content_json):
            #print('content_json: %s'%content_json)
            context['content_native']=content_json['results']
            context['bm_count']=content_json['count']
            context['paged']=True
            context['next_page']=content_json['next'] if content_json['next'] else ''
            context['prev_page']=content_json['previous'] if content_json['previous'] else ''
        elif ('detail' in content_json):
            if (content_json['detail']=='Not found'):
                context['content_native']=[]
        else:
            context['content_native']=content_json

        return context

class UserProfileRenderer(BrowsableAPIRenderer):
    template = 'yaba0/settings.html'

    def get_context(self, data, accepted_media_type, renderer_context):
        context = super(UserProfileRenderer, self).get_context(data,accepted_media_type,renderer_context)
        context['version'] = VERSION
        content = context['content']
        content_json = loads(content)
        #print('context=%s'%context['content'])

        if ('detail' in content_json):
            if (content_json['detail']=='Not found'):
                context['content_native']=[]
        else:
            context['content_native']=content_json

        return context

class SocialAccountRenderer(JSONRenderer):

    def render(self, data, accepted_media_type=None, renderer_context=None):
        renderer_context = renderer_context or {}
        data = data or []
        if (len(data) > 0):
            data[0]['permissions'] = settings.SOCIALACCOUNT_PROVIDERS[data[0]['provider']]['SCOPE']
        context = super(SocialAccountRenderer, self).render(data, accepted_media_type, renderer_context)
        return context
