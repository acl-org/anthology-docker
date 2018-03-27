#!/bin/sh

SOLR_CONFIG=/home/acl/jetty/solr/blacklight-core/conf/data-config.xml
JETTY_CONFIG=/home/acl/jetty/etc/jetty.xml
DATABASE_CONFIG=/home/acl/config/database.yml

# Update username, password, and database for Solr and Jetty in its config files
# This script changes the 4th line to the content on the next line. Please note:
#   * The newline after 4c\ is mandatory
#   * The \ afterwards is there to force sed to respect whitespaces
sed -i "4c\
\              url=\"jdbc:postgresql://${PGSQL_HOST}/${PGSQL_DATABASE}\"" ${SOLR_CONFIG}
sed -i "5c\
\              user=\"${PGSQL_USER}\"" ${SOLR_CONFIG}
sed -i "6c\
\              password=\"${PGSQL_PASS}\"/>" ${SOLR_CONFIG}

# Now, we change the IP that Jetty will use to 'localhost'
sed -i "80c\
\                                 <Arg>127.0.0.1</Arg>" ${JETTY_CONFIG}

# Same for the database info
sed -i "57c\
\  database: ${PGSQL_DATABASE}" ${DATABASE_CONFIG}
sed -i "58c\
\  host: ${PGSQL_HOST}" ${DATABASE_CONFIG}
sed -i "61c\
\  username: ${PGSQL_USER}" ${DATABASE_CONFIG}
sed -i "62c\
\  password: ${PGSQL_PASS}" ${DATABASE_CONFIG}

# Pull the latest version of the code - this should not overwrite the files
# we've just edited.
cd /home/acl
git pull

# Start the services
cd /home/acl/jetty
java -jar start.jar &
cd /home/acl
rails server -p 80 &

# At startup time, the server will perform the following tasks:
#  - Rebuild the database
#  - Download missing PDFs (if any)
#  - Export all papers to Bibtex and similar formats
# These tasks can take as long as they want, while the server should be running
# fine in the meantime

# Step 1: rebuild the database


# Step 2: Re-export the papers
cd /home/acl
for file in import/*xml
do
      volume=`grep '<volume id' $file | sed 's/.*volume id=.\(.*\).>.*/\1/'`
      for paper in `grep "paper id" $file | sed 's/.*id=.\([0-9]\+\).*/\1/'`
      do
              rake export:all_papers[${volume}-${paper}]
      done
done


# Step 3: Re-download the PDFs
