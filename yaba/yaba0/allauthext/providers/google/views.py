import logging
import requests

from allauth.socialaccount.models import (SocialLogin,
                                          SocialToken)
from allauth.socialaccount.helpers import complete_social_login
from allauth.socialaccount.helpers import render_authentication_error

from allauth.socialaccount import providers
from allauth.socialaccount.providers.google.provider import GoogleProvider

from .forms import GoogleConnectForm

logger = logging.getLogger('yaba.yaba0.allauthext.providers.google.provider.views')

def gl_complete_login(request, app, token, **kwargs):
    profile_url = 'https://www.googleapis.com/oauth2/v1/userinfo'
    resp = requests.get(profile_url,
                        params={'access_token': token.token,
                                'alt': 'json'})
    extra_data = resp.json()
    login = providers.registry \
        .by_id(GoogleProvider.id) \
        .sociallogin_from_response(request, extra_data)
    return login

def login_by_token(request):
    logger.info('login_by_token')
    ret = None
    if request.method == 'POST':
        form = GoogleConnectForm(request.POST)
        if form.is_valid():
            try:
                provider = providers.registry.by_id(GoogleProvider.id)
                app = providers.registry.by_id(GoogleProvider.id) \
                    .get_app(request)
                access_token = form.cleaned_data['access_token']
                logger.info('login_by_token: access_token={}'.format(access_token))
                token = SocialToken(app=app,
                                    token=access_token)
                login = gl_complete_login(request, app, token)
                login.token = token
                login.state = SocialLogin.state_from_request(request)
                ret = complete_social_login(request, login)
            except requests.RequestException:
                logger.exception('Error accessing Google user profile')
    if not ret:
        ret = render_authentication_error(request)
    return ret