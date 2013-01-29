IRCSetupScripts
===============
 
 
A Simple set of scripts and files for people to start their own IRC Network with!
 
This is a simple system for setting up your own IRC Network with syncronised files accross all your servers.
 
There are two methods for setting up a IRC Network...
 
 
~ Warning! This does NOT Setup the Hub or SSL Certificates yet ~
    
    
    
    
    
    
Git Master Setup;
-----------------
 
This method runs from multiple servers and does not track server.conf
 
This method has a bit less security
 
 
Instructions:
 
Simply clone this repository into the home of a fresh user on a server you'll call your "Git Master"   
Then run "sh masther_create.sh" inside via_git to setup the Master Git
 
To install an IRCD simply clone this repository into the home of a fresh user on a server you're installing to   
Then run "sh simple_setup.sh" inside the via_git directory, and follow the instructions
 
Remember to edit all your configs before booting the IRCD
 
Run "sh sync.sh" in the home directory each time you update your configs
 
 
RSYNC Master Setup;
-------------------
 
This method pushes all the updated configs from the Master Repo to all your leaves 
 
This method is a bit more secure
 
 
Instructions:
 
Simply clone this repostiroy into the home of a fresh user on a server you'll call your "RSNYC Master"   
Then run option #1 to setup the initial system, remember to follow the steps carefully.
 
To install an IRCD simply run step #3 of the script from the "RSNYC Master"   
This method does all the work for you other then setting the initial ssh key into the remote server's authorized_keys
 
Once you're done, run option #2 to syncronise the Master and Leaves   
Each time you update your config, run #2 to update everything.
