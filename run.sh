#!/bin/bash
# Add tokens
echo ${COUCHDB_USER} > /etc/cozy/couchdb.login
echo ${COUCHDB_PASSWORD} >> /etc/cozy/couchdb.login
chown cozy-data-system /etc/cozy/couchdb.login
chmod 640 /etc/cozy/couchdb.login
pwgen -s -1 16 > /etc/cozy/controller.token
chown cozy-home /etc/cozy/controller.token
chmod 700 /etc/cozy/controller.token

# Make controller listen in all IPs (and not only localhost)
export CONTROLLER_HOST=0.0.0.0

# Wait for couchdb to be up and running
RUNNING=1
while [ $RUNNING != 0 ]; do
        (curl -s couchdb:5984)
        RUNNING=$?
done

# Create cozy database
curl -s -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@$COUCH_HOST:$COUCH_PORT/cozy

# Start cozy controller as background process
cozy-controller start &
pid="$!"

# Wait for cozy controller to be up and running
RUNNING=1
while [ $RUNNING != 0 ]; do
        (curl -s localhost:9002)
        RUNNING=$?
done

# Install cozy modules
cozy-monitor install data-system
cozy-monitor install home
cozy-monitor install proxy

# Stop controller background process
if ! kill -s TERM "$pid" || ! wait "$pid"; then
	echo >&2 'cozy-controller not running.'
	exit 1
fi
 
# Start controller in the foreground
cozy-controller start 


