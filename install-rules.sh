#!/bin/bash

#choose y/N
yesno(){ read -p "$question " choice;case "$choice" in y|Y|yes|Yes|YES ) decision=1;; n|N|no|No|NO ) decision=0;; * ) echo "invalid" && yesno; esac; }

OGRULES=/var/ossec/etc/rules/local_rules.xml
NEWRULES=$(pwd)/local_rules.xml


#create backup of existing config
echo -e "\nBacking up current Rules\n"
sudo cp -av $OGRULES{,.$(date +%y%m%d-%H%M).bak}


#add new rules
echo -e "\nWriting new rules\n"
sudo mv $NEWRULES $OGRULES

echo -e "\nAdding of rules complete, restart Wazuh Manager for them to take effect\n systemctl restart wazuh-manager.service"
