#!/bin/bash

# Update package lists and install Apache web server
echo "Updating package lists..."
sudo apt-get update -y

echo "Installing Apache web server..."
sudo apt-get install apache2 -y

# Get the hostname
hostname=$(hostname)

# Create a simple index.html displaying the hostname
echo "<html>
  <head><title>Hostname</title></head>
  <body>
    <h1>Welcome to the web server!</h1>
    <p>Hostname: $hostname</p>
  </body>
</html>" | sudo tee /var/www/html/index.html

# Start and enable Apache service
echo "Starting Apache service..."
sudo systemctl start apache2

echo "Enabling Apache service to start on boot..."
sudo systemctl enable apache2

echo "Apache web server is running. Access it via http://<server-ip>/"
