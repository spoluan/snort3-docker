FROM ubuntu:20.04
LABEL author="Sevendi Eldrige Rifki Poluan" email="sevendipoluan@gmail.com"
  
# Set DEBIAN_FRONTEND to noninteractive to prevent interactive prompts
RUN export DEBIAN_FRONTEND=noninteractive

# Install tzdata package
RUN apt update && \
    apt dist-upgrade -y && \
    apt install -y tzdata

# Configure timezone non-interactively for Asia/Taipei
RUN ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Update the ubuntu server and install dependencies
RUN apt install -y software-properties-common \
        build-essential \
        libpcap-dev \
        libpcre3-dev \
        libnet1-dev \
        zlib1g-dev \
        luajit \
        hwloc \
        libdnet-dev \
        libdumbnet-dev \
        bison \
        flex \
        liblzma-dev \
        openssl \
        libssl-dev \
        pkg-config \
        libhwloc-dev \
        cmake \
        cpputest \
        libsqlite3-dev \
        uuid-dev \
        libcmocka-dev \
        libnetfilter-queue-dev \
        libmnl-dev \
        autotools-dev \
        libluajit-5.1-dev \
        libunwind-dev \
        libfl-dev \
        git \
        wget \
        unzip \
        tcpdump \
        net-tools \
        iputils-ping \
        vim

# Snort DAQ (Data Acquisition library) 
ENV DAQ_VERSION "v3.0.13"
RUN git clone https://github.com/snort3/libdaq.git --progress --verbose /tmp/libdaq && \
    cd /tmp/libdaq && \
    git checkout ${DAQ_VERSION} && \
    ./bootstrap && \
    ./configure --prefix=/usr/local/ && \
    make && \
    make install 

# Find the libdaq.pc file for verification and set PKG_CONFIG_PATH & LD_LIBRARY_PATH
RUN find /usr/local -name libdaq.pc && \
    echo 'export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH' >> /etc/profile.d/pkg_config_path.sh && \
    echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> /etc/profile.d/pkg_config_path.sh
    
# Install Google's thread-caching malloc, Tcmalloc, a memory allocator tuned for high concurrency conditions
RUN wget -P /tmp/ https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz && \
    tar xzf /tmp/gperftools-2.9.1.tar.gz -C /tmp/ && \
    cd /tmp/gperftools-2.9.1/ && \
    ./configure && \
    make && \  
    make install
 
# Download and install snort3 from source code
ENV SNORT_VERSION "3.2.1.0"  
RUN sh -c 'if . /etc/profile.d/pkg_config_path.sh 2>/dev/null; then echo "Sourced using . /etc/profile.d/pkg_config_path.sh"; else if source /etc/profile.d/pkg_config_path.sh 2>/dev/null; then echo "Sourced using source /etc/profile.d/pkg_config_path.sh"; else echo "Failed to source /etc/profile.d/pkg_config_path.sh"; fi; fi' && \
    pkg-config --modversion libdaq && \
    git clone https://github.com/snort3/snort3.git --progress --verbose /tmp/snort3 && \
    cd /tmp/snort3 && \
    git checkout ${SNORT_VERSION}  && \
    ./configure_cmake.sh --prefix=/usr/local \ 
        --enable-tcmalloc && \ 
    cd /tmp/snort3/build && \
    NUM_CORES=$(nproc) && \
    JOBS=$((NUM_CORES - 2)) && \
    make -j${JOBS} && \
    make install

# Configure the run-time bindings and validate installation
RUN ldconfig && \
    sh -c 'if . /etc/profile.d/pkg_config_path.sh 2>/dev/null; then echo "Sourced using . /etc/profile.d/pkg_config_path.sh"; else if source /etc/profile.d/pkg_config_path.sh 2>/dev/null; then echo "Sourced using source /etc/profile.d/pkg_config_path.sh"; else echo "Failed to source /etc/profile.d/pkg_config_path.sh"; fi; fi' && \
    snort -c /usr/local/etc/snort/snort.lua
 
RUN mkdir /usr/local/etc/rules && \
    mkdir /usr/local/etc/so_rules/ && \
    mkdir /usr/local/etc/lists/ && \
    mkdir /usr/local/etc/snort_custom/ && \ 
    touch /usr/local/etc/rules/local.rules && \
    touch /usr/local/etc/lists/default.blocklist && \
    mkdir /var/log/snort/

ADD entrypoint.sh /opt 
RUN chmod +x /opt/entrypoint.sh

# Clean up when done
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* 
  
# Run snort   
ENTRYPOINT ["/opt/entrypoint.sh"]  