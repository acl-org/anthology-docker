# anthology-docker
Official source for Docker configurations, images, and examples of Dockerfiles for the ACL Anthology and projects
# ACL Anthology Docker image

This project aims to provide a Docker image of the ACL Anthology.

The process for running the ACL Anthology as a Docker image consists of 3 steps:

1. Set your configuration options
2. Allocate data resources
3. Run the Docker image


## Step 1: set your configuration options

The file `params.env` contains a list of variables that you need to set.
These variables are:
  * PGSQL_HOST: IP address of your PostgreSQL database
  * PGSQL_DATABASE: name of your database
  * PGSQL_USER: the database user
  * PGSQL_PASS: the password for the database user
  * POPULATE_DB: if true, it will create a database from scratch

Note that setting POPULATE_DB=true means the server will take several hours
to start. Luckily, you only need to do this once - afterwards all information
will be stored in your database.

Security advice: the user PGSQL_USER needs write access to PGSQL_DATABASE.
We encourage you to create a restricted user with no access to any other
database in the same host.

The default configuration options connect this Docker image to a read-only
remote database. This database is provided only to simplify the initial setup,
but you should not rely on it. We strongly encourage you to set your own local
database server, and update your configuration.

## Step 2: allocate data resources

Data for the Anthology is provided as a collection of PDF files and a 
database. The Docker image includes scripts that periodically check for
updates and download new data, which will be downloaded to your local server.

Currently, the Anthology contains around 16 GiB worth of PDFs. These papers can 
be stored in any directory you want, as long as Docker has access to it. This
directory is referred to as `<your_paper_dir>` in Step 3.


## Step 3: Run docker

Start your Docker container the following way:

```
docker run --rm --env-file ./params.env -p 8080:80 \
       -v <your_paper_dir>:/var/papers <container_name>
```

## License
Materials published in or after 2016 are licensed on a Creative Commons
Attribution 4.0 License.
