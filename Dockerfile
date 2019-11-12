# This is a Docker image for Viper.
# A description of Viper from viper.li:
#   Viper is a binary management and analysis framework dedicated to malware
#   and exploit researchers.
# This Dockerfile is based on the one made by REMnux.
#   https://github.com/REMnux/docker/blob/master/viper/Dockerfile
# I created this file to be able to test later versions of Viper. I also include
# radare2.

FROM debian:stretch-slim
MAINTAINER PR <code@ongoing.today>

USER root
## Install tools and libraries via apt
RUN sed -i -e "s/main/main non-free/" /etc/apt/sources.list && \
    apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends \
        autoconf \
        automake \
        build-essential \
        ca-certificates \
        clamav-daemon \
        curl \
        exiftool \
        gcc \
        git \
        libdpkg-perl \
        libffi-dev \
        libfuzzy-dev \
        libssl-dev \
        libtool \
        nano \
        openssh-client \
        p7zip-full \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python-socksipychain \
        ssdeep \
        swig \
        tor \
        unrar \
        wget && \
    # Install radare2
    git clone https://github.com/radare/radare2 && \
    cd radare2 && \
    ./sys/install.sh && \
    make install && \
    cd .. && \
    rm -rf radare2 && \
    # Install PrettyTable for viper
    #pip3 install PrettyTable && \
    # Support for MISP
    #pip3 install pymisp && \
    # Add user for viper
    groupadd -r viper && \
    useradd -r -g viper -d /home/viper -s /sbin/nologin -c "Viper Account" viper && \
	mkdir -p /home/viper/workdir && \
	mkdir -p /home/viper/.viper && \
    cd /home/viper && \
	ln -s /home/viper/workdir/viper.conf .viper/ && \
    git clone https://github.com/viper-framework/viper-modules.git && \
    mv viper-modules /home/viper/.viper/modules && \
    cd /home/viper/.viper/modules && \
    git submodule add https://github.com/viper-framework/Mach-O.git && \
    git submodule add https://github.com/viper-framework/pdftools.git && \
    # Install viper via pip
    pip3 install viper-framework && \
    # Install dependencies
    grep -v -E "@ git\+https" /home/viper/.viper/modules/requirements.txt > /tmp/requirements.txt && \
    mv /tmp/requirements.txt /home/viper/.viper/modules/requirements.txt && \
    pip3 install -r /home/viper/.viper/modules/requirements.txt && \
    chown -R viper:viper /home/viper && \
  	# Clean
  	apt-get remove -y \
  	    autoconf \
  	    automake \
  	    autotools-dev \
        build-essential \
        cpp \
        gcc && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/debconf
USER viper
EXPOSE 8080
VOLUME ["/home/viper/workdir"]
WORKDIR /home/viper/
CMD /usr/local/bin/viper
