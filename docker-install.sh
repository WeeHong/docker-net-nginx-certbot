#!/bin/bash

echo -e "Checking Docker and Docker Compose exist ..."
if [ -x "$(command -v docker)" ]; then
    echo "Docker exists. Proceed to next step."
    exit
    # command
else
    echo -e "Docker cannot be found in the system."
    read -p "Do you want to install Docker? (y/N) " decision
    if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
        exit
    fi

    if ! command -v apt-get &> /dev/null 
    then
        echo "apt-get command could not be found"
        exit
    fi

    echo -e "Installing ..."
    sudo apt-get install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y

    sudo apt-get install docker-ce docker-ce-cli containerd.io -y

    echo -e "Completed."
fi


echo -e "Checking Docker Compose exists ..."
if [ -x "$(command -v docker-compose)" ]; then
    echo "Docker compose exists. Proceed to next step."
    exit
else
    echo -e "Docker Compose cannot be found in the system."
    read -p "Do you want to install Docker Compose? (y/N) " decision
    if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
        exit
    fi

    if ! command -v apt-get &> /dev/null 
    then
        echo "apt-get command could not be found"
        exit
    fi

    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    sudo chmod +x /usr/local/bin/docker-compose

    echo -e "Completed."
fi
