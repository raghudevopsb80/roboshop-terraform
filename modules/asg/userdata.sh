#!/bin/bash

dnf install docker -y

growpart /dev/nvme0n1 4
lvextend -r -L +10G /dev/mapper/RootVG-varVol
#pip3.11 install ansible hvac 2>&1 | tee -a /opt/userdata.log
#ansible-pull -i localhost, -U https://github.com/raghudevopsb80/roboshop-ansible main.yml -e env=${env} -e role_name=${role_name} -e vault_token=${vault_token} 2>&1 | tee -a /opt/userdata.log

