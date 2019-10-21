#!/bin/bash
########################################################################################
#This script is used to generate a local_rules.xml file for Wazuh's Ossec implementation
#
#Edit the following based on the rules you want to implement
#

R331=$(pwd)/0331-sysmon_rules.xml
R332=$(pwd)/0332-credential_access_rules.xml
R803=$(pwd)/0803-wmic_malicious_rules.xml
R804=$(pwd)/0804-defender_bypass.xml
R805=$(pwd)/0805-sysmon-modular_rules.xml
R805v10=$(pwd)/0805-v10-sysmon-modular_rules.xml
R806=$(pwd)/0806-priv_esc_rules.xml
R807=$(pwd)/0807-persistence_rules.xml
R808=$(pwd)/0808-defense_evasion_rules.xml
R809=$(pwd)/0809-execution_rules.xml
RULESFILE=$(pwd)/local_rules.xml
rm $RULESFILE

echo -e "=== Generating Configuration file ===\n"

touch $RULESFILE

echo -e "Adding: \n$R331\n"; cat $R331 >> $RULESFILE
echo -e "Adding: \n$R805v10\n"; cat $R805v10 >> $RULESFILE
echo -e "Adding: \n$R332\n"; cat $R332 >> $RULESFILE
echo -e "Adding: \n$R803\n"; cat $R803 >> $RULESFILE
echo -e "Adding: \n$R804\n"; cat $R804 >> $RULESFILE
echo -e "Adding: \n$R806\n"; cat $R806 >> $RULESFILE
echo -e "Adding: \n$R807\n"; cat $R807 >> $RULESFILE
echo -e "Adding: \n$R808\n"; cat $R808 >> $RULESFILE
echo -e "Adding: \n$R809\n"; cat $R809 >> $RULESFILE

echo -e "You can find your configuration file here:"
echo -e "$RULESFILE"
echo -e "\nUse this to replace the /var/ossec/etc/rules/local_rules.xml on your Wazuh/Ossec Server"
