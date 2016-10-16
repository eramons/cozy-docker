FROM node:4

# Install dependencies (cozy)
RUN apt-get -y update && apt-get install -y python openssl git imagemagick curl wget sqlite3 build-essential python-dev python-setuptools python-pip libssl-dev libxml2-dev libxslt1-dev pwgen sudo

# Add cozy users and directories and install cozy npm modules
RUN useradd -M cozy && useradd -M cozy-data-system && useradd -M cozy-home && mkdir /etc/cozy && chown -hR cozy /etc/cozy && npm install -g coffee-script cozy-monitor cozy-controller 

# Envirnoment
ENV COUCHDB_USER
ENV COUCHDB_PASSWORD

ENV NODE_ENV production
ENV COUCH_HOST couchdb
ENV COUCH_PORT 5984

# Expose cozy proxy port
EXPOSE 9104

# Cozy configuration in run script 
COPY ./run.sh /
CMD ["/run.sh"]

