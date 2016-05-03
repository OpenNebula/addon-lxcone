# Addon LXCoNe

## Description

This addon gives Opennebula the posibility to manage LXC 
containers. It includes virtualization and monitoring drivers.

This is the readme for the current development version. If you're looking for one of the stable releases, check the [releases] (https://github.com/OpenNebula/addon-lxcone/releases) at the top of this page.


## Features

This addon has the following capabilities:

* Deploy, stop, shutdown, reboot, save, suspend and resume LXC containers.
* Supports File-System, LVM and CEPH datastores.
* It's able to hot-attach and detach NICs and Disks from all the datastores specified before.
* Failure probe. In case any node is forcibly power off, or in case of an electrical failure, all containers that where running inside affected nodes will be up and running once the node is started again, and all hard drives and NICs attached and hot-attached will be in the same state they were. Only running containers will be started, the ones that where in power off state will stay the same. The only condition is that the frontend must be up before nodes are started, and /var/lib/one must be specified with the auto option inside fstab (step 2.4 from the Guide).
* VM snaphots, only for containers with File-System disks attached.
* Obtain monitoring information from nodes and containers.
* Limit container's resources. In this moment, we are only able to limit RAM memory. CPU limit is not yet supported.

## Development

To contribute bug patches or new features, you can use the github 
Pull Request model. It is assumed that code and documentation are 
contributed under the Apache License 2.0. 

More info: 
* [How to Contribute] (http://opennebula.org/software:addons#how_to_contribute_to_an_existing_add-on) 
* Support: [OpenNebula user mailing list] (http://opennebula.org/community:mailinglists) 
* Development: [OpenNebula developers mailing list] (http://opennebula.org/community:mailinglists) 
* Issues Tracking: [Github issues] (https://github.com/OpenNebula/addon-lxc/issues)

## Authors

Leaders: Sergio Vega Gutiérrez (sergiojvg92@gmail.com), José Manuel de la Fé Herrero (jmdelafe92@gmail.com)

## Compatibility

This addon was tested on OpenNebula 4.10, 4.12 and 4.14, with the 
frontend installed on Ubuntu 14.04 and Debian 8 (Jessie). The host with LXC was a 
Debian 8 (Jessie) PC.


## Installation, Configuration and Usage
Use [this guide](https://github.com/OpenNebula/addon-lxcone/blob/master/Guide.md)

## References
[LXC] (https://linuxcontainers.org/)
[OpenNebula] (http://opennebula.org/)

## License

José Manuel de la Fé Herrero - jmdelafe92@gmail.com

Sergio Vega Gutiérrez - sergiojvg92@gmail.com

Copyright 2014-2016, OpenNebula Project, OpenNebula Systems (formerly C12G Labs)

Licensed under the Apache license, version 2.0 (the "license"); 
You may not use this file except in compliance with the license. 
You may obtain a copy of the license at:

http://www.apache.org/licenses/LICENSE-2.0.html 

Unless required by applicable law or agreed to in writing, 
software distributed under the license is distributed on an "as 
is" basis, without warranties or conditions of any kind, either 
express or implied. See the license for the specific language 
governing permissions and limitations under the license.
