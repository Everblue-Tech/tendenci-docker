# Everblue Docker Image for Tendenci - The Open Source AMS
### What is Tendenci?
> Tendenci is an open source content management system built for non-profits, associations and cause-based sites. Functionality including association management, event registration, membership management, forums, photo galleries, donations, payments, newsletters, CRM, and much more.
## How to use this image
This image is optimized for high-availability clustered deployments in a cloud environment. As such, it contains only the Tendenci application.  In order for this container to run, you must have a PostgreSQL database and a Memcached instance.  You can simplify your deployment by using the Everblue Tendenci Terraform Module. [https://github.com/Everblue-Tech/tendenci-terraform-module](https://github.com/Everblue-Tech/tendenci-terraform-module)
## Configuration
There are currently two methods of configuring the Everblue Tendenci container. The first is by passing all necessary configuration into the container via environment variable.  The second is to pass an AWS SecretsManager Secret ID into the container via environment variable. 
### Environment Variables
If configuring the container by environment variable, the following variables are required:
| Variable | Value | Description
| --- | --- | --- | 
| SECRET_KEY | 4yb*dsfs-y*%2bpv56prw@#(hol@%j9*_^$6s=l8or(j7&t_r_ | This is the secret key for Django.  You should generate a secure string, 50 characters or longer. [You can generate one here.](https://djecrety.ir) |
| SITE_SETTINGS_KEY | 0(nqjiqjwnn)ctfjj5kbnb@0tfot(!0u!7^gbzomr((d=b=oj& | This is the secret key used to protect your settings. You should generate a secure string, 50 characters or longer. [You can generate one here.](https://djecrety.ir) |
| db_host | aurora-pgsql.cluster-ro-cdofvfnghvh2.us-east-1.rds.amazonaws.com | The hostname or ip address if your PostgreSQL database. |
| db_name | postgres | The name of the database Tendenci should connect to |
| db_user | tendenci | The username Tendenci should use to connect to your database. |
| db_password | T3nd3nc1! | The password Tendenci should use to connect to your database. |
| db_port | 5432 | The TCP port on which to connect to your database. |
| cache_host | tendenci.sxf1an.0001.ue1.cache.amazonaws.com | The hostname or ip address of your Memcached deployment. |
| site_urls | everbluetendenci.com | The allowed origin for the web server. |

### AWS SecretsManager Secret
You can also configure your container using an AWS SecretsManager Secret. If using a secret, the following environment variables are required:
| Variable | Value | Description
| --- | --- | --- | 
| secret_id | tendenci | The id given to your SecretsManager secret. |

#### When using secrets manager, all required variables listed in the above "environment variables" section are required to be in your secret.

Your secret in SecretsManager should have the following format:
```json
{
  "SECRET_KEY": "4yb*dsfs-y*%2bpv56prw@#(hol@%j9*_^$6s=l8or(j7&t_r_",
  "SITE_SETTINGS_KEY": "0(nqjiqjwnn)ctfjj5kbnb@0tfot(!0u!7^gbzomr((d=b=oj&",
  "db_host": "aurora-pgsql.cluster-ro-cdofvfnghvh2.us-east-1.rds.amazonaws.com",
  "db_name": "postgres",
  "db_password": "T3nd3nc1!",
  "db_port": "5432",
  "db_user": "tendenci"
}
```
## Additional Settings
In addition to the variables listed above, the following variables are supported:
| Variable | Value | Description
| --- | --- | --- | 
| INSTALLED_APPS | markdown_deux,bootstrapform,tendenci.apps.helpdesk | A comma separated list of additional installed apps |
| AUTHENTICATION_BACKENDS | tendenci.apps.oauth2_client.backends.AuthenticationBackend | A comma separated list of additional authentication backends |
| MIDDLEWARE | aws_xray_sdk.ext.django.middleware.XRayMiddleware | A comma separated list of additional middleware |
| urlpatterns | url(r'^tickets/', include('tendenci.apps.helpdesk.urls')),url(r'^oauth2/',include('tendenci.apps.oauth2_client.urls')) | A comma separated list of additional url patterns |
| debug | true | Enables debug |

### Custom settings
Any additional variable can be added to the settings by prefixing the environment variable or secret key with T- 

For example:
| Variable | Value 
| --- | --- | 
| T_DEFAULT_FROM_EMAIL | noreply@everbluetendenci.com |

## Superuser
All new installations will default the superuser credentials to the following:  
Username: admin  
Password: password
 
## Local Development
This repo includes a docker-compose file to use for local development. You can set up your local development environment with the following steps:
```shell
git clone https://github.com/tendenci/tendenci ~/tendenci
docker-compose up
```