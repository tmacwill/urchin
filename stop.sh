#!/bin/bash

sudo pfctl -df /etc/pf.conf > /dev/null 2>&1
vboxmanage controlvm xenial poweroff
