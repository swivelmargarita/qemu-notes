# QEMU notes

## Table of Contents
[[_TOC_]]

## Description
Compilation of useful information, scripts and cli options examples I learned whilst exploring QEMU. 
Note that this applies to x86_64 systems, as it is tested on 64 bit system. 

## Scripts 
### Bridged tap network setup
Use `create_bridged_tap.sh` to create bridge, bridge a tap interface and your ethernet interface to it. Then scripts attempts to get and IP address and network configuration from DHCP. 
```bash
chmod +x ./create_bridged_tap.sh
./create_bridged_tap.sh
```
## `qemu`(`qemu-system-x86_64`) usage
### Synopsis
QEMU binary `qemu-system-x86_64`(`qemu` from this point)
can be used like following:
```
qemu [options] [disk_image]
```
That implies qemu takes optional arguments, as marked with '`[options]`'.

Since some targets doesn't need `[disk_image]` it marked as optional too.
The `disk_image` is a raw hard disk image for hard disk 0. 

- `-machine [type=]name[,prop=value[,...]]`<br>
    Flag `-machine` followed by name of the emulated machine type i.e q35, 440fx etc.
    - prop `accel=accels1[:accels2[:...]]`<br>
    Used to enable an accelerator.  
    Kvm, xen, hvf, nvmm, whpx or tcg may be available. By default, tcg is used. <br>
    The `kvm` accelerator is **recommended**
- `-cpu model`<br>
    Select cpu model `model` i.e core2duo, EPYC-Genoa-v1 or host(**recommended**). Use `qemu -cpu help` to list available models
- `-smp [[cpus=]n][,maxcpus=maxcpus][,drawers=drawers][,books=books][,sockets=sockets][,dies=dies][,clusters=clusters][,modules=modules][,cores=cores][,threads=threads]`<br>
    Simulates Symmetric MultiProcessing(SMP)
    `-smp 2` or `-smp cpus=2` can be used to set CPU core count to 2(1 CPU socket consisting of 2 cores as per QEMU version 6.2) 










