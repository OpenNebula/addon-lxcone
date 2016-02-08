# LXCoNe. Installation & Configuration Guide.

The purpose of this guide is to provide users with step by step guide to install OpenNebula using LXC as the way to create virtual machines (VMs).

After following this guide, users will have a working OpenNebula with graphical interface (Sunstone), at least one host and a running VM.

Throughout the installation there are two separate roles: `frontend` and `nodes`. The frontend server will execute the OpenNebula services, and the nodes will be used to execute virtual machines.


#### Note
> We built and tested this drivers with the frontend installed on Ubuntu 14.04 (Trusty Tahr) and the nodes on Debian 8 (Jessie)


[LXC](https://linuxcontainers.org/lxc/)
is a userspace interface for the Linux kernel containment features. Through a powerful API and simple tools, it lets Linux users easily create and manage system or application containers.

[OpenNebula](http://opennebula.org/)
is a cloud computing platform for managing heterogeneous distributed data center infrastructures. The OpenNebula platform manages a data center's virtual infrastructure to build private, public and hybrid implementations of infrastructure as a service. OpenNebula is free and open-source software, subject to the requirements of the Apache License version 2.



## 1 - Installation in the Frontend


#### Warning
> Commands prefixed by # are meant to be run as root. Commands prefixed by $ must be run as oneadmin.


### 1.1. Configure **Opennebula** repository

####Add key for OpenNebula repository:
```
$ wget -q -O- http://downloads.opennebula.org/repo/Ubuntu/repo.key | apt-key add -
```

####Add this line at the end of **/etc/apt/sources.list**:  
``` 
deb http://downloads.opennebula.org/repo/4.14/Ubuntu/14.04/ stable opennebula
```


####Issue an update:
```
# apt-get update
```


### 1.2. Install the required packages

```
# apt-get install opennebula opennebula-sunstone nfs-kernel-server
```


### 1.3. Configure and start the services 

There are two main processes that must be started, the main OpenNebula daemon: `opennebula`, and the graphical user interface: `opennebula-sunstone`.

> For security reasons, Sunstone listens only in the loopback interface by default. In case you want to change this behavior, edit **/etc/one/sunstone-server**.conf and change **:host: 127.0.0.1** to **:host: 0.0.0.0**.

Now restart Sunstone:
```
# service opennebula-sunstone restart
```


### 1.4. Configure **NFS**

#### Warning
> Skip this section if you are using a single server for both the frontend and worker node roles.

Export **/var/lib/one/** from the frontend to the worker nodes. To do so add the following at the end of **/etc/exports** in the `frontend`:   
/var/lib/one/ *(rw,sync,no_subtree_check,no_root_squash,crossmnt,nohide)


####Refresh NFS exports:
```
# service nfs-kernel-server restart
```


### 1.5. Configure **SSH** public Key

OpenNebula will need to SSH passwordlessly from any node (including the `frontend`) to any other node. Set public key as authorized key:
```
# su - oneadmin
$ cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
```

Add the following snippet to **~/.ssh/config** so it doesn’t prompt to add the keys to the **known_hosts** file: 
```
$ cat << EOT > ~/.ssh/config 
Host *
 StrictHostKeyChecking no
 UserKnownHostsFile /dev/null
EOT

$ chmod 600 ~/.ssh/config
```


### 1.6. Copy and set permissions to the **LXC** drivers

Copy the **lxc** folder under **vmm** to the `frontend` on **/var/lib/one/remotes/vmm**. Route to scripts located inside **lxc**, such as **deploy**, should be this one at the end: **/var/lib/one/remotes/vmm/lxc/deploy**.

Copy **lxc.d** and **lxc-probes.d** folders under **im** to the `frontend` on **/var/lib/one/remotes/im**. Route to scripts located inside, such as **mon_lxc.sh** from **lxc.d** folder, should be this one: **/var/lib/one/remotes/im/lxc.d/mon_lxc.sh**.


Change user, group and permissions:
```
# chown -R oneadmin:oneadmin /var/lib/one/remotes/vmm/lxc /var/lib/one/remotes/im/lxc.d /var/lib/one/remotes/im/lxc-probes.d
``` 
```
# chmod -R 755 /var/lib/one/remotes/vmm/lxc /var/lib/one/remotes/im/lxc.d /var/lib/one/remotes/im/lxc-probes.d
```

### 1.7. Modify **/etc/one/oned.conf**

Under **Information Driver Configuration** add this:
```
#-------------------------------------------------------------------------------
# LXC Information Driver Manager Configuration
# -r number of retries when monitoring a host
# -t number of threads, i.e. number of hosts monitored at the same time
#-------------------------------------------------------------------------------
IM_MAD = [
 name = "lxc",
 executable = "one_im_ssh",
 arguments = "-r 3 -t 15 lxc" ]
#-------------------------------------------------------------------------------

```

Under **Virtualization Driver Configuration** add this:
```
#------------------------------------------------------------------------------- 
# LXC Virtualization Driver Manager Configuration 
# -r number of retries when monitoring a host
# -t number of threads, i.e. number of actions performed at the same time
#-------------------------------------------------------------------------------
VM_MAD = [ name = "lxc",
   executable = "one_vmm_exec",
   arguments = "-t 15 -r 0 lxc",
   type = "xml" ]
#-------------------------------------------------------------------------------

```

We are adding a [configuration file example](oned.conf), you can check it.

Restart **OpenNebula** service.
```
# service opennebula restart
```

#### Warning
> By default, Opennebula-sunstone doesn't automatically starts with the system. To change this, add **service opennebula-sunstone start** to **/etc/rc.local**.


## 2 - Installation in the Nodes

 
### 2.1. Configure **Opennebula** repositories

####Add key for OpenNebula repository:
```
# wget -q -O- http://downloads.opennebula.org/repo/Ubuntu/repo.key | apt-key add -
```

####Add this line at the end of **/etc/apt/sources.list**:    
```
deb http://downloads.opennebula.org/repo/4.14/Ubuntu/14.04/ stable opennebula
```

####Issue an update
```
# apt-get update
```


### 2.2. Install required packages

```
# apt-get install opennebula-node nfs-common bridge-utils lxc xmlstarlet x11vnc libpam-runtime bc at
```


#### Warning
> We installed the host over Debian 8 (jessie). Packages for Jessie aren't in the Opennebula repositories, but you can manually install them using any package manager (dpkg, GDebi) and watching the dependencies.

Download **VNCterm** binary package from the **GitHub** repository and install it using **dpkg** or other package manager.

### 2.3. Network configuration

Turn down your network interface
```
# ifdown eth0
```

Configure the new bridge in **/etc/network/interfaces**. This is my configuration

This is our config:
```
# This file describes the network interfaces available on your system and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface 
auto lo 
iface lo inet loopback

# The primary network interface 
#allow-hotplug eth0 
#iface eth0 inet dhcp

auto br0 
iface br0 inet static 
address 10.8.91.88 
netmask 255.255.255.0 
gateway 10.8.91.1 
bridge_ports eth0 
bridge_fd 0 
bridge_maxwait 0
```

Turn up the new bridge
```
# ifup br0
```

#### Note
> **eth0** was my primary network adapter, if the name is different in your case, remember to change it in **bridge_ports** option


### 2.4. Configure **fstab** to mount **/var/lib/one** from the `frontend`

Add this line to **/etc/fstab**:
```
192.168.1.1:/var/lib/one/ /var/lib/one/ nfs soft,intr,rsize=8192,wsize=8192,auto
```

Replace **192.168.1.1** with the frontend's ip address.

Mount the directory
```
# mount /var/lib/one
```

Now, the `frontend` should be able to SSH inside the host without password using the **oneadmin** user. 

#### Warning
> Node will automatically try to mount /var/lib/one every time it starts. This is recommended, specially if you are using shared storage, but an error will occur if the frontend is down when the node boots up. If this happen, manually mount /var/lib/one and everything should be fine.


### 2.5. Add **oneadmin** to the **sudoers** file, and enable it to run **root** commands without password.

Add the following line to **/etc/sudoers**
```
oneadmin ALL= NOPASSWD: ALL
```


### 2.6. Activate memory limit capability

Check if cgroup memory capability is available:
```
# cat /proc/cgroups| grep memory | awk '{ print $4 }'
```

A **0** indicates that capability is no loaded (**1** indicates the oposite).


To manage memory on containers add **cgroup** argument to **grub** to activate those functionality. Add, in **GRUB_CMDLINE_LINUX** entry of **/etc/default/grub** file, the **cgroup_enable=memory** and **swapaccount=1** parameters.
```
[...] 
GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"
[...]
```

Regenerate grub config
```
# update-grub
```

### 2.7. Add loop devices
Every File System image used by LXC through this driver will require one loop device. Because the default limit for this loop devices is 8, this needs to be increased. 

Write **options loop max_loop=64** to **/etc/modprobe.d/local-loop.conf**

Activate loop module automatically. Write **loop** at then end of **/etc/modules**.

**Reboot** host to enable changes from previous steps.

### 2.8. Prepare the node for using LVM Datastores [Optional]

In case an image datastore wants to be created as LVM this steps will be needed.

#### Note
>To use LVM drivers, the system datastore must be shared. This sytem datastore will hold only the symbolic links to the block devices, so it will not take much space. See more details on the System Datastore Guide

>It is worth noting that running virtual disk images will be created in Volume Groups that are hardcoded to be vg-one-<system_ds_id>. Therefore the nodes must have those Volume Groups pre-created and available for all possible system datastores.

#### Installing required packages
```
# apt-get install lvm2 clvm
```

#### Creating a physical volume 
```
# pvcreate /dev/sdxx
```
**sdxx** is the disk or partition that will be used by LVM.

#### Creating a volume group
```
# vgcreate vg-one-SYSTEM_DATASTORE_ID /dev/sdxx
```
**SYSTEM_DATASTORE_ID** will be 0 if using the default system datastore


### 2.9. Prepare the node for using Ceph Datastores [Optional]

#### Install ceph
```
# apt-get install ceph
```

#### Add the node to an existing ceph cluster
For this, just copy **ceph.conf** and the keyring for the user to /etc/ceph.

#### Change permissions

#### Enable ceph to run commands without specifying a keyring for the user
Add the following line to **/etc/environment**
```
CEPH_ARGS="--keyring /route/to/keyring/file --id user(one by default)"
```

Activate loop module automatically. Write **rbd** at then end of **/etc/modules**.

Reboot or load rbd module with **modprobe rbd**.


## 3 - Create LXC image

### 3.1. Create a raw image using **LXC**

```
# lxc-create -t debian -B loop --fssize=3G -n name
```

#### Warning
> If this command fails, try running it again.

We just created a 3Gb raw image with a linux container inside. The raw image file will be located at **/var/lib/lxc/name/rootdev**. 
**name** will be the name of the container.


### 3.2. Configure this container


####  3.2.1. Start the container

First, be sure to copy the **root** password at the end of **lxc-create**
```
# lxc-start -n name
```

####  3.2.2. Change the default root password

Inside the container type:
```
# passwd
```

####  3.2.3. Install the software you want

**openssh-server**, for example


### 3.3. Make the image fit into a 512-byte sector 
Images created by LXC won't mount well, either in a loop device or a LV, in case LVM is being used. This happens because size of images created with LXC is not multiple of 512 bytes. Right now we are working on this,  but a simple patch will be the following:

####  3.3.1. Create an empty raw image.
This can be done in different ways, one of them is the following command:
```
# qemu-img create -f raw image_name <SIZE_IN_MB>M
```
You need to have "qemu" installed for this to work. This package should be already installed because it's a dependency of opennebula-node.
You should specify size a little bigger than **fssize** parameter when creating the image with **lxc-create**, just in case.

####  3.3.2. Dump content inside image
```
# dd if=/var/lib/lxc/**name**/rootdev of=image_name bs=512 conv=notrunc
```


## 4 - Sunstone

#### 4.1. Enter the **Sunstone** interface

Log in to `http://192.168.1.1:9869/` address.
Replace **192.168.1.1** with the `frontend` ip address.

The credentials are located in the `frontend` inside **/var/lib/one/.one/one_auth**. You'll need to be oneadmin user to be able to read this file.


#### 4.2. Upload the image previously created with **LXC** to **OpenNebula** using **Sunstone**

You can add one using sunstone under **Virtual Resources** --> **Images** --> **ADD**.

#### This is the required data:
* Name. 
* Type. Select OS.
* Image Location. In case the image is on a web server, **Provide a Path** can be used, just copy the URL. 

Upload the image created by lxc, located in /var/lib/lxc/**name**/rootdev to OpenNebula. 

![Adding an image file] (picts/Images.png)

#### Warning
> The image file will be located by default in **/var/lib/lxc/$name/rootdev**. In case LVM is going to be used, remember to upload the image created in step 3.2.

#### Warning
> Until now, we are only using the default datastore created by OpenNebula. Please, use this one.


#### 4.3. Add the host

You can add one using sunstone under **Infrastructure** --> **Hosts** --> **ADD**. 

#### This is the required data:
* Type. Select **Custom**.
* Write the host's Ip address where LXC is installed and configured. You can also write a hostname or DNS if previously configurated.
* Under **Drivers**
    * Virtualization. Select Custom.
    * Information. Select Custom.
    * Custom VMM_MAD. Write lxc.
    * Custom IM_MAD. Write lxc.

![Host configuration example] (picts/Host.png)


#### 4.4. Create a virtual network

You can add one using sunstone under **Infrastructure** --> **Virtual Networks** --> **ADD**. 
#### This is the required data:
* Under **General**:
    * Name
* Under **Conf**:
    * Bridge. Write the name of the bridge previously created. **br0** in this case.
* Under **Addresses**:
    * Ip Start. This will be the first address in the pool.
    * Size. Amount of IP addresses OpenNebula can assign after **Ip Start**.
* Under **Context**:
    * Add gateway

After this, just click on the **Create** button.


#### 4.5. Create a new template

You can add one using sunstone under **Virtual Resources** --> **Templates** --> **ADD**. 
#### This is the required data:
* Under **General**:
    * Name
    * Memory
    * CPU
* Under **Storage**
    * Select on Disk 0 the previously loaded OS image from LXC
    * It is posible to add several more LVM and File System diks. This disks will be mounted inside the container under **/media/DISK_ID**
* Under **Network**
    * Select none, one or many network interfaces. They will appear inside the container configured.
* Under **Input/Output** (In case VNC is required0
    * Select VNC under graphics.
    * The only required field is **Password**. A password must be specified or **Generate Random Password** must be checked.

After this, just click on the **Create** button.


#### 4.6. Deploy a container
You can add one using sunstone under **Virtual Resources** --> **Virtual Machines** --> **ADD**.
Select template and click **Create**.
Select the Virtual Machine and click **Deploy** from the menu.


## 4 - FAQs and tips for this addon

#### I attached an image as hard drive. Where is it?
Every image attached to any container will be automatically mounted inside the container in **/media/$DISK_ID**. Doesn't matter if it was hot-attached or attached in the template and then deployed, it will always be mounted in that folder.

#### It won't detach, what happened?
For you to be able to detach an image from a running container, this image needs to be mounted in the same place it was originally mounted (**/media/$DISK_ID**  as specified before). Also, it can't be in use for any application in the container or it will purposely fail, you can make sure of this using lsof.

#### I attached a Virtual Nic, wich one is it and is it configured?
Nic's ID will match with the eth number inside the container. For example, if OpenNebula shows that the NIC you attached has an ID=3, this nic will be eth3 inside the container. NICs will already appear configured if you add them in the template and then deploy that template. If you hot-attached it, it won't be configured but it will appear, for you to be able to manually configure it. This happens because OpenNebula doesn't pass that info when hot attaching a NIC. Now, in case you hot attach a NIC, if you shutdown and then start this container again, it will appear configured, with the configuration specified by OpenNebula.

#### If I configure NICs inside the container using /etc/network/interfaces, will the container use this configuration or the one provided by OpenNebula?
It will use both. In case the configuration from OpenNebula matches the one inside the interfaces file, this will obviously be the configuration that the NIC will get. If not, the NIC will have two different configurations associated. 

#### Can I also shutdown LXC container's from LXC's CLI or from inside the container?
Yes, you can. There are some other actions that need to be done, but they will be executed regardless you issued the shutdown from OpenNebula or fron LXC. It might take up to 30 seconds to OpenNebula to change te container's status in case you power off the container from LXC.


### Any issue or question please contact us.

Sergio Vega Gutiérrez (sergiojvg92@gmail.com)
José Manuel de la Fé Herrero (jmdelafe92@gmail.com)






