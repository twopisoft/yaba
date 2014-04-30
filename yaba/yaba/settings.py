# Django settings for yaba project.

import os
import logging
import dj_database_url

BASE_DIR = os.path.dirname(os.path.dirname(__file__))

DEBUG = True
TEMPLATE_DEBUG = DEBUG

ADMINS = (
    # ('Your Name', 'your_email@example.com'),
)

MANAGERS = ADMINS

#SECRET_KEY='6bz%#sk#+3@3787-oyx_v_aes3arsedk!&ntk8!$%ep_w#k0&^yaba'

'''
DATABASES = {
    'default': {
        #'ENGINE': 'django_mongodb_engine', # Add 'postgresql_psycopg2', 'mysql', 'sqlite3' or 'oracle'.
        #'NAME': 'yaba0',                      # Or path to database file if using sqlite3.
        # The following settings are not used with sqlite3:
        #'USER': 'admin',
        #'PASSWORD': 'abc123456',
        #'HOST': '',                      # Empty for localhost through domain sockets or '127.0.0.1' for localhost through TCP.
        #'PORT': '',                      # Set to empty string for default.
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    }
}
'''

DEFAULT_DB_NAME='getyaba-staging'
DBS = {
    'getyaba-staging': dj_database_url.config(),
    'local': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'yaba0',                      
        'USER': 'admin',
        'PASSWORD': 'abc123456',
        'HOST': ''
    }
}

DATABASES = {
    'default': DBS[DEFAULT_DB_NAME]
}

#AUTH_USER_MODEL=auth.User

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

#LOGIN_URL='yaba0/api'
#LOGIN_REDIRECT_URL = '/yaba0/api'
LOGIN_URL='/'
LOGIN_REDIRECT_URL = '/'
SOCIALACCOUNT_QUERY_EMAIL = True
SOCIALACCOUNT_EMAIL_REQUIRED = True
SOCIALACCOUNT_ENABLED = True
ACCOUNT_LOGIN_ON_EMAIL_CONFIRMATION = False
ACCOUNT_EMAIL_SUBJECT_PREFIX = '[YABA] - '
#SOCIALACCOUNT_EMAIL_VERIFICATION = 'mandatory'
#ACCOUNT_EMAIL_VERIFICATION = 'mandatory'
#ACCOUNT_UNIQUE_EMAIL=False

SOCIALACCOUNT_PROVIDERS = {
    'facebook': {
        'SCOPE': ['email'],
        'METHOD': 'oauth2'  
    },
    'google': { 
        'SCOPE': ['profile','email'],
        'AUTH_PARAMS': { 'access_type': 'online' } 
    }
}

if (DEFAULT_DB_NAME=='getyaba-staging'):
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    EMAIL_HOST = 'smtp.mandrillapp.com'
    EMAIL_PORT = 587
    EMAIL_HOST_USER = 'app23916433@heroku.com'
    EMAIL_HOST_PASSWORD = 'hiYYCSEAtFDqwr-xttZ9Pg'
    DEFAULT_FROM_EMAIL = 'admin@getyaba.com'
else:
    EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

REMINDER_FROM_EMAIL = 'yaba-reminders@getyaba.com'
REMINDER_SUBJECT_EMAIL = '[YABA] - Reminder from YABA'

# Hosts/domain names that are valid for this site; required if DEBUG is False
# See https://docs.djangoproject.com/en/1.5/ref/settings/#allowed-hosts
ALLOWED_HOSTS = ['*']

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# In a Windows environment this must be set to your system time zone.
TIME_ZONE = 'UTC'

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'en-us'

#SITE_ID = u'53352117990ef01cb2c0af08' 
SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True

# If you set this to False, Django will not format dates, numbers and
# calendars according to the current locale.
USE_L10N = True

# If you set this to False, Django will not use timezone-aware datetimes.
USE_TZ = True

# Absolute filesystem path to the directory that will hold user-uploaded files.
# Example: "/var/www/example.com/media/"
MEDIA_ROOT = ''

