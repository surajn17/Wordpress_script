#!/bin/bash

check_package() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

install_package() {
    echo "Installing $1..."
    if [[ $1 == "docker" ]]; then
       yum install -y docker
       systemctl restart docker
       systemctl enable docker
    elif [[ $1 == "docker-compose" ]]; then
       sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose version
    fi
    echo "$1 installed successfully."
}

# Check if Docker and Docker Compose are installed, and install if necessary
if ! check_package "docker"; then
    echo "Docker is not installed. Installing Docker..."
    install_package "docker"
else
    echo "Docker is already installed."
fi

if ! check_package "docker-compose"; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    install_package "docker-compose"
else
    echo "Docker Compose is already installed."
fi

create_wordpress_site() {
    site_name="$1"
    wordpress_version=$(curl -sL https://api.wordpress.org/core/version-check/1.7/ | jq -r '.offers[0].version')
    wordpress_dir="$PWD/$site_name"

    # Check if WordPress is already installed
    if [[ -d "$wordpress_dir" ]]; then
        echo "WordPress is already installed for the site: $site_name"
        exit 0
    fi

    # Create the site directory
    mkdir -p "$wordpress_dir"

    # Create docker-compose.yml file
    cat <<EOF > "$wordpress_dir/docker-compose.yml"
version: '3'
services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: 123
      MYSQL_DATABASE: $site_name

  wordpress:
    depends_on:
      - db
    image: wordpress:$wordpress_version
    ports:
      - 80:80
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_NAME: $site_name
      WORDPRESS_DB_USER: root
      WORDPRESS_DB_PASSWORD: 123
    volumes:
      - ./wp-content:/var/www/html/wp-content

volumes:
  db_data:
EOF

    # Create /etc/hosts entry
    echo "127.0.0.1 $site_name" | sudo tee -a /etc/hosts

    # Start the containers
    echo "Starting the containers..."
    cd "$wordpress_dir"
    docker-compose up -d

    # Check if the site is up and healthy
    echo "Checking if the site is up and healthy..."
    until $(curl --output /dev/null --silent --head --fail http://$site_name); do
        sleep 1
    done

    echo "WordPress site $site_name created successfully."
    echo "Open http://$site_name in your browser."

    cd - >/dev/null
}

enable_disable_site() {
    site_name="$1"
    wordpress_dir="$PWD/$site_name"

    # Check if the site directory exists
    if [[ ! -d "$wordpress_dir" ]]; then
        echo "WordPress is not installed for the site: $site_name"
        exit 1
    fi

    # Check the current state of the containers
    containers_running=$(docker-compose -f "$wordpress_dir/docker-compose.yml" ps -q | wc -l)

    if [[ $containers_running -eq 0 ]]; then
        # Start the containers
        echo "Starting the containers for site: $site_name"
        cd "$wordpress_dir"
        docker-compose up -d
        echo "Site $site_name enabled successfully."
    else
        # Stop the containers
        echo "Stopping the containers for site: $site_name"
        cd "$wordpress_dir"
        docker-compose down
        echo "Site $site_name disabled successfully."
    fi

    cd - >/dev/null
}

delete_site() {
    site_name="$1"
    wordpress_dir="$PWD/$site_name"

    # Check if the site directory exists
    if [[ ! -d "$wordpress_dir" ]]; then
        echo "WordPress is not installed for the site: $site_name"
        exit 1
    fi

    # Stop and remove the containers
    echo "Stopping and removing the containers for site: $site_name"
    cd "$wordpress_dir"
    docker-compose down

    # Remove the site directory
    echo "Removing the site directory: $site_name"
    cd ..
    rm -rf "$site_name"

    # Remove /etc/hosts entry
    echo "Removing the /etc/hosts entry for site: $site_name"
    sudo sed -i "/$site_name/d" /etc/hosts

    echo "Site $site_name deleted successfully."
}

# Parse the command-line arguments
if [[ $# -eq 0 ]]; then
    echo "Please provide a subcommand: create, enable/disable, delete."
    exit 1
fi

subcommand="$1"
shift

case "$subcommand" in
    create)
        if [[ $# -eq 0 ]]; then
            echo "Please provide the site name as an argument for the 'create' subcommand."
            exit 1
        fi
        create_wordpress_site "$1"
        ;;
    enable|disable)
        if [[ $# -eq 0 ]]; then
            echo "Please provide the site name as an argument for the 'enable/disable' subcommand."
            exit 1
        fi
        enable_disable_site "$1"
        ;;
    delete)
        if [[ $# -eq 0 ]]; then
            echo "Please provide the site name as an argument for the 'delete' subcommand."
            exit 1
        fi
        delete_site "$1"
        ;;
    *)
        echo "Invalid subcommand. Available subcommands: create, enable/disable, delete."
        exit 1
        ;;
esac
