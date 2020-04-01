import configparser
config = configparser.ConfigParser()
config.read('/etc/publik.conf')

def get_var(key):
    if config.has_option('publik', key):
        return config.get('publik', key)
    return None

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True
CSRF_COOKIE_SECURE = False
SESSION_COOKIE_SECURE = False

ADMINS = (
    ('Admins', 'admin@localhost'),
)

#ADMINS = (
#        # ('User 1', 'watchdog@example.net'),
#        # ('User 2', 'janitor@example.net'),
#)

try:
    DATABASES['default']['USER'] = get_var('DB_USERNAME')
    DATABASES['default']['PASSWORD'] = get_var('DB_PASSWORD')
    DATABASES['default']['HOST'] = get_var('DB_HOST')
    DATABASES['default']['PORT'] = get_var('DB_PORT')
except:
    pass

# ALLOWED_HOSTS must be correct in production!
# See https://docs.djangoproject.com/en/dev/ref/settings/#allowed-hosts
ALLOWED_HOSTS = [
        '*',
]

LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'

EMAIL_HOST = 'maildev'
EMAIL_HOST_USER = ''
EMAIL_HOST_PASSWORD = ''
EMAIL_PORT = 25

# Email configuration
EMAIL_SUBJECT_PREFIX = '[publik] '
SERVER_EMAIL = 'noreply@localhost'
DEFAULT_FROM_EMAIL = 'noreply@localhost'

# Caches
CACHES = {
    'default': {
        'BACKEND': 'hobo.multitenant.cache.TenantCache',
        'REAL_BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': 'memcached:11211',
    }
}

# Rabbitmq
BROKER_URL = 'amqp://guest:guest@rabbitmq:5672/'

# Proxy
import os