# URL that handles the media served from MEDIA_ROOT. Make sure to use a
# trailing slash.
# Examples: "http://example.com/media/", "http://media.example.com/"
MEDIA_URL = ''

# Absolute path to the directory static files should be collected to.
# Don't put anything in this directory yourself; store your static files
# in apps' "static/" subdirectories and in STATICFILES_DIRS.
# Example: "/var/www/example.com/static/"
STATIC_ROOT = 'staticfiles'

# URL prefix for static files.
# Example: "http://example.com/static/", "http://static.example.com/"
STATIC_URL = '/static/'

# Additional locations of static files
STATICFILES_DIRS = (
    # Put strings here, like "/home/html/static" or "C:/www/django/static".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
    os.path.join(BASE_DIR, 'static'),
)

# List of finder classes that know how to find static files in
# various locations.
STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
#    'django.contrib.staticfiles.finders.DefaultStorageFinder',
)

# Make this unique, and don't share it with anybody.
SECRET_KEY = 'e=8b6@jxl6kcpgk8m8v)o7(^o4ipqn2w+s8owz41@hb8br7&8s'

# List of callables that know how to import templates from various sources.
TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
    'django.template.loaders.eggs.Loader',
)

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    # Uncomment the next line for simple clickjacking protection:
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

ROOT_URLCONF = 'yaba.urls'

# Python dotted path to the WSGI application used by Django's runserver.
WSGI_APPLICATION = 'yaba.wsgi.application'

TEMPLATE_DIRS = (
    # Put strings here, like "/home/html/django_templates" or "C:/www/django/templates".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
)

TEMPLATE_CONTEXT_PROCESSORS = (
    # Required by allauth template tags
    "django.core.context_processors.request",

    # allauth specific context processors
    "allauth.account.context_processors.account",
    "allauth.socialaccount.context_processors.socialaccount",

    "django.contrib.auth.context_processors.auth",
)

AUTHENTICATION_BACKENDS = (
    # Needed to login by username in Django admin, regardless of `allauth`
    "django.contrib.auth.backends.ModelBackend",

    # `allauth` specific authentication methods, such as login by e-mail
    "allauth.account.auth_backends.AuthenticationBackend",
)

REST_FRAMEWORK = {
    #'PAGINATE_BY': 10,                 # Default to 10
    #'MAX_PAGINATE_BY': 100             # Maximum limit allowed when using `?page_size=xxx`.
}

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'yaba0',

    'allauth',
    'allauth.account',
    'allauth.socialaccount',
    'allauth.socialaccount.providers.facebook',
    'allauth.socialaccount.providers.google',

    # Uncomment the next line to enable the admin:
    'django.contrib.admin',
    # Uncomment the next line to enable admin documentation:
    'django.contrib.admindocs',
    #'djangotoolbox',
    'rest_framework',
    'south',
)

SESSION_SERIALIZER = 'django.contrib.sessions.serializers.JSONSerializer'

# A sample logging configuration. The only tangible logging
# performed by this configuration is to send an email to
# the site admins on every HTTP 500 error when DEBUG=False.
# See http://docs.djangoproject.com/en/dev/topics/logging for
# more details on how to customize your logging configuration.
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse'
        }
    },
    'formatters':{
        'verbose': {
            'format': '%(levelname)s %(asctime)s %(name)s.%(funcName)s: %(message)s'
        },
    },
    'handlers': {
        'mail_admins': {
            'level': 'ERROR',
            'filters': ['require_debug_false'],
            'class': 'django.utils.log.AdminEmailHandler'
        },
        'console': {
            'level': 'ERROR',
            'class': 'logging.StreamHandler'
        },
        'yaba_console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose'
        }
    },
    'loggers': {
        'django.request': {
            'handlers': ['mail_admins', 'console'],
            'level': 'ERROR',
            'propagate': True,
        },
        'django': {
            'handlers' : ['console'],
            'level': 'ERROR'
        },
        'yaba': {
            'handlers' : ['yaba_console'],
            'level' : 'ERROR',
            'propagate' : True
        }
    }
}
