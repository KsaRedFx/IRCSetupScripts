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
## for the irc network "Snoonet"                                                                                         ##
##                                                                                                                       ##
###########################################################################################################################

#########################################################
# Double Checking the shell
#########################################################
data=y
if [ $data = "y" ] ; then 
echo "Checks completed"
else
	exit
fi
#########################################################
# Hardcodes, Bypass the constant questions
#########################################################
#
# Only set things here if you know what you're doing!
#
#########################################################

bypass=n 					# If set to y will skip over items set below, default n
setup=n 					# This setting will allow you to skip over the instructions, not reccomended, default n
git=y 						# This setting is default y, if set to n will skip over any git moves

# Below are the network specific settings, if bypass is not set to y they will have no effect

mname=						# Name of the Master Git's user, example: git 
mnetwork=					# IP or Domain of the Master Git, example: 184.164.131.180 or git.network.org
ircname=					# Name of the IRC Network, example: OSPnet, Snoonet, EsperNet
domain=						# Root Domain for the IRC Network, example: ospnet.org, snoonet.com, esper.net

#########################################################
# Actual Script
#########################################################

cd ~
echo "Please enter new server's name, example: opal"
read name
echo "Please enter new server's IP, example: 184.164.131.181"
read network
echo "Server's name is $name"
echo "Server's IP is $network"
echo "Is this correct? (y/n)"
read answer
if [ $answer != y ] ; then
	echo "Exiting"
	exit
fi
if [ $bypass != y ] ; then
	echo "Please enter the git master's user, example: ircd"
	read mname
	echo "Please enter the git master's IP, example: 184.164.131.182"
	read mnetwork
	echo "Git Master's user is $mname"
	echo "Git Master's IP is $mnetwork"
	echo "SSH is $mname@$mnetwork"
	echo "Is this correct? (y/n)"
	read answer
	if [ $answer != y ] ; then
		echo "Exiting"
		exit
	fi
	echo "Please enter the irc network's name, example: OSPnet"
	read ircname
	echo "Please enter the irc network's domain, example: ospnet.org"
	read domain
	echo "The networks name is $ircname"
	echo "The domain name is $domain"
	echo "The operations name is $opname"
	echo "The user line will be servers+$name@$domain"
	echo "Is this correct? (y/n)"
	read answer
	if [ $answer != y ] ; then
		echo "Exiting"
		exit
	fi
fi
if [ $setup != y ] ; then
	echo ""
	echo ""
	echo ""
	echo "#####################################################################"
	echo "#####################################################################"
	echo ""
	echo "Before you let this script continue, please make sure you've installed all the required packages"
	echo "To do so, please run 'sudo apt-get install -y build-essential git bison flex libssl-dev'"
	echo ""
	if [ $git = y ] ; then
		echo "This script also assumes that you've already setup a Git Master using the master_setup.sh on a remote server"
	fi
	echo "Is this complete? (y/n)"
	read answer
	if [ $answer != y ] ; then
		echo "Exiting"
		exit
	fi
fi
echo "Continuing"
echo "Generating new key for servers+"$name"@$domain"
ssh-keygen -t rsa -C "servers+$name@$domain"
echo "Please place the key below in $mnetwork's authorized_keys"
echo ""
cat ~/.ssh/id_rsa.pub
echo ""
echo "Please confirm this is complete (y/n)"
read answer
if [ $answer != y ] ; then
	echo "Exiting"
	exit
fi
if [ $git = y ] ; then
	echo "cd ~/git/config && git remote add $name $USER@$name.$domain:git/config" > push.sh
	echo "cd ~/git/pubkeys && git remote add $name $USER@$name.$domain:git/pubkeys" >> push.sh
	echo "sed -n "\'"H"\;\$\{"x"\;"s"\/\^""\\\\"n"\/\/\;"s"\/"done."\*\$\/\t"git push "$name" master \\\\n"\&\/\;"p"\;\}\'" ~/sync > ~/syncx" >> push.sh
	echo "mv ~/syncx ~/sync;" >> push.sh
	echo "rm push.sh" >> push.sh
	echo "Copying files"
	rsync -vue ~/push.sh ssh $mname@$mnetwork:/home/$mname/push.sh 
	echo "Copy complete"
