# springboot

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with springboot](#setup)
    * [What springboot affects](#what-springboot-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with springboot](#beginning-with-springboot)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This Puppet module implements the `springboot` class and the `springboot::app` defined type.

The class intents to create OS structures (packages, SELinux modules, systemd service templates, filesystems, group/user, ...)
in order to prepare the OS to host Springboot application(s).
The defined type intents to implement the deployment of a Springboot app instance on top of a prepared OS.

This Puppet module is part of the overall HubertQC/selinux_springboot GitHub repository:
   https://github.com/hubertqc/selinux_springboot


## Module Description

If applicable, this section should have a brief description of the technology
the module integrates with and what that integration enables. This section
should answer the questions: "What does this module *do*?" and "Why would I use
it?"

If your module has a range of functionality (installation, configuration,
management, etc.) this is the time to mention it.

## Setup

### What springboot affects

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

### Setup Requirements **OPTIONAL**

This module requires the following Puppet modules to be available:
    - puppetlabs-stdlib, version 1.0.0 or later,
    - puppetlabs-lvm, version 1.1.0 or later,
    - hubertqc-mountpoint, version 1.0.0 or later,
    - voxpopuli-selinux, version 3.0.0 or later,


### Beginning with springboot

The very basic steps needed for a user to get the module up and running.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you may wish to include an additional section here: Upgrading
(For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

Works only on Red Hat Linux and Red Hat like distributions.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You may also add any additional sections you feel are
necessary or important to include here. Please use the `## ` header.
