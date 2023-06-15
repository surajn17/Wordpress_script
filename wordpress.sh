#!/bin/bash

check_dependencies() {
    # Check if docker is installed
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed. Installing..."
        install_docker
    fi

    # Check if docker-compose is installed
    if ! command -v docker-compose &> /dev/null; then
        echo "Docker Compose is not installed. Installing..."
        install_docker_compose
    fi
}

install_docker() {
    # Update the system packages
    sudo apt update

    # Install required dependencies for Docker
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add Docker repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update the packages again
    sudo apt update

    # Install Docker
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    # Add the current user to the "docker" group
    sudo usermod -aG docker "$USER"
}

install_docker_compose() {
    # Download Docker Compose
    sudo curl -fsSL -o /usr/local/bin/docker-compose https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)

    # Apply executable permissions
    sudo chmod +x /usr/local/bin/docker-compose
}

create_wordpress_site() {
    site_name=$1

    # Create the site directory
    mkdir "$site_name"
    cd "$site_name"

    # Create docker-compose.yml
    cat << EOF > docker-compose.yml
version: '3'
services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress

  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    volumes:
      - ./wp-content:/var/www/html/wp-content
    restart: always
    ports:
      - "8000:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress

volumes:
  db_data:
EOF

    # Start the containers
    docker-compose up -d
}

add_hosts_entry() {
    site_name=$1
    echo "127.0.0.1 $site_name" | sudo tee -a /etc/hosts > /dev/null
}

open_in_browser() {
    site_name=$1
    echo "Open http://$site_name in a browser."
}

enable_site() {
    docker-compose start
}

disable_site() {
    docker-compose stop
}

delete_site() {
    site_name=$1
    cd "$site_name"
    docker-compose down
    cd ..
    rm -rf "$site_name"
}

# Main script logic
case $1 in
    check)
        check_dependencies
        ;;
    create)
        if [ -z "$2" ]; then
            echo "Please provide a site name."
            exit 1
        fi
        check_dependencies
        create_wordpress_site "$2"
        add_hosts_entry "$2"
        open_in_browser "$2"
        ;;
    enable)
        check_dependencies
        enable_site
        ;;
    disable)
        check_dependencies
        disable_site
        ;;
    delete)
        if [ -z "$2" ]; then
            echo "Please provide a site name."
            exit 1
        fi
        check_dependencies
        delete_site "$2"
        ;;
    *)
        echo "Usage: $0 {check|create <site_name>|enable|disable|delete <site_name>}"
        exit 1
        ;;
esac

exit 0 
