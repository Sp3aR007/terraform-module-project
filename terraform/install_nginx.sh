#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
echo "Hello World from $(hostname -f)" > /usr/share/nginx/html/index.html