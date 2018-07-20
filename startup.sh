#!/bin/sh

SOLR_CONFIG=/home/acl/jetty/solr/blacklight-core/conf/data-config.xml
JETTY_CONFIG=/home/acl/jetty/etc/jetty.xml
DATABASE_CONFIG=/home/acl/config/database.yml
export RAILS_ENV=production

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

# Here comes the production database info
sed -i "57c\
\  database: ${PGSQL_DATABASE}" ${DATABASE_CONFIG}
sed -i "58c\
\  host: ${PGSQL_HOST}" ${DATABASE_CONFIG}
sed -i "59c\
\  username: ${PGSQL_USER}" ${DATABASE_CONFIG}
sed -i "60c\
\  password: ${PGSQL_PASS}" ${DATABASE_CONFIG}

# If this is the first time running this container,
# create the database
if ${POPULATE_DB}
then
	rake db:drop
	rake db:create
	rake db:migrate
	cd /home/acl/import
	for file in *xml
	do
		name=`basename -s .xml $file`
		rake import:xml[true,$name]
	done > /dev/null
fi

# Compile assets
cd /home/acl
RAILS_ENV=production bundle exec rake assets:precompile

# Start the services
cd /home/acl/jetty
java -jar start.jar &
rake acl:reindex_solr
cd /home/acl
rails server -p 80 &

# Now, the container starts an infinite loop.
# It will perform the following tasks:
#  1. Pull the latest version of the code from Github
#  2. Download missing PDFs (if any)
#  3. Export all papers to Bibtex and similar formats
#  4. Sleep for 24hs
# These tasks can take as long as they want, because the server should be
# running fine

cd /home/acl
while true
do
	# 1. Pull the latest version of the code
	git pull

	# 2. Download missing PDFs
	# TBA

	# 3: Export all papers
	cd /home/acl
	for file in import/*xml
	do
	      volume=`grep '<volume id' $file | sed 's/.*volume id=.\(.*\).>.*/\1/'`
	      for paper in `grep "paper id" $file | sed 's/.*id=.\([0-9]\+\).*/\1/'`
	      do
	              rake export:all_papers[${volume}-${paper}]
	      done
	done

	# 4. Send the loop to sleep for 24hs
	sleep 1d 
done
