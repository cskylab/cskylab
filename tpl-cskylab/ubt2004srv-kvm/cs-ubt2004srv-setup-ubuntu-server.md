# Setup Ubuntu server 20.04 LTS <!-- omit in toc -->

## `cs-ubt2004srv` v21.12.15 <!-- omit in toc -->

## Manual setup procedure <!-- omit in toc -->

This procedure installs a basic Ubuntu Server 20.04 machine with openssh-server ready to be used by other cskylab deployment procedures.

It´s intended to be used in bare metal machines.

- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Language and keyboard](#language-and-keyboard)
  - [Network](#network)
  - [Disk](#disk)
  - [OpenSSH server](#openssh-server)
  - [Complete and reboot](#complete-and-reboot)

---

## Prerequisites

The following task must be completed before installation:

- Static IP Address assignment.
- Name assigned and DNS registered.
- Generate configuration directory from template.

## Installation

Boot the machine from .iso installation file and connect to the console.

### Language and keyboard

Select **English** as language:

![Ubuntu-Setup-Screen](./images/cs-ubt2004srv_12-06-38.png)

Select your keyboard:

![Ubuntu-Setup-Screen](./images/cs-ubt2004srv_12-08-30.png)

### Network

Be sure the network interface is  `eno1` and take note of DHCPv4 address assigned:

![Ubuntu-Setup-Screen](./images/cs-ubt2004srv_12-09-15.png)

Leave empty Proxy address:

![Ubuntu-Setup-Screen](./images/cs-ubt2004srv_12-18-17.png)

Accept default mirror settings:

![Ubuntu-Setup-Screen](./images/cs-ubt2004srv_12-18-32.png)

### Disk

Select the appropriate disk for OS installation:

![Ubuntu-Setup-Screen](./images/cs-ubt2004srv_12-19-09.png)

Change the root device to its maximum size as following:

![Ubuntu-Setup-Screen](./images/cs-ubt2004srv_12-21-04.png)

![Ubuntu-Setup-Screen](./images/cs-ubt2004srv_12-21-04b.png)

![Ubuntu-Setup-Screen](./images/cs-ubt2004srv_12-21-04c.png)

Confirm disk formatting:

![Ubuntu-Setup-Screen](./images/cs-ubt2004srv_12-21-43.png)

Introduce server name (`kvm-main` or `kvm-aux`), username and password:

![Ubuntu-Setup-Screen](./images/cs-ubt2004srv_12-22-21.png)

### OpenSSH server

Check **Install OpenSSH server** and optionally import SSH identity:

![Ubuntu-Setup-Screen](./images/cs-ubt2004srv_12-24-16.png)

### Complete and reboot

Wait for installation to complete and reboot the machine

![Ubuntu-Setup-Screen](./images/cs-ubt2004srv_12-32-05.png)

>Note: You can safely ignore cloud-init messages at first boot.
