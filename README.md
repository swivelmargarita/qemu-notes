# QEMU notes

## Table of Contents
[[_TOC_]]

## Description
Compilation of useful information, scripts and cli options examples I learned 
whilst exploring QEMU. 
Note that this applies to x86_64 systems, as it is tested on 64 bit system. 

## Scripts 
### Bridged tap network setup
Use `create_bridged_tap.sh` to create bridge, bridge a tap interface and your 
ethernet interface to it. Then scripts attempts to get and IP address and 
network configuration from DHCP. 
```bash
git clone https://gitlab.com/turbo-zone/qemu-notes.git
cd ./qemu-notes/
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

### Options
Since some targets doesn't need `[disk_image]` it marked as optional too.
The `disk_image` is a raw hard disk image for hard disk 0. 

- `-machine [type=]name[,prop=value[,...]]`<br>
    Flag `-machine` followed by name of the emulated 
    machine type i.e q35, 440fx etc.
    - prop `accel=accels1[:accels2[:...]]`<br>
    Used to enable an accelerator.  
    Kvm, xen, hvf, nvmm, whpx or tcg may be available. 
    By default, tcg is used. <br>
    The `kvm` accelerator is **recommended**

- `-cpu model`<br>
    Select cpu model `model` i.e core2duo, EPYC-Genoa-v1 or 
    host(**recommended**). Use `qemu -cpu help` to list available models

- `-smp [[cpus=]n][,maxcpus=maxcpus][,drawers=drawers][,books=books]
[,sockets=sockets][,dies=dies][,clusters=clusters][,modules=modules]
[,cores=cores][,threads=threads]`<br>
    Simulates Symmetric MultiProcessing(SMP)
    `-smp 2` or `-smp cpus=2` can be used to set CPU core count to 
    2(1 CPU socket consisting of 2 cores as per QEMU version 6.2 and newer) 

- `-boot [order=drives][,once=drives][,menu=on|off]
         [,splash=sp_name][,splash-time=sp_time]
         [,reboot-time‐out=rb_timeout][,strict=on|off]` <br>
    Specify boot order drives as a string of  drive  letters.
    `drives` option can include one or more of these letters appended one 
    after each other, which every one of them defines a drive to boot from.
    - `a` - Floppy disk 1
    - `b` - Floppy disk 2
    - `c` - First Hardk disk
    - `d` - First CD-ROM
    - `n` - Etherboot<br>
    To specify boot order only on first startup use `once`:
        `-boot once=<letters>`
    Note that the `order` or `once` parameter should not be used together.
    Use `menu=on` for enable boot menu:
    `-boot menu=on`
    Examples:<br>
        - Boot from CD-ROM first, switch back to default order after reboot:<br>
            `qemu -boot once=d`
         - Try to boot from network first, then from hard disk
             `qemu -boot order=nc`
         - Boot with a splash picture for 5 seconds.
             `qemu -boot menu=on,splash=/root/boot.bmp,splash-time=5000`

- `-m [size=]megs[,slots=n,maxmem=size]`<br>
    Specify RAM size. Default is 128MiB.
    Optional pair slots, maxmem could be used to set amount of hotpluggable 
    memory slots and  maximum  amount of memory.<br>
    Examples:
        - Set memory of guest to 1G:
            `qemu -m 1G`
        - The following command-line sets the guest startup RAM size to 1GB,
        creates 3 slots to hotplug additional memory and sets the maximum 
        memory the guest can reach to 4GB:<br>
            `qemu -m 1G,slots=3,maxmem=4G`

- `-audio [driver=]driver[,model=value][,prop[=value][,...]]`
    Examples:
    - This sets the audio hardware to Sound Blaster 16 and audio driver to 
    pulseaudio.
        `qemu-system-x86_64 -audio pa,model=sb16`

- `-device driver[,prop[=value][,...]]`
      Add  device driver. prop=value sets driver properties. Valid properties
      depend on the driver.

- `-name name`
      Sets the name of the guest. This name will be displayed in the SDL window
      caption.  The  name will also be used for the VNC server. Also 
      optionally set the top visible process name in Linux. Naming of  
      individual threads can also be enabled on Linux to aid debugging.

