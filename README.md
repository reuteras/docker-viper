# Viper Binary Analysis and Management Framework

[![Docker Pulls](https://img.shields.io/docker/pulls/reuteras/docker-viper.svg?style=plastic)](https://hub.docker.com/r/reuteras/docker-viper/)

This is a Dockerfile to create a docker image for [Viper][1].

To run this image you can add the following aliases:

    alias viper='docker run --rm -it --name viper -v ~/Dropbox/Virus/viper-workdir:/home/viper/workdir reuteras/docker-viper'
    alias viper-bash='docker run --rm -it --name viper -v ~/Dropbox/Virus/viper-workdir:/home/viper/workdir reuteras/docker-viper bash'

Documentation for Viper can be found at [Read the docs][2] and the code is on [Github][3].

The current version of this Dockerfile has some ugly hacks to fix issues regarding issue [767](https://github.com/viper-framework/viper/issues/767).

 [1]: http://viper.li
 [2]: http://viper-framework.readthedocs.io/en/latest/index.html
 [3]: https://github.com/viper-framework/viper

