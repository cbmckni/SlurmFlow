####################
#       GEV
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

#USER ddhpc
#WORKDIR /home/ddhpc
#RUN nextflow \
#  && git clone https://github.com/cbmckni/sra2gev-slurm.git









#init nextflow and download sra2gev-slurm
nextflow && git clone https://github.com/cbmckni/sra2gev-slurm.git

# Move the files from iRODs for execution
cd sra2gev-slurm
icd /scidasZone/sysbio/experiments/SRA2GEV/$EXPID
echo "Copying SRA_IDs.txt..."
iget SRA_IDs.txt .
echo "Copying basename.txt..."
iget basename.txt .

# Adjust the nextflow config file
echo "Adjusting the nextflow.config file..."
perl -pi -e 's/.\/examples\/SRA_IDs.txt/.\/SRA_IDs.txt/' nextflow.config
perl -pi -e 's/examples\/reference/reference/' nextflow.config
export BASENAME=`cat basename.txt`
perl -pi -e "s/GCA_002793175.1_ASM279317v1_genomic/$BASENAME/" nextflow.config

# Finish copying the reference files.
echo "Copying reference genome files. This may take awhile..."
iget -r reference .

# Run the workflow
source ~/.bashrc
module add trimmomatic
#nextflow run SRA2GEV.nf -profile standard

