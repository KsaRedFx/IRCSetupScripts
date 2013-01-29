#!/bin/bash
mkdir -p ~/git/config
mkdir -p ~/git/pubkeys
cd ~/git/config && git init
cd ~/git/pubkeys && git init
cd ~
echo "Creating snyc file"
echo "#\!/bin/bash" > sync.sh
echo "repos=(config pubkeys)" >> sync.sh
echo "" >> sync.sh
echo "for repo in ${repos[*]}" >> sync.sh
echo "do" >> sync.sh
echo "        cd ~/git/$repo" >> sync.sh
echo "        git add ." >> sync.sh
echo "        git commit -am 'Sync Script'" >> sync.sh
echo "#       git push pinwheel master" >> sync.sh
echo "done" >> sync.sh
echo "Sync file created"
echo "Generating Key"
echo "Please enter the irc network's domain, example: ospnet.org"
read domain
echo "The irc network's domain is $domain"
echo "Is this correct? (y/n)"
read answer
if [ $answer != y ] ; then
	echo "Exiting"
	exit
fi
ssh-keygen -t rsa -C "Git Master@$domain"
cat ~/.ssh/id_rsa.pub > ~/git/pubkeys/authorized_keys
cd ~/git/pubkeys && git add .
git commit -am "Initial Commit"
cd ~/git/config
echo "Generating a key and certificate"
echo "Set the password to 'super'"
openssl genrsa -des3 -out server.key 4096
echo "Set the information below as requested"
openssl req -new -key server.key -out server.csr
echo "The password is 'super'"
openssl rsa -in server.key -out ssl.key
openssl x509 -req -in server.csr -signkey ssl.key -out ssl.cert
echo "Cert and Key generated"
echo "Cleaning up"
rm server.csr
rm server.key.org
echo "Commiting"
git add .
git commit -am "Initial Commit"
echo "Git commited"
cp -R ~/IRCSetupScripts/config/* ~/git/config/*
cd ~/git/config/
git add .
git commit -am "Adding in default configs"
echo "Setup complete"
echo "Please remember to properly edit the files in ~/git/config and then run sync.sh"
echo "Each time you make edits to anything in ~/git/config or ~/git/pubkeys please remember to run sync.sh"