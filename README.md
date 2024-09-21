# QEMU notes
## Table of Contents
[[_TOC_]]


## Description
Compilation of useful information, scripts and cli options examples I learned 
whilst exploring QEMU.  
Note that this applies to x86_64 systems, as it is tested on 64 bit system. 

## Examples
### First time boot for Arch Linux Guest
You should remove the `-boot once` and `-cdrom` options after installing the Arch Linux into your drive. 
```bash
qemu-system-x86_64\
 -display gtk\
 -machine type=q35,accel=kvm\
 -cpu host -smp 4 -m 4G\
 -cdrom arch.iso\
 -drive driver=qcow2,if=virtio,file=arch_test.qcow2\
 -boot once=d\
 -vga qxl\
 -device VGA,vgamem_mb=64\
 -netdev tap,id=mynet0,ifname=tap0,script=no,downscript=no\
 -device e1000,netdev=mynet0,mac=52:54:69:69:69:42\
 -audio pipewire,model=sb16\
 -name "Arch Linux Test Machine"
```
Explanation:
- `-display gtk\` - Set display to GTK
- `-machine type=q35,accel=kvm\` - Set emulated machine type to q35, turn KVM acceleration on
- `-cpu host -smp 4 -m 4G\` Set CPU to host machine's CPU, Core count to 4, Memory to 4GB
- `-cdrom arch.iso\` - Add arch.iso file as a  CD-ROM
- `-drive driver=qcow2,if=virtio,file=arch_test.qcow2\` - Add arch_test.qcow2 file as a drive
- `-boot once=d\` - Only boot from CD-ROM once. After reboot revert back to hard drive
- `-vga qxl\` - Use qxl 
- `-device VGA,vgamem_mb=64\` - Set VGA memory to 64 MB
- `-netdev tap,id=mynet0,ifname=tap0,script=no,downscript=no\` - ~~Add tap device(I think)~~
- `-device e1000,netdev=mynet0,mac=52:54:69:69:69:42\` - ~~Dunno~~
- `-audio pipewire,model=sb16\` - Add Sound Blaster 16 device with pipewire as driver
- `-name "Arch Linux Test Machine"` Name to be displayed by window title
## Scripts 
### Bridged tap network setup
Use `create_bridged_tap.sh` to create bridge, bridge a tap interface and your 
ethernet interface to it.  
Then scripts attempts to get and IP address and 
network configuration from DHCP. 
```bash
git clone https://gitlab.com/turbo-zone/qemu-notes.git
cd ./qemu-notes/
chmod +x ./create_bridged_tap.sh
./create_bridged_tap.sh
```


## `qemu`(`qemu-system-x86_64`) usage
### Synopsis
QEMU binary `qemu-system-x86_64`(`qemu` from this point) can be used 
like following:
```
qemu [options] [disk_image]
```
That implies `qemu` takes optional arguments, as marked with '`[options]`'.  
Since some targets doesn't need `[disk_image]` it marked as optional too.  
The `disk_image` is a raw hard disk image for hard disk 0. 

### Options
#### Machine type
- `-machine [type=]name[,prop=value[,...]]`  
    Select the emulated machine by `name` i.e q35, 440fx etc.
    - prop `accel=accels1[:accels2[:...]]`  
        Used to enable an accelerator.  
        Kvm, xen, hvf, nvmm, whpx or tcg may be available. 
        By default, tcg is used.   
        The kvm accelerator is **recommended**

- `-cpu model`  
    Select cpu model `model` i.e core2duo, EPYC-Genoa-v1 or 
    host(**recommended**). Use `qemu -cpu help` to list available models

- `-smp [[cpus=]n][,maxcpus=maxcpus][,drawers=drawers][,books=books]`  
  `     [,sockets=sockets][,dies=dies][,clusters=clusters][,modules=modules]`  
  `     [,cores=cores][,threads=threads]`  
    Simulates Symmetric MultiProcessing(SMP)
    `-smp 2` or `-smp cpus=2` can be used to set CPU core count to 
    2(1 CPU socket consisting of 2 cores as per QEMU version 6.2 and newer) 

- `-boot [order=drives][,once=drives][,menu=on|off]`  
  `      [,splash=sp_name][,splash-time=sp_time]`  
  `      [,reboot-time‐out=rb_timeout][,strict=on|off]`   
    Specify boot order drives as a string of  drive  letters.  
    `drives` option can include one or more of these letters appended one 
    after each other, which every one of them defines a drive to boot from.
    - `a` - Floppy disk 1
    - `b` - Floppy disk 2
    - `c` - First Hardk disk
    - `d` - First CD-ROM
    - `n` - Etherboot  
    To specify boot order only on first startup use `once`:  
        `-boot once=<letters>`  
    Note that the `order` or `once` parameter should not be used together.
    Use `menu=on` for enable boot menu:
    `-boot menu=on`  
    Examples:  
        - Boot from CD-ROM first, switch back to default order after reboot:  
            `qemu -boot once=d`
         - Try to boot from network first, then from hard disk.  
             `qemu -boot order=nc`
         - Boot with a splash picture for 5 seconds.  
             `qemu -boot menu=on,splash=/root/boot.bmp,splash-time=5000`

- `-m [size=]megs[,slots=n,maxmem=size]`  
    Specify RAM size. Default is 128MiB.  
    Optional pair slots, maxmem could be used to set amount of hotpluggable 
    memory slots and  maximum  amount of memory.  
    Examples:  
    - Set memory of guest to 1G:
        `qemu -m 1G`
    - The following command-line sets the guest startup RAM size to 1GB,
      creates 3 slots to hotplug additional memory and sets the maximum 
      memory the guest can reach to 4GB:  
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

### Block device options
- `hda hard_disk`  
Set hard disk 1 to `hard_disk`  
Example:
    - Set a virtual hard drive and use the specified image file for it:   
    `-hda IMAGE.img`
### Display options
- `-display type`  
Select type of display to use.  
Use `-display help` to list the available display types.  
    - `-display sdl`  
    Display video output via SDL (usually in a separate graphics window)  
    - `-display gtk`  
      Display  video output in a GTK window. This interface provides drop-down
      menus and other UI elements to configure and control the VM during
      runtime
    - `vnc=<display>`  
      Start a VNC server on display <display>
- `-spice option[,option[,...]]`  
Enable the spice remote desktop protocol.


### Network options

## References
- qemu-system-x86_64 man page
- https://wiki.gentoo.org/wiki/QEMU/Options
