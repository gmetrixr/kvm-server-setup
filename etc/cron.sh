#!/bin/bash

/usr/sbin/netplan apply
/etc/init.d/procps restart
