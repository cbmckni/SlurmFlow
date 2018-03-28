# Docker SLURM Cluster

This repository is forked from **[Data Driven HPC](https://github.com/datadrivenhpc/docker-slurmbase)** 
that provides a set of containers that can be used to run a SLURM HPC cluster as a set of Docker
containers. This version is configured with Nextflow to run **[sra2gev-slurm](https://github.com/cbmckni/sra2gev-slurm)**
The project consists of three components:

1. [docker-slurmctld](https://github.com/GRomR1/docker-slurmctld) provide
a SLURM controller or "head node".

2. [docker-slurmd](https://github.com/GRomR1/docker-slurmd) provides a
SLURM compute node.

3. [docker-slurmbase](https://github.com/GRomR1/docker-slurmbase) is the
base container from which both docker-slurmctld and docker-slurmd inherit.

This repository contains the container source files. The ready built container
images are available via DockerHub: [https://hub.docker.com/r/gromr1](https://hub.docker.com/r/gromr1).

The Docker SLURM cluster is configured with the following software packages:

- Ubuntu 16.04 LTS
- SLURM 17.11.2
- GlusterFS 3.8
- Open MPI 1.10.2
- Nextflow

A user `ddhpc` is configured across all nodes for MPI job execution and a shared
GlusterFS volume *ddhpc* is mounted on all nodes as `/data/ddhpc`. The head node
runs an SSH server for accessing the cluster.

## Launch a New SLURM cluster

Create a new directory with a `docker-compose.yml` file:

```
version: '2'

services:
  slurmflowctld:
    container_name: slurmflowctld
    environment:
      SLURM_CLUSTER_NAME: ddhpc
      SLURM_CONTROL_MACHINE: slurmflowctld
      SLURM_NODE_NAMES: slurmflowd
      INFLUXDB_HOST: influxdb
      INFLUXDB_DATABASE_NAME: docker_slurm
    tty: true
    hostname: slurmflowctld
    networks:
      default:
        aliases:
          - slurmflowctld
    image: cbmckni/slurmflowctld
    stdin_open: true
  slurmflowd:
    container_name: slurmflowd
    environment:
      SLURM_CONTROL_MACHINE: slurmflowctld
      SLURM_CLUSTER_NAME: ddhpc
      SLURM_NODE_NAMES: slurmflowd
      INFLUXDB_HOST: influxdb
      INFLUXDB_DATABASE_NAME: docker_slurm
    tty: true
    hostname: slurmflowd
    networks:
      default:
        aliases:
          - slurmflowd
    image: cbmckni/slurmflowd
    depends_on:
      - slurmflowctld
    stdin_open: true
```

After that you can create and run the configured containers with a command `docker-compose up -d`.

For a stopping them run `docker-compose down`. 


**Configuration variables**:

  * `SLURM_CLUSTER_NAME`: the name of the SLURM cluster.
  * `SLURM_CONTROL_MACHINE`: the host name of the controller container. This should match `hostname` in the `slurmctld` section.
  * `SLURM_NODE_NAMES`: the host name of the compute node container. This should match `hostname` in the `slurmd` section.
  * `INFLUXDB_HOST`: the host name of the database host. 
  * `INFLUXDB_DATABASE_NAME`: the name of existing database in influxdb host. Database should exists a retention policy with name 'default'. 
