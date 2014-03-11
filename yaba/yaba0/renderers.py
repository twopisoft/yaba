from rest_framework.renderers import BrowsableAPIRenderer
from yaba0 import VERSION
from json import loads

class YabaBrowsableAPIRenderer(BrowsableAPIRenderer):
    template = 'yaba0/bm.html'

    def get_context(self, data, accepted_media_type, renderer_context):
        context = super(YabaBrowsableAPIRenderer, self).get_context(data,accepted_media_type,renderer_context)
        context['version'] = VERSION
        content = context['content']
        #print ("content=%s" % content)
        context['content_native'] = loads(content)
        return context
