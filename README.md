# Wordpress_script
This script is a command-line tool for managing WordPress sites using Docker and 
Docker Compose. It provides functionalities to create, enable/disable, and delete 
WordPress sites.
#Prerequisites
Before using this script, make sure you have the following dependencies installed on 
your Ubuntu system:
Docker
Docker Compose
If any of the dependencies are missing, the script will automatically install them for 
you
#Usage
To use this script, open your terminal and run the following command:
gitclone url of the repository 
After that you see script file then run this command:
./wordpress.sh [subcommand] [site_name]
#Subcommands
The script supports the following subcommands:
• create: Creates a new WordPress site with the specified site_name.
• enable: Enables a WordPress site by starting the containers associated with the 
site_name.
• disable: Disables a WordPress site by stopping the containers associated with 
the site_name.
• delete: Deletes a WordPress site by stopping the containers, removing files, 
and cleaning up associated configuration
#For Example:
To check if Docker and Docker Compose are installed: ./wordpress.sh check
To create a WordPress site: ./wordpress.sh create example.com
To enable the site (start the containers): ./wordpress.sh enable
To disable the site (stop the containers): ./wordpress.sh disable
To delete the site: ./wordpress.sh delete example.com
#Examples
Creating a WordPress site
To create a new WordPress site, use the create subcommand followed by the desired 
site_name. For example:
./wordpress.sh create example.com

Replace example.com with the desired name for your WordPress site

#Enabling or Disabling a WordPress site
To enable or disable a WordPress site, use the enable or disable subcommand 
followed by the site_name. For example, to enable a site:
./wordpress.sh enable example.com
#And to disable a site:
./wordpress.sh disable example.com
Replace example.com with the name of the WordPress site you want to enable or 
disable.
#Deleting a WordPress site
To delete a WordPress site, use the delete subcommand followed by the site_name. 
For example:
./wordpress.sh delete example.com
#Important Notes
• The script will automatically check for the presence of Docker and Docker 
Compose. If any of them are not installed, the script will install them for you.
• The script will create the necessary Docker Compose configuration files for 
each WordPress site in a directory named after the site_name.
• The script uses a default MySQL root password  for the database 
container. You may modify this as per your security requirements.
• The script adds an entry to the /etc/hosts file for each created site. This allows 
accessing the site in a web browser using the provided site_name

#IMPORTANT

After running the script you have to make an entry in your computer hosts file . 
Location for your hosts file is:
C:\Windows\System32\drivers\etc
here you find hosts file 
I this file you need you make an entry 
public ip of your instance site_name 
site_name the name you giving to your wordpress site
