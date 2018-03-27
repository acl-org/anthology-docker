# anthology-docker
Official source for Docker configurations, images, and examples of Dockerfiles for the ACL Anthology and projects
# ACL Anthology Docker image

This project aims to provide a Docker image of the ACL Anthology.

The process for running the ACL Anthology as a Docker image consists of 3 steps:

1. Set your configuration options
2. Allocate data resources
3. Run the Docker image

## Step 1: set your configuration options

The file `params.cfg` contains a list of variables that you need to set.
These variables are:
  * Database host: IP address of your database
  * Database name: name of your database
  * Username: the database user
  * Password: the password for the database user

## Step 2: allocate data resources

Data for the Anthology is provided as a collection of PDF files and a 
database. The Docker image includes scripts that periodically check for
updates and download new data, which will be downloaded to your local server.

Currently, the Anthology contains around 16 GiB worth of PDFs. These papers can 
be stored in any directory you want, as long as Docker has access to it. This
directory is referred to as `your_paper_dir` in Step 3.

The database will be regenerated periodically. Make sure that the database user
has write permissions.

## Step 3: Run docker

Start your Docker container the following way:

```
docker run --rm --env-file ./params.env -p 8080:80 \
       -v <your_paper_dir>:/var/papers <container_name>
```


# License
This software is provided under the [JSON License](http://www.json.org/license.html).
