import configparser
config = configparser.ConfigParser()
config.read('/etc/publik.conf')

def get_var(key):
    return config.get('publik', key)

# LDAP_AUTH_SETTINGS= [
# ]
