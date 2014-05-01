from requests import get,exceptions
from summarize import summarize_page_soup
from bs4 import BeautifulSoup
import re
import logging
from yaba.settings import URL_CONNECT_TIMEOUT

logger = logging.getLogger('yaba.yaba0.document')

class Document(object):

    meta_attr_map = {
        'title':          u'og:title',
        'image_url':      u'og:image',
        'description':    u'og:description',
        'site':           u'og:site_name',
        'doctype':        u'og:type',
        'locale':         u'og:locale',
        'lang':           u'DC.language',
        'publisher':      u'DC.publisher'
    }

    def __init__(self, url):
        self.url=url
        self.loaded=False
        self.__metas=None
        self.__summary=None
        self.__lang=None

    def __load_document(self):
        try:
            req = get(self.url, timeout=URL_CONNECT_TIMEOUT)
            req.encoding = 'utf-8'
            self.__html = req.text
            self.__soup = BeautifulSoup(self.__html)
            self.loaded = True
            self.__get_meta_info()
        except exceptions.Timeout:
            logger.error('Connection Timeout with url: {}'.format(self.url))
            pass
        except exceptions.RequestException:
            logger.error('RequestException with url: {}'.format(self.url))
            pass

    def __get_meta_info(self):
        if (not self.loaded):
            self.__load_document()

        if (self.__metas == None):
            field=u'property'
            og_tags = self.__soup('meta',property=re.compile('og:'))
            if (len(og_tags)==0):
                field=u'name'
                og_tags=self.__soup('meta',attrs={'name': re.compile('og:')})
            self.__metas={}
            for og in [m.attrs for m in og_tags]:
                self.__metas[og[field]]=og.get(u'content','')

            name_tags=self.__soup('meta', attrs={'name': re.compile('.*')})
            for name in [n.attrs for n in name_tags]:
                self.__metas[name[u'name']]=name.get(u'content','')

    def __get_meta_attr(self,name):
        self.__get_meta_info()
        return self.__metas.get(name,'')

    def load(self):
        self.__load_document()
        return self

    def title(self):
        return self.__get_meta_attr(Document.meta_attr_map['title'])

    def image_url(self):
        return self.__get_meta_attr(Document.meta_attr_map['image_url'])

    def doctype(self):
        return self.__get_meta_attr(Document.meta_attr_map['doctype']).lower()

    def description(self):
        return self.__get_meta_attr(Document.meta_attr_map['description']).strip()

    def locale(self):
        return self.__get_meta_attr(Document.meta_attr_map['locale']).lower()

    def site(self):
        return self.__get_meta_attr(Document.meta_attr_map['site'])

    def lang(self):

        if (self.__lang == None):
            self.__lang = ''
            self.__lang = self.__get_meta_attr(Document.meta_attr_map['lang']).lower()
            if (self.__lang != ''):
                return self.__lang

            lang = self.__soup.find_all(lang=re.compile('.*'))
            for lang_dict in [ll.attrs for ll in lang]:
                if (u'lang' in lang_dict.keys()):
                    self.__lang = lang_dict[u'lang'].lower()[0:2]
                    break
        return self.__lang

    def publisher(self):
        return self.__get_meta_attr(Document.meta_attr_map['publisher'])

    def summary(self):
        if (self.__summary==None):
            self.__load_document()

            self.__summary=str(summarize_page_soup(self.__soup)).strip()

        return self.__summary






