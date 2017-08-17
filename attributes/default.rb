# This attribute defines your RESTful API endpoint.
#
# The default setting uses the unauthenticated local-only port 3002. Therefore it
# doesn't need to pass any credentials and works out-of-the box with chef.
#
# You can also access the RESTful API from another machine and use
# HTTPS to secure the connection. In this case your URL will look something like
# this:
#
# default['sophos']['sg']['url'] = 'https://admin:secret@example.com:3000/api'
#
# This URL uses port 3000 which is also accessible from remote machines and
# requires authentication. Credentials are given in the URL and we authenticate
# as user admin with the password secret.
# 
default['sophos']['sg']['url'] = 'http://localhost:3002/api'

# In case the SG is remote use https and provide the fingerprint of the
# certificate  or have a certificate in your chain that verifies the utm
# Example of the fingerprint format:
#     'FF:00:80:BE:89:3E:CA:7C:A4:C3:03:AF:1F:18:99:7D:75:D2:69:01'
default['sophos']['sg']['fingerprint'] = nil
