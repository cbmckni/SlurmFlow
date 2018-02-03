FROM ubuntu:16.04
LABEL Name="SLURMFlowBase"
LABEL Description="Slurm/Nextflow base Dockerfile"
LABEL Last_Edited="02/3/18"
LABEL Contact="cbmckni@clemson.edu"

####################
#   Basic Setup
####################

ENV SLURM_VER=17.11.2

# Add some basic utilities 
RUN apt-get update && apt-get -y  dist-upgrade
RUN apt-get -y install git tcl wget unzip default-jre vim zlib1g-dev libbz2-dev liblzma-dev python \
     munge curl gcc make bzip2 supervisor python python-dev \
     libmunge-dev libmunge2 lua5.3 lua5.3-dev libopenmpi-dev openmpi-bin \
     gfortran vim python-mpi4py python-numpy python-psutil sudo psmisc \
     software-properties-common python-software-properties iputils-ping \
     openssh-server openssh-client

# Create users, set up SSH keys (for MPI)
RUN useradd -u 2001 -d /home/slurm slurm
RUN useradd -u 6000 -ms /bin/bash ddhpc \
    && echo "source /etc/profile.d/z00_lmod.sh" >> ~ddhpc/.bashrc \
    && chown -R ddhpc /home/ddhpc
ADD etc/sudoers.d/ddhpc /etc/sudoers.d/ddhpc
ADD home/ddhpc/ssh/config /home/ddhpc/.ssh/config
ADD home/ddhpc/ssh/id_rsa /home/ddhpc/.ssh/id_rsa
ADD home/ddhpc/ssh/id_rsa.pub /home/ddhpc/.ssh/id_rsa.pub
ADD home/ddhpc/ssh/authorized_keys /home/ddhpc/.ssh/authorized_keys
RUN chown -R ddhpc:ddhpc /home/ddhpc/.ssh/
RUN chmod 400 /home/ddhpc/.ssh/*

# Install packages
RUN apt-get update && apt-get -y  dist-upgrade
RUN apt-get install -y munge curl gcc make bzip2 supervisor python python-dev \
    libmunge-dev libmunge2 lua5.3 lua5.3-dev libopenmpi-dev openmpi-bin \
    gfortran vim python-mpi4py python-numpy python-psutil sudo psmisc \
    software-properties-common python-software-properties iputils-ping \
    openssh-server openssh-client \
    automake autoconf unzip \ 
    libgtk2.0-dev libglib2.0-dev \
    libhdf5-dev \
    libcurl4-openssl-dev

####################
#      SLURM
####################

# Download, compile and install SLURM
RUN curl -fsL https://download.schedmd.com/slurm/slurm-17.11.2.tar.bz2 | tar xfj - -C /opt/ \
    && cd /opt/slurm-${SLURM_VER}/ && \
    ./configure && make && make install
ADD etc/slurm/slurm.conf /usr/local/etc/slurm.conf


# Configure OpenSSH
# Also see: https://docs.docker.com/engine/examples/running_ssh_service/
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN mkdir /var/run/sshd
RUN echo 'ddhpc:ddhpc' | chpasswd
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ADD etc/supervisord.d/sshd.conf /etc/supervisor/conf.d/sshd.conf


# Configure GlusterFS
# RUN add-apt-repository ppa:gluster/glusterfs-3.8 && \
#     apt-get update -y && \
#     apt-get install -y glusterfs-server
#
# RUN mkdir -p /data/ddhpc
# ADD etc/supervisord.d/glusterd.conf /etc/supervisor/conf.d/glusterd.conf


# Configure munge (for SLURM authentication)
ADD etc/munge/munge.key /etc/munge/munge.key
RUN mkdir /var/run/munge && \
    chown root /var/lib/munge && \
    chown root /etc/munge && chmod 600 /var/run/munge && \
    chmod 755  /run/munge && \
    chmod 600 /etc/munge/munge.key
ADD etc/supervisord.d/munged.conf /etc/supervisor/conf.d/munged.conf

####################
#     Nextflow
####################

# Install the Lmod modules system for package managmenet since
# the GEV workflow expects it

WORKDIR /usr/local/src
RUN apt-get install -y lua5.2 liblua5.2-dev libtool-bin lua-posix lua-filesystem lua-filesystem-dev \
  && git clone https://github.com/TACC/Lmod.git --branch 7.7.13 \
  && cd Lmod \
  && ./configure --prefix=/usr/local \
  && make install \
  && ln -s /usr/local/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh \
  && ln -s /usr/local/lmod/lmod/init/cshrc /etc/profile.d/z00_lmod.csh \
  && mkdir -p /usr/local/modulefiles/Linux

# Install Nextflow
RUN wget -qO- get.nextflow.io | bash \
  && mv nextflow /usr/local/bin \
  && chmod 755 /usr/local/bin/nextflow \
  && rm -rf ~/.nextflow

####################
#       GEV
####################

# Install SRAToolkit v2.8.2
RUN apt-get install -y curl \
  && wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2/sratoolkit.2.8.2-ubuntu64.tar.gz \
  && tar -zxvf sratoolkit.2.8.2-ubuntu64.tar.gz \
  && mv sratoolkit.2.8.2-ubuntu64 /usr/local/sratoolkit.2.8.2 

# Install trimmomatic
RUN wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.36.zip \
  && unzip Trimmomatic-0.36.zip \
  && mv Trimmomatic-0.36 /usr/local

# Install hisat2
RUN wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/downloads/hisat2-2.1.0-Linux_x86_64.zip \
  && unzip hisat2-2.1.0-Linux_x86_64.zip \
  && mv hisat2-2.1.0 /usr/local

# Install samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.6/samtools-1.6.tar.bz2 \
  && bunzip2 samtools-1.6.tar.bz2 \
  && tar -xvf samtools-1.6.tar \
  && cd samtools-1.6 \
  && ./configure --prefix=/usr/local/samtools-1.6 --without-curses \
  && make install

# Install stringtie
RUN wget http://ccb.jhu.edu/software/stringtie/dl/stringtie-1.3.3b.Linux_x86_64.tar.gz \
  && tar -zxvf stringtie-1.3.3b.Linux_x86_64.tar.gz \
  && mv stringtie-1.3.3b.Linux_x86_64 /usr/local/stringtie-1.3.3b 
   
# Add the module files for all of the installed tools
ADD modulefiles/. /usr/local/modulefiles/Linux

USER ddhpc
WORKDIR /home/ddhpc
RUN nextflow \
  && git clone https://github.com/cbmckni/sra2gev-slurm.git

####################
#      iRODS
####################

# Install IRODs
ADD scripts/. /usr/local/share
RUN apt-get -y install libfuse2 expect \
  && wget ftp://ftp.renci.org/pub/irods/releases/4.1.11/ubuntu14/irods-icommands-4.1.11-ubuntu14-x86_64.deb \
  && dpkg -i irods-icommands-4.1.11-ubuntu14-x86_64.deb \
  && chmod 755 /usr/local/share/*


EXPOSE 22
