# Apache2 container with mods and Git

![Travis (.com) branch](https://img.shields.io/travis/com/baskraai/docker-apache-mod-git/master?label=Build%20Master&style=flat-square)

This is a container with Apache2, some modules and a Git client for pulling the certificates and config.
The purpose of this host is a running a loadbalancer-like apache2 instaces with auto-git pulling of config and certificates.
This image is not based on the official HTTPD Docker container, but on the ubuntu install of apache2.

## Repo's

This images can use two repo's:

 - Apache2 config
 - Certificates

These can be the same repo, but you need to put the files in the right path:

 - apache2 sites : <git_repo>/sites
 - certificates : <git_repo>/live

The certificates directory is based on the folder lay-out of Let's Encrypt.
If you use a git repository based `/etc/letsencrypt`, you can just use that repository directly.

## Ports

This containers exposes the following ports:

| Port | usage |
| :---: | --- |
| 80 | HTTP |
| 443 | HTTPS |

## Usage

You can use this image with docker run and docker-compose.
Below are examples for both.

### Docker run

The most basic docker run config is:

```bash

docker run --name "apache-mod-git" -e CONFIG_MOUNT="/config" -e SSH_KEY_MOUNT="/keys" -v "$(pwd)/keys":/keys -v "$(pwd)/config":/config baskraai/openssh-server

```

 1. Create the following directories: `config` and `keys`
 2. You need to create a id\_ecdsa ssh key in de keys directory, for now the only supported type is ecdsa.
 3. run the `docker run` command above.

### Parameters

You can use the following parameters with this container:

| Parameter | meaning |
| :---: | --- |
| --hostname | Used to set the minion and master name |

### Environment variables

You can use the following environment variables with this container:

| Variable | Required | meaning | values |
| :---: | --- | --- | --- |
| NAME | Required | Name of the user | string |
| SSH\_KEY\_MOUNT | Optional | The directory with the ssh keys used for git clone | linux path |
| SSH\_PRIVKEY | Optional |Give the private ssh key directly | SSH private key |
| SSH\_PUBKEY | Optional | Give the public ssh key directly | SSH public key |
| CONFIG\_REPO | Required | The repo url for the apache2 configuration | git ssh link |
| CERT\_REPO | Required | The repo url for the SSL certificates | git ssh link |
| CONFIG\_MOUNT | Required | The location of the directory mounted apache2 config | linux path |

## Extend image

```Dockerfile
FROM baskraai/apache-mod-git:latest
RUN apt-get update \
    && apt-get install -y <packages> \
    && rm -rf /var/lib/apt/lists/
```

With this Dockerfile the rest of the container keeps working as expected.

### Todo
