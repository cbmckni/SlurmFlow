FROM cbmckni/slurmflowbase
LABEL Name="slurmflowctld"
LABEL Description="Slurm/Nextflow ctld Dockerfile"
LABEL Last_Edited="02/3/18"
LABEL Contact="cbmckni@clemson.edu"

ADD scripts/start.sh /root/start.sh
RUN chmod +x /root/start.sh

ADD etc/supervisord.d/slurmd.conf /etc/supervisor/conf.d/slurmd.conf

CMD ["/bin/bash","/root/start.sh"]
