# Wordpress_script
This script is a command-line tool for managing WordPress sites using Docker and 
Docker Compose. It provides functionalities to create, enable/disable, and delete 
WordPress sites.
Prerequisites
Before using this script, make sure you have the following dependencies installed on 
your Ubuntu system:
Docker
Docker Compose
If any of the dependencies are missing, the script will automatically install them for 
you
Usage
To use this script, open your terminal and run the following command:
gitclone url of the repository 
After that you see script file then run this command:
./wordpress.sh [subcommand] [site_name]
Subcommands
The script supports the following subcommands:
• create: Creates a new WordPress site with the specified site_name.
• enable: Enables a WordPress site by starting the containers associated with the 
site_name.
• disable: Disables a WordPress site by stopping the containers associated with 
the site_name.
• delete: Deletes a WordPress site by stopping the containers, removing files, 
and cleaning up associated configuration
For Example:
To check if Docker and Docker Compose are installed: ./wordpress.sh check
To create a WordPress site: ./wordpress.sh create example.com
To enable the site (start the containers): ./wordpress.sh enable
To disable the site (stop the containers): ./wordpress.sh disable
To delete the site: ./wordpress.sh delete example.com
