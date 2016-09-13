default['sophos']['sg']['url'] = 'http://admin:pppp@localhost:3000/api'

# In case the SG is remote use https and provide the fingerprint of the
# certificate  or have a certificate in your chain that verifies the utm
# Example of the fingerprint format:
#     'FF:00:80:BE:89:3E:CA:7C:A4:C3:03:AF:1F:18:99:7D:75:D2:69:01'
default['sophos']['sg']['fingerprint'] = nil