fi
echo "Copying, and Installing the ircd, please wait"
mkdir -p git && cd git
git clone git://github.com/snoonetIRC/charybdis.git && cd charybdis
./configure --prefix="$PWD/ircd" --enable-epoll --enable-openssl --enable-ipv6 --disable-assert
make
make install
if [ $git = y ] ; then
	echo "Complete, configuring"
	cd ~/git && git clone $mname@$mnetwork:git/config
	cd ~/git && git clone $mname@$mnetwork:git/pubkeys
	echo ""
	rm ~/ircd/etc/*
	cd ~/ircd/etc
	ln -s ~/git/config/dh.pem .
	ln -s ~/git/config/general.conf .
	ln -s ~/git/config/ircd.conf .
	ln -s ~/git/config/ircd.motd .
	ln -s ~/git/config/operators.conf .
	ln -s ~/git/config/ssl.cert .
	ln -s ~/git/config/ssl.key .
	echo "Links created"
	echo "Removing authorized_keys"
	rm -f ~/.ssh/authorized_keys && ln -s ~/git/pubkeys/authorized_keys ~/.ssh/authorized_keys
	echo "Authorized_keys replaced"
	echo "Setting up git and hooks file"
	git config --global 'receive.denyCurrentBranch' ignore
	echo "#"\!"/bin/bash" > ~/git/config/.git/hooks/post-receive &&\
	echo "cd .." >> ~/git/config/.git/hooks/post-receive &&\
	echo "env -i git reset --hard" >> ~/git/config/.git/hooks/post-receive
	echo "Git setup and hooks file created"
	chmod +x ~/git/config/.git/hooks/post-receive &&\
	cp ~/git/config/.git/hooks/post-receive ~/git/pubkeys/.git/hooks
	echo "Setting up server with Git on $mnetwork"
	echo "Connecting via ssh"
	ssh $mname@$mnetwork sh push.sh
	echo "SSH Connection closed"
	echo "Setup Git on $mnetwork with new server's information"
	echo "Cleaning Up"
	rm push.sh
	echo "Complete"
else
	echo "You opted out of git setup, only IRC has been installed, databases, configs, and keys were not setup"
fi
echo "Setting up config files"
echo ""
echo "######################### server.conf ################################"
echo ""
echo "listen {"
echo "    port = 5000, 6667 .. 6669;"
echo "    sslport = 6697;"
echo "};"
echo ""
echo "serverinfo {"
echo "    name = \"$name.$domain\";"
echo ""
echo "    sid = \"<unique digit, letter, letter>\";"
echo ""
echo "    description = \"$ircname leaf node.\";"
echo ""
echo "    network_name = \"$ircname.\";"
echo "    network_desc = \"$ircname network.\";"
echo ""
echo "    hub = no;"
echo ""
echo "    vhost = \"$network\";"
echo ""
echo "    ssl_private_key = \"etc/ssl.key\";"
echo "    ssl_cert = \"etc/ssl.cert\";"
echo "    ssh_dh_params = \"etc/dh.pem\";"
echo "    ssld_count = 5;"
echo ""
echo "    default_max_clients = 1000;"
echo ""
echo "    nicklen = 30;"
echo "};"
echo ""
echo "admin {"
echo "    name = \"$ircname admin.\";"
echo "    description = \"$ircname administrator.\";"
echo "    email = \"support@$domain\";"
echo "};"
echo ""
echo "connect \"<hub name>.$domain\" {"
echo "    host = \"<hub IP>\";"
echo "    send_password = \"<password hub is expecting>\";"
echo "    accept_password = \"<password your new server will expect from hub>\";"
echo "    port = 22223;"
echo "    hub_mask = \"*\";"
echo "    class = \"server\";"
echo "    flags = autoconn, compressed, topicburst, ssl;"
echo "};"
echo "###############################################################################"
echo "################################ hub config ###################################"
echo "connect \"$name.$domain\" {"
echo "    host = \"$network\";"
echo "    send_password = \"<password your new server will expect from hub>\";"
echo "    accept_password = \"<password hub is expecting>\";"
echo "    port = 22223;"
echo "    hub_mask = \"*\";"
echo "    class = \"server\";"
echo "    flags = compressed, topicburst, ssl;"
echo "};"
echo ""
echo "Please create and fill out a config file for the ircd in ~/ircd/etc with the name server.conf"
echo "Please also add this server to the hub config file"
