# This is a Docker image for Viper.
# A description of Viper from viper.li:
#   Viper is a binary management and analysis framework dedicated to malware
#   and exploit researchers.
# This Dockerfile is based on the one made by REMnux. 
#   https://github.com/REMnux/docker/blob/master/viper/Dockerfile
# I created this file to be able to test later versions of Viper. I also include 
# radare2 and might add clamav later.

FROM debian:jessie
MAINTAINER Peter Reuterås <peter@reuteras.net>

USER root
## Install tools and libraries via apt
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends \
        autoconf \
        automake \
        build-essential \
        curl \
        gcc \
        git \
        libffi-dev \
        libfuzzy-dev \
        libssl-dev \
        libtool \
        nano \
        python-dev \
        python-pip \
        python-socksipy \
        swig && \
    # Install ssdeep
    curl -SL http://sourceforge.net/projects/ssdeep/files/ssdeep-2.12/ssdeep-2.12.tar.gz/download | \
    tar -xzC .  && \
    cd ssdeep-2.12 && \
    ./configure && \
    make install && \
    pip install pydeep && \
    cd .. && \
    rm -rf ssdeep-2.12 && \
    # Install radare2
    git clone https://github.com/radare/radare2 && \
    cd radare2 && \
    ./sys/install.sh && \
    make install && \
    cd .. && \
    rm -rf radare2 && \
    # Install PrettyTable for viper
    pip install PrettyTable && \
    # Add user for viper
    groupadd -r viper && \
    useradd -r -g viper -d /home/viper -s /sbin/nologin -c "Viper Account" viper && \
    mkdir /home/viper && \
    cd /home/viper && \
    # Checkout and build vioer
    git clone https://github.com/botherder/viper.git && \
	mkdir /home/viper/workdir && \
	cd viper && \
	ln -s ../workdir/viper.conf && \
	sed -i 's/storage_path =/storage_path =\/home\/viper\/workdir/' viper.conf.sample && \
	sed -i 's/data\/yara/\/home\/viper\/viper\/data\/yara/g' viper/modules/yarascan.py && \
    chmod a+xr viper-cli viper-web && \
	#rm viper/viper/modules/clamav.py && \
	pip install -r requirements.txt && \
    chown -R viper:viper /home/viper && \
    cd .. && \
    # Install Yara
    curl -SL "https://github.com/plusvic/yara/archive/v3.4.0.tar.gz" | tar -xzC . && \
    cd yara-3.4.0 && \
    ./bootstrap.sh && \
    ./configure && \
    make && \
    make install && \
    cd yara-python/ && \
    python setup.py build && \
    python setup.py install && \
    cd ../.. && \
    rm -rf yara-3.4.0 && \
    ldconfig &&  \
    # Install pyexiftool
	git clone git://github.com/smarnach/pyexiftool.git && \
	cd pyexiftool && \
  	python setup.py install && \
  	cd .. && \
  	rm -rf pyexiftool && \
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
EXPOSE 9090
VOLUME ["/home/viper/workdir"]
WORKDIR /home/viper/viper
CMD ./viper-web -H $HOSTNAME
