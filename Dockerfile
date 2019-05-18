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
        p7zip-full \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python-socksipychain \
        swig \
        tor \
        unrar \
        wget && \
    # Install ssdeep
    git clone https://github.com/ssdeep-project/ssdeep.git && \
    cd ssdeep && \
    ./bootstrap && \
    ./configure && \
    make install && \
    cd .. && \
    rm -rf ssdeep && \
    pip3 install pyopenssl ndg-httpsclient pyasn1 && \
    pip3 install pydeep && \
    # Install radare2
    git clone https://github.com/radare/radare2 && \
    cd radare2 && \
    ./sys/install.sh && \
    make install && \
    cd .. && \
    rm -rf radare2 && \
    # Install PrettyTable for viper
    pip3 install PrettyTable && \
    # Add user for viper
    groupadd -r viper && \
    useradd -r -g viper -d /home/viper -s /sbin/nologin -c "Viper Account" viper && \
	mkdir -p /home/viper/workdir && \
    cd /home/viper && \
    # Checkout and build viper
    git clone https://github.com/viper-framework/viper.git && \
	cd viper && \
	git submodule init && \
	git submodule update && \
	ln -s ../workdir/viper.conf && \
	sed -i 's/storage_path =/storage_path =\/home\/viper\/workdir/' viper.conf.sample && \
	sed -i 's/data\/yara/\/home\/viper\/viper\/data\/yara/g' viper/modules/yarascan.py && \
    chmod a+xr viper-cli viper-web && \
    # Preinstall lief and remove extra url
    pip3 install --index-url https://lief-project.github.io/packages lief && \
	sed -i '/extra-index-url/d' ./requirements-modules.txt && \
	pip3 install -r requirements.txt && \
    chown -R viper:viper /home/viper && \
    cd .. && \
  	# Clean
  	apt-get remove -y \
  	    autoconf \
  	    automake \
        build-essential && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/debconf
USER viper
EXPOSE 8080
VOLUME ["/home/viper/workdir"]
WORKDIR /home/viper/viper
CMD /home/viper/viper/viper-cli
