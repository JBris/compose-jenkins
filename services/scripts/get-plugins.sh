#!/usr/bin/env bash

usage() {
    echo '
    ###############################################################
    Help:
    * Description:
        - Retrieves a list of installed Jenkins plugins.
    * Dependencies:
        - perl
    * Usage:
        - ./scripts/init.sh
    ###############################################################
    '    
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    usage
    exit 0
fi

read -p "Enter your Jenkins username (defaults to admin): " username
[[ "$username" == "" ]] && username=admin

read -p "Enter your Jenkins host (defaults to localhost:8080):" jenkins_host
[[ "$jenkins_host" == "" ]] && jenkins_host="localhost:8080"

read -sp 'Enter your Jenkins Password:' password

plugins=$(curl -sSL -u "${username}:${password}" "${jenkins_host}/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins") 
echo $plugins | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g' | sed 's/ /:/' 