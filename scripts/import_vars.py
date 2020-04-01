import os
import configparser

def import_vars(dest):
    config = configparser.ConfigParser()
    config.add_section('publik')

    variables = os.environ
    for key, variable in variables.items():
        config['publik'][key] = variable.replace('%', '%%')

    with open(dest, 'w') as configfile:
        config.write(configfile)        

if __name__ == "__main__":
    import_vars('/etc/publik.conf')
