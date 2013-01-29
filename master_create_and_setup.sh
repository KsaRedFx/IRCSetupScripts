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

echo "Please pick what part of the script you'd like to run"
echo "1) Intial Setup"
echo "2) Syncronisation"
echo "3) Install IRCD Remotely"

if [ $que = 1 ] ; then

	echo "Initial Setup Starting"
	echo "Are you sure this is what you want to do? (y/n)"
	read answer
	if [ $answer != y ] ; then
		echo "Exiting"
		exit
	fi

	echo "Please enter the IRC network's domain, example: ospnet.org"
	read domain
	echo "The IRC network's domain is $domain"

	echo "Is this correct? (y/n)"
	read answer
	if [ $answer != y ] ; then
		echo "Exiting"
		exit
	fi

	echo "Creating Directories"
	mkdir -p ~/.repo
	mkdir -p ~/.repo/keys
	mkdir -p ~/.repo/leaves
	mkdir -p ~/.repo/base
	mkdir -p ~/config

	echo "Creating Links"
	ln -s ~/.repo/keys ~/config/keys
	ln -s ~/.repo/leaves ~/config/leaves
	ln -s ~/.repo/base ~/config/base

	echo "Initialising Git"
	cd git && git init

	echo "Generating Key"
	ssh-keygen -t rsa -C "Git Master@$domain"
	cat ~/.ssh/id_rsa.pub > ~/configs/keys/authorized_keys

	echo "Please keep this key handy"
	cat ~/configs/keys/authorized_keys

	echo "Copying default configs"
	cp -R ~/IRCSetupScripts/config/* ~/config/base

	echo "Generating syncronisation script"
echo "#"\!"/bin/bash

sh .confs.sh



cd ~/.repo
git add .
git commit -am 'Snyc Update" > sync
echo "#"\!"/bin/bash

for item in ircd.motd ircd.conf operators.conf general.conf
do
	
done"

	echo ""
	echo "#####################################################################"
	echo "Generating SSL Certificate, Key, and DH Params"
	echo "You will be asked several questions, so pay attention"
	echo "#####################################################################"
	echo ""

	cd ~/config/base

	echo "Generating self-signed certificate ... "
	openssl req -x509 -nodes -newkey rsa:1024 -keyout ssl.key -out ssl.cert

	echo "Generating Diffie-Hellman file for secure SSL/TLS negotiation ... "
	openssl dhparam -out dh.pem 2048


fi

if [ $que = 2 ] ; then
	echo "Syncing"
	sh sync
	echo "Complete"
fi

if [ $que = 3 ] ; then

	echo ""
	echo "Please enter your new leaf's name, example: Opal"
	read name
	echo "Please enter your new leaf's IP, example: 184.164.131.180"
	read network
	echo "Please enter the name of the user you are installing the IRCD to"
	read user
	echo ""
	echo "Server's name is $name"
	echo "Server's IP is $network"
	echo "Server's user is $user"

	echo "Is this correct? (y/n)"
	read answer
	if [ $answer != y ] ; then
		echo "Exiting"
		exit
	fi

	if [ $bypass != y ] ; then

		echo ""
		echo "Please enter your IRC Network's name, example: OSPnet"
		read ircname
		echo "Please enter the IRC Network's root domain, example: ospnet.org"
		read domain
		echo ""
		echo "The IRC Network's name is $ircname"
		echo "The root domain name is $domain"
		
		echo "Is this correct? (y/n)"
		read answer
		if [ $answer != y ] ; then
			echo "Exiting"
			exit
		fi

		echo ""
		echo "Please place the below key in authorized_keys on the remote server"
		echo ""
		cat ~/.ssh/id_rsa.pub
		echo ""
		echo "Is this complete? (y/n)"
		read answer
		if [ $answer != y ] ; then
			echo "Exiting"
			exit
		fi

	fi
	if [ $info != y ] ; then

		echo ""
		echo "#####################################################################"
		echo "Before you let this script continue, please make sure you've installed all the required packages"
		echo "To do so, please run 'sudo apt-get install -y build-essential git bison flex libssl-dev'"
		echo ""
		echo "If you don't do this then the install will probably fail"
		echo "#####################################################################"
		echo ""
		
		echo "Is this complete? (y/n)"
		read answer
		if [ $answer != y ] ; then
			echo "Exiting"
			exit
		fi

	fi

	cd ~

	echo "Continuing"

	echo "Editing the sync script"
	sed -i "5irsync -vue ~/config/leaves/$name.conf ssh $user@$network:ircd/etc/server.conf" sync
	sed -i "5irsync -vue ~/config/base/\$item ssh $user@$network:ircd/etc" .confs.sh
	sed -i "5irsync -vue ~/config/keys/authorized_keys ssh $user@$network:.ssh/authorized_keys" sync

	echo "Preparing the IRCD install"
	echo "git clone git://github.com/snoonetIRC/charybdis.git && cd charybdis" > inst.sh
	echo './configure --prefix="$PWD/ircd" --enable-epoll --enable-openssl --enable-ipv6 --disable-assert' >> inst.sh
	echo "make" >> inst.sh
	echo "make install" >> inst.sh
	echo "rm inst.sh" >> inst.sh
	rsync -vue ~/inst ssh $user@$network:inst
	ssh $user@network sh inst
	echo "Install of IRCD Complete"

	echo "Setting up Config File"

	echo "listen {" > ~/config/leaves/$name.conf
	echo "    port = 5000, 6667 .. 6697;" >> ~/config/leaves/$name.conf
	echo "    sslport = 6697;" >> ~/config/leaves/$name.conf
	echo "};" >> ~/config/leaves/$name.conf
	echo "" >> ~/config/leaves/$name.conf
	echo "serverinfo {" >> ~/config/leaves/$name.conf
	echo "    name = \"$name.$domain\";" >> ~/config/leaves/$name.conf
	echo "" >> ~/config/leaves/$name.conf
	echo "    sid = \"<unique digit, letter, letter>\";" >> ~/config/leaves/$name.conf
	echo "" >> ~/config/leaves/$name.conf
	echo "    description = \"$ircname leaf node.\";" >> ~/config/leaves/$name.conf
	echo "" >> ~/config/leaves/$name.conf
	echo "    network_name = \"$ircname.\";" >> ~/config/leaves/$name.conf
	echo "    network_desc = \"$ircname network.\";" >> ~/config/leaves/$name.conf
	echo "" >> ~/config/leaves/$name.conf
	echo "    hub = no;" >> ~/config/leaves/$name.conf
	echo "" >> ~/config/leaves/$name.conf
	echo "    vhost = \"$network\";" >> ~/config/leaves/$name.conf
	echo "" >> ~/config/leaves/$name.conf
	echo "    ssl_private_key = \"etc/ssl.key\";" >> ~/config/leaves/$name.conf
	echo "    ssl_cert = \"etc/ssl.cert\";" >> ~/config/leaves/$name.conf
	echo "    ssh_dh_params = \"etc/dh.pem\";" >> ~/config/leaves/$name.conf
	echo "    ssld_count = 5;" >> ~/config/leaves/$name.conf
	echo "" >> ~/config/leaves/$name.conf
	echo "    default_max_clients = 1000;" >> ~/config/leaves/$name.conf
	echo "" >> ~/config/leaves/$name.conf
	echo "    nicklen = 30;" >> ~/config/leaves/$name.conf
	echo "};" >> ~/config/leaves/$name.conf
	echo "" >> ~/config/leaves/$name.conf
	echo "admin {" >> ~/config/leaves/$name.conf
	echo "    name = \"$ircname admin.\";" >> ~/config/leaves/$name.conf
	echo "    description = \"$ircname administrator.\";" >> ~/config/leaves/$name.conf
	echo "    email = \"support@$domain\";" >> ~/config/leaves/$name.conf
	echo "};" >> ~/config/leaves/$name.conf
	echo "" >> ~/config/leaves/$name.conf
	echo "connect \"<hub name>.$domain\" {" >> ~/config/leaves/$name.conf
	echo "    host = \"<hub IP>\";" >> ~/config/leaves/$name.conf
	echo "    send_password = \"<password hub is expecting>\";" >> ~/config/leaves/$name.conf
	echo "    accept_password = \"<password your new server will expect from hub>\";" >> ~/config/leaves/$name.conf
	echo "    port = 22223;" >> ~/config/leaves/$name.conf
	echo "    hub_mask = \"*\";" >> ~/config/leaves/$name.conf
	echo "    class = \"server\";" >> ~/config/leaves/$name.conf
	echo "    flags = autoconn, compressed, topicburst, ssl;" >> ~/config/leaves/$name.conf
	echo "};" >> ~/config/leaves/$name.conf

	echo ""
	echo "####################################################################"
	echo "Config file setup and placed in ~/config/leaves/$name.conf"
	echo "Please edit this file accordingly then run the sync option"
	echo "####################################################################"

	nano ~/config/leaves/$name.conf

	sh ~/sync

fi