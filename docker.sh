#!/bin/bash
# Description: Script to  Containerize a WordPress Application 
# Developer: Okiki Olumide

wp_folder=wordpress_folder/
repo=https://github.com/wordpress/wordpress

#Install Docker 
sudo apt-get update -y
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose -y


# Create local WordPress folder 
mkdir $wp_folder
cd $wp_folder

# Clone default wordpress folder with contents
git clone $repo

cat > .env << EOF

    mysql_root=somewordpress
    mysql_db=wordpress
    mysql_user=wordpress
    mysql_pass=wordpress

    wordpress_db_host=db
    wordpress_db_user=wordpress
    wordpress_db_password=wordpress
    wordpress_db_name=wordpress

EOF

cat > docker-compose.yml << EOF

    version: "3.3"
    services:
        db:
            image: mysql:5.7
            volumes: 
                - db_data:/var/lib/mysql
            restart: always
            environment:
                MYSQL_ROOT_PASSWORD: ${mysql_root}
                MYSQL_DATABASE: ${mysql_db}
                MYSQL_USER: ${mysql_user}
                MYSQL_PASSWORD: ${mysql_pass}
        
        wordpress:
            depends_on:
                - db
            image: wordpress:latest
            volumes:
                - wordpress_data:/var/www/html
            ports:
                - "8080:80"
            restart: always
            environment:
                WORDPRESS_DB_HOST: ${wordpress_db_host}
                WORDPRESS_DB_USER: ${wordpress_db_user}
                WORDPRESS_DB_NAME: ${wordpress_db_name}
                WORDPRESS_DB_PASSWORD: ${wordpress_db_password}
    
    volumes:
        db_data: {}
        wordpress_data: {}
EOF

# Build Project
service docker restart
sudo docker-compose up -d


