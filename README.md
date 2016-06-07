
# Introduction

This is a Dockerfile to build a [Kune](http://kune.ourproject.org) server with its dependencies (openfire, mysql, postfix, mainly). You can try kune using [kune.cc](http://kune.cc) node.

## Version

Current Version: **0.0.1-1**

# Contributing

If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Help new users with [Issues](https://github.com/comunes/docker-kune/issues) they may encounter
- Send us a tip via [Bitcoin](https://blockchain.info/address/1J6A2TZERJXS8evzSpmg5cxS4DaCQAkF8P)

# Reporting Issues

First of all, you should consider that this image is only released by the Comunes Collective as a helper for sysadmins, but, we don't use this image for anything rather than simple tests. So, please, fork it, improve it, and send pull requests to help other sysadmins interested in kune.

Docker is a relatively new project and is active being developed and tested by a thriving community of developers and testers and every release of docker features many enhancements and bugfixes.

Given the nature of the development and release cycle it is very important that you have the latest version of docker installed because any issue that you encounter might have already been fixed with a newer docker release.

In your issue report please make sure you provide the following information:

- The host distribution and release version.
- Output of the `docker version` command
- Output of the `docker info` command
- The `docker run` command you used to run the image (mask out the sensitive bits).

# Installation

Pull the `latest` version of the image from the docker index. This is the recommended method of installation as it is easier to update image in the future. These builds are performed by the **Docker Trusted Build** service.

```bash
docker pull comunes/kune:latest
```

You can also pull a particular version of kune by specifying the version. For example,

```bash
docker pull comunes/kune:0.0.1-1
```

Alternately you can build the image yourself.

```bash
git clone https://github.com/comunes/docker-kune.git
cd docker-kune
docker build --tag="$USER/kune" .
```
or simply:

```bash
make
```

NOTE: If you want another passwords different that the default ones, change these lines in Dockerfile before the build process:

```
ENV DB_ROOT_PWD db4kune
ENV ROOT_PWD changeme
```
also you can set `KUNE_DOMAIN` and `KUNE_PORT`.

# Quick Start

Run the kune image:

```bash
docker run --name=kune -i -t --rm -p 22001:22 -p 8888:8888 -p 9091:9091 \
	  -p 9090:9090 -p 5222:5222 -p 5223:5223 -p 7777:7777 \
	  -p 7070:7070 -p 7443:7443 -p 5229:5229 -p 5269:5269 \
	comunes/kune:0.0.1-1
```
Point your browser to `http://localhost:8888` or whatever domain you have configured in `KUNE_DOMAIN` env variable.

# Other steps

Configure openfire correctly (if you want to use the chat, or the wave federation). For that, point your browser to `http://localhost:9090` and follow the setup procedure to complete the openfire basic installation and also follow our [INSTALL openfire-kune integration appendix](https://github.com/comunes/kune/blob/master/INSTALL.md).

Also you need to configure the email system (postfix) if you want email notifications.

Probably you have to increase the limit of open files. In our debian package we use: ulimit -n 65000 in our init script but in docker you should do [something similar](https://stackoverflow.com/questions/24318543/how-to-set-ulimit-file-descriptor-on-docker-container-the-image-tag-is-phusion).

For ipv4, take into account [this](https://coderwall.com/p/rzuoew/enable-ipv6-packet-forwarding-when-using-docker).

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using docker version `1.3.0` or higher you can access a running containers shell using `docker exec` command.

```bash
docker exec -it kune bash
```

If you are using an older version of docker, you can use the [nsenter](http://man7.org/linux/man-pages/man1/nsenter.1.html) linux tool (part of the util-linux package) to access the container shell.

Some linux distros (e.g. ubuntu) use older versions of the util-linux which do not include the `nsenter` tool. To get around this @jpetazzo has created a nice docker image that allows you to install the `nsenter` utility and a helper script named `docker-enter` on these distros.

To install `nsenter` execute the following command on your host,

```bash
docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter
```

Now you can access the container shell using the command

```bash
sudo docker-enter kune
```

For more information refer https://github.com/jpetazzo/nsenter

Also you can access via ssh:

```bash
ssh -p 22001 root@localhost
```

# Upgrading

To upgrade to newer releases, simply follow this 3 step upgrade procedure.

- **Step 1**: Stop the currently running image

```bash
docker stop kune
```

- **Step 2**: Update the docker image.

```bash
docker pull comunes/kune:latest
```

- **Step 3**: Start the image

```bash
docker run -name kune -d [OPTIONS] comunes/kune:latest
```

# References

  * The [kune debian package](http://kune.cc/?locale=es#!kune.docs.6810.898) page.
  * The kune [INSTALL](https://github.com/comunes/kune/blob/master/INSTALL.md) documentation.
  * http://www.igniterealtime.org/projects/openfire/

# Credits

This docker image was created based in [sameersbn/docker-openfire](https://github.com/sameersbn/docker-openfire) image.
