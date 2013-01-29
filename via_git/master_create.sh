#!/bin/bash

##################################################### Owner Information ###################################################
##                                                                                                                       ##
## Created by Robert "Red" English (KsaRedFx) for open source use under the licence "Creative Commons                    ##
## Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0) Feel free to use this script for any reason as long as you follow  ##
## the rules of the licence found here: http://creativecommons.org/licenses/by-sa/3.0/                                   ##
## Basically this just means that you have to credit me and inform me when you are using it, or any part of it           ##
## commercially, even with editing, then licence that work under a similar licence to this one.                          ##
##                                                                                                                       ##
## "Red" on irc.ospnet.org #sllabs or #castlestoryonline                                                                 ##
## @KsaRedFx on Twitter                                                                                                  ##
## http://brokengear.net                                                                                                 ##
##                                                                                                                       ##
####################################################### Instructions ######################################################
##                                                                                                                       ##
## Make sure to run the file in a fresh user for the ircd and to follow the promted questions and instructions closely   ##
##                                                                                                                       ##
########################################################## Purpose ########################################################
##                                                                                                                       ##
## This script was developed to give you a simple and easy way to install an ircd and syncronise it with the repos       ##
##                                                                                                                       ##
##                                                                                                                       ##
###########################################################################################################################



mkdir -p ~/git/config
mkdir -p ~/git/pubkeys
cd ~/git/config && git init
cd ~/git/pubkeys && git init
cd ~
echo "Creating snyc file"
echo "#"\!"/bin/bash" > sync.sh
echo "" >> sync.sh
echo "for repo in config pubkeys" >> sync.sh
echo "do" >> sync.sh
echo "        cd ~/git/\$repo" >> sync.sh
echo "        git add ." >> sync.sh
echo "        git commit -am 'Sync Script'" >> sync.sh
echo "#       git push pinwheel master" >> sync.sh
echo "done" >> sync.sh
echo "Sync file created"

echo "Please enter the irc network's domain, example: ospnet.org"
read domain
echo "The irc network's domain is $domain"
echo "Is this correct? (y/n)"
read answer
if [ $answer != y ] ; then
	echo "Exiting"
	exit
fi
git config --global user.name $USER
git config --global user.email $USER@$domain
echo "Generating Key"
ssh-keygen -t rsa -C "Git Master@$domain"
cat ~/.ssh/id_rsa.pub > ~/git/pubkeys/authorized_keys
cd ~/git/pubkeys && git add .
git commit -am "Initial Commit"
cd ~/git/config
echo "Generating a key and certificate"
echo ""
echo "#############################"
echo "Set the password to 'super'"
echo "#############################"
openssl genrsa -des3 -out server.key 4096
echo "Set the information below as requested"
openssl req -new -key server.key -out server.csr
echo ""
echo "#############################"
echo "The password is 'super'"
echo "#############################"
openssl rsa -in server.key -out ssl.key
openssl x509 -req -in server.csr -signkey ssl.key -out ssl.cert
echo "Cert and Key generated"
echo "Cleaning up"
rm server.csr
rm server.key
echo "Commiting"
git add .
git commit -am "Initial Commit"
echo "Git commited"
cp -R ~/IRCSetupScripts/config/* ~/git/config
cd ~/git/config/
git add .
git commit -am "Adding in default configs"
echo "Setup complete"
echo ""
echo "#############################"
echo "Please remember to properly edit the files in ~/git/config and then run sync.sh"
echo "Each time you make edits to anything in ~/git/config or ~/git/pubkeys please remember to run sync.sh"