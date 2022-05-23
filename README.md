# Terrarform slurm setup
This terrfaform configuration can setup in combination with kiwi a two nodes with KVM so that they act as a small slurm cluster. 
## Setup
Install the required tools:
```
zypper in terraform kiwi-ng libvirt
```
Setup the libvirt terraform and other providers with
```
sudo terraform init
```
## Starup the nodes
At first build the image, e.g. with
```
./build-image.sh leap15.4
```
After the image has been build (can take some time, depending on the used hardware), boot the nodes with
```
sudo terraform apply -var="image=/var/tmp/leap15.4-current/Leap-15.4_appliance.x86_64-1.15.3.qcow2"
```
The cluster will boot now and the primary node is then `10.10.$RAND.11`. You can login with the root password is `linux`.

## Configuration
The configuration of the nodes is under `assets/root`, so every file in there will show up on the root file system of the nodes. So you might want to add your ssh-key under `assets/root/root/.ssh/authorized_keys`. 

If a distribution requires its own configurations, place the files under `$DISTRI/root/`, e.g. there are special slurm configrations like `tw/root/etc/slurm/slurm.conf`.

## Adding custom packages
Self compiled packages can be added in the directory `$DISTRI/local`. This repo will not show up on the booted nodes.

## Test the cluster
Log in to a node and run
```
sbatch sleeper.sh
```
