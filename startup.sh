#!/bin/sh

SOLR_CONFIG=/home/acl/jetty/solr/blacklight-core/conf/data-config.xml
JETTY_CONFIG=/home/acl/jetty/etc/jetty.xml

# Update username, password, and database for Solr and Jetty in its config files
# This script changes the 4th line to the content on the next line. Please note:
#   * The newline after 4c\ is mandatory
#   * The \ afterwards is there to force sed to respect whitespaces
sed -i "4c\
\              url=\"jdbc:postgresql://${PGSQL_HOST}/${PGSQL_DATABASE}\"" ${SOLR_CONFIG}
sed -i "5c\
\              user=\"${PGSQL_USER}\"/" ${SOLR_CONFIG}
sed -i "6c\
\              password=\"${PGSQL_PASS}\"/>" i${SOLR_CONFIG}

# Now, we change the IP that Jetty will use to 'localhost'
sed -i "80c\
\                                 <Arg>127.0.0.1</Arg>" ${JETTY_CONFIG}

# Start the services
java -jar /home/acl/jetty/start.jar &
cd /home/acl
rails server -p 80 &

# Beginning of an infinite loop
# 1. Download a dump of the database, and overwrite the current one
# 2. Download the new list of available PDFs
# 3. Download missing PDFs, if any
# 4. Generate new bib files?
# Repeat until the heath death of the universe
