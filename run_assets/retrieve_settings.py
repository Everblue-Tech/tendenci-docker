import os
import boto3
import json
import socket

def settings_source():
    if "secret_id" in os.environ:
        get_secret()
    else:
        write_settings(os.environ)

def get_secret():
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager'
    )
    # try:
    secret = client.get_secret_value(
        SecretId=os.environ['secret_id']
        )
    secret_value = json.loads(secret['SecretString'])
    print("Secret Retrieved Successfully")
    with open('/etc/environment', 'r') as file:
        environment = file.read()
    environment = environment + "\ndb_host=" + secret_value['db_host']
    environment = environment + "\ndb_port=" + secret_value['db_port']
    environment = environment + "\ndb_user=" + secret_value['db_user']
    environment = environment + "\ndb_name=" + secret_value['db_name']
    environment = environment + "\ndb_password=" + secret_value['db_password']
    with open('/etc/environment', 'w') as file:
        file.write(environment)
    write_settings(secret_value)

def write_settings(settings):

    # Defining environment variables to look for
    env_vars = ['db_host','db_port','db_name','db_user','db_password','ec_host','SECRET_KEY','SITE_SETTINGS_KEY', \
        'cache_host','ALLOWED_HOSTS', 'allowed_hosts', 'SECRET_ID', 'INSTALLED_APPS',\
        'MIDDLEWARE', 'AUTHENTICATION_BACKENDS']
    new_settings = []
    new_tendenci_variables = []
    installed_apps = []
    middleware = []
    authentication_backends = []

    # Iterating through env_vars to see if they exist and if they do
    # add them to a list to iterate over. Secret first, then environment
    for item in env_vars:
        if item in settings:
            #print(item + " found in secret.")
            new_settings.append(item + "=" + settings[item])
        elif item in os.environ:
            #print(item + " found in environment.")
            new_settings.append(item + "=" + os.environ[item])
        else:
           ##print(item + " not found.")
           pass

    # Checking our new_settings list to see if they match needed variables
    # and making another list with the correct format to add to the settings file
    for line in new_settings:
        #print('Checking ' + line)
        if 'db_host=' in line:
            x = line.split("=")[1].strip()
            new_tendenci_variables.append("DATABASES['default']['HOST'] = '" + x + "'")
        elif 'db_port=' in line:
            x = line.split("=")[1].strip()
            new_tendenci_variables.append("DATABASES['default']['PORT'] = " + x)
        elif 'db_user=' in line:
            x = line.split("=")[1].strip()
            new_tendenci_variables.append("DATABASES['default']['USER'] = '" + x + "'")
        elif 'db_password=' in line:
            x = line.split("=")[1].strip()
            new_tendenci_variables.append("DATABASES['default']['PASSWORD'] = '" + x + "'")
        elif 'db_name=' in line:
            x = line.split("=")[1].strip()
            new_tendenci_variables.append("DATABASES['default']['NAME'] = '" + x + "'")
        elif 'cache_host=' in line:
            x = line.split("=")[1].strip()
            new_tendenci_variables.append("CACHES['default']['LOCATION'] = '" + x + "'")
        elif 'ec_host=' in line:
            x = line.split("=")[1].strip()
            new_tendenci_variables.append("CACHES['default']['LOCATION'] = '" + x + "'")
        elif 'SECRET_KEY' in line:
            x = settings['SECRET_KEY']
            new_tendenci_variables.append("SECRET_KEY = '" + x + "'")
        elif 'SITE_SETTINGS_KEY=' in line:
            x = settings['SITE_SETTINGS_KEY']
            new_tendenci_variables.append("SITE_SETTINGS_KEY = '" + x + "'")
        elif 'ALLOWED_HOSTS=' in line:
            x = line.split("=")[1].strip()
            new_tendenci_variables.append("ALLOWED_HOSTS = ['" + socket.gethostname() + "','" + socket.gethostbyname(socket.gethostname()) + "','" + x + "','lb." + x + "']")
        elif 'time_zone=' in line:
            new_tendenci_variables.append("TIME_ZONE = 'UTC'")
        ## Checking for installed apps and middleware
        elif "INSTALLED_APPS=" in line:
            #print('Found installed apps list.')
            x = line.split("=")[1].strip()
            if len(x) > 0:
                y = x.split(",")
                #print(y)
                for z in y:
                    installed_apps.append("'"+ z +"'")
                #print(z)
            else:
                installed_apps.append("'"+ x + "'")
        elif "MIDDLEWARE=" in line:
            #print('Found MIDDLEWARE list.')
            x = line.split("=")[1].strip()
            if len(x) > 0:
                y = x.split(",")
                #print(y)
                for z in y:
                    middleware.append("'"+ z +"'")
                #print(z)
            else:
                middleware.append("'"+ x + "'")
        elif "AUTHENTICATION_BACKENDS=" in line:
            #print('Found AUTHENTICATION_BACKENDS list.')
            x = line.split("=")[1].strip()
            if len(x) > 0:
                y = x.split(",")
                #print(y)
                for z in y:
                    authentication_backends.append("'"+ z +"'")
                #print(z)
            else:
                authentication_backends.append("'"+ x + "'")
        else:
            pass

    # If installed apps or middleware exist, write them to our appending list
    if len(installed_apps) > 1:
        separator = ','
        new_tendenci_variables.append("INSTALLED_APPS += ["+ separator.join(installed_apps) +"]")
        #print('Added INSTALLED_APPS...')
    elif len(installed_apps) == 1:
        new_tendenci_variables.append("INSTALLED_APPS += ["+ installed_apps[0] +"]")

    if len(middleware) > 1:
        separator = ','
        new_tendenci_variables.append("MIDDLEWARE = ["+ separator.join(middleware) +"] + MIDDLEWARE")
        #print('Added MIDDLEWARE...')
    elif len(middleware) == 1:
        new_tendenci_variables.append("MIDDLEWARE = ["+ middleware[0] +"] + MIDDLEWARE")

    if len(authentication_backends) > 1:
        separator = ','
        new_tendenci_variables.append("AUTHENTICATION_BACKENDS += ["+ separator.join(authentication_backends) +"]")
        #print('Added AUTHENTICATION_BACKENDS...')
    elif len(authentication_backends) == 1:
        new_tendenci_variables.append("AUTHENTICATION_BACKENDS += ["+ authentication_backends[0] +"]")

    # Search for keys prefixed with a T_, the T_ is cut off and the remainder
    # is added to the list we are going to append in the settings file
    for line in settings:
        if line.startswith("T_"):
            if settings[line][0] in [ "{" , "[" ]:
                new_tendenci_variables.append(line[2:]+ " = "+ settings[line])
            else:
                new_tendenci_variables.append(line[2:]+ " = '"+ settings[line] +"'")

    # Checking for debug and disable_template_cache settings and enabling them
    # Opening the original settings file and splitting it to a list so we can append
    # new settings to the file before the required ending of the file.
    settings_file = open('/var/www/mysite/conf/settings.py', 'rt')
    settings_data = settings_file.read()
    if "debug" in os.environ:
        settings_data = settings_data.replace("#DEBUG = True", "DEBUG = True")
        print("Enabling debug...")
    if "disable_template_cache" in os.environ:
        settings_data = settings_data.replace("#DEBUG = True", "#DEBUG = True\n\ndisable_template_cache()")
        print('Disabling template cache...')
    split_settings = settings_data.split("\n")
    settings_file.close()

    # Inserting new settings before required end of file
    for x in new_tendenci_variables:
        #print("Adding " + x + " to settings file...")
        split_settings.insert(-7, x)

    separator = "\n"
    new_data = separator.join(split_settings)

    # Deleting all text from the original file and re-writing with new settings
    fin = open('/var/www/mysite/conf/settings.py', 'wt')
    fin.truncate(0)
    fin.write(new_data)
    fin.close()
    print("Settings updated.")

    if 'urlpatterns' in settings:
        urls = open('/var/www/mysite/conf/urls.py', "a+")
        urls.write("\nurlpatterns = pre_urlpatterns + [" + settings['urlpatterns'] + "] + post_urlpatterns")
        urls.close()

settings_source()
