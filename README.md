# Addon LXCoNe

## Description

This addon gives Opennebula the posibility to manage LXC 
containers. It includes virtualization and monitoring drivers.

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

This addon was tested on OpenNebula 4.10 and 4.12, with the 
frontend installed on Ubuntu 14.04. The host with LXC was a 
Debian 8 (jessie) PC.

## Features

With the monitoring driver we can monitor both the host and the 
container. This currently works fine
With the virtualization driver, we can deploy lxc container based 
on raw images, attach disks, assign RAM memory to the containers, 
configure the container's network. Reboot, cancel, reset and 
shutdown functions are also supported.

## Limitations

-We currently can't attach more than one network interface.
-We can only use the default datastore.
-Only supports Shared and SSH for distributing datastore images to the host. 
-Only supports File-system image datastore. Currently working on LVM support.
-Doesn't sets CPU ammount to the containers.


## Installation, Configuration and Usage
Use this guide:
https://github.com/OpenNebula/addon-lxcone/blob/master/LXC%2BOpenNebula_Guide.pdf

## References
https://linuxcontainers.org/
http://opennebula.org/

## License

José Manuel de la Fé Herrero - @jmdelafe
Sergio Vega Gutiérrez - @sergiojvg

Licensed under the Apache license, version 2.0 (the "license"); 
You may not use this file except in compliance with the license. 
You may obtain a copy of the license at:

http://www.apache.org/licenses/LICENSE-2.0.html 

Unless required by applicable law or agreed to in writing, 
software distributed under the license is distributed on an "as 
is" basis, without warranties or conditions of any kind, either 
express or implied. See the license for the specific language 
governing permissions and limitations under the license.
