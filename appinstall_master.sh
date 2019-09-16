#!/bin/bash

#Non-standard and non-Amazon machine image python modules:

sudo echo "Starting the installation and configuration of master node"
if [ `grep 'isMaster' /mnt/var/lib/info/instance.json | awk -F ':' '{print $2}' | awk -F ',' 'print $1'` = 'false' ]; then
  echo "Slave"
  exit
fi

sudo echo "Creating Directories"

sudo mkdir -p /usr/share/nginx/html/static
sudo mkdir -p /etc/spark/sparkui/static
sudo mkdir -p /usr/share/nginx/html/sparkui/static
sudo mkdir -p /usr/share/nginx/logs
sudo mkdir -p /usr/share/nginx/html/_dash-component-suites/dash-renderer/
sudo mkdir -p /usr/share/nginx/html/_dash-component-suites/dash-core-components/
sudo mkdir -p /usr/share/nginx/html/_dash-component-suites/dash_html_components/
sudo mkdir -p /etc/flame
sudo mkdir -p /home/scripts

#Create the log file
sudo echo "Creating log file"
sudo touch /usr/share/nginx/logs/host.access.logs

#Get the public and private name of the master node

sudo echo "Getting public and private name of the master node"
temp_publicname=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
temp_privatename=$(curl -s http://169.254.169.254/latest/meta-data/local-hostname)

#Configuring livy
#Configuring sparku

#change the nginx config for nginx
sudo echo "Configuring Nginx"
cd /etc/nginx
sudo cp nginx.conf nginx.conf_copy
sudo rm -f nginx.config
sudo aws s3 cp s3://ux/nginx.conf .

sudo echo "Configuring Nginx timeout"
cd /etc/nginx/conf.d
sudo aws s3 cp s3://ux/timeout.conf .
#sudo chmod 755 nginx.config
#sudo sed -i "s/InterNalIP/$temp_privatename/g" nginx.config

#start nginx server
sudo service nginx stop
sleep 3
sudo service nginx start

#Copying dash static files for nginx
sudo echo "Copy dash static files"
if [ -d "/usr/local/lib/python3.6/site-packages/dash_core_components" ]; then
sudo cp /usr/local/lib/python3.6/site-packages/dash_renderer/* /usr/share/nginx/html/_dash-component-suites/dash_renderer/
sudo cp /usr/local/lib/python3.6/site-packages/dash_core_components/* /usr/share/nginx/html/_dash-component-suites/dash_core_components/
sudo cp /usr/local/lib/python3.6/site-packages/dash_html_components/* /usr/share/nginx/html/_dash-component-suites/dash_html_components/
fi
if [ -d "/usr/lib/python3.6/dist-packages/dash_core_components/" ]; then
sudo cp /usr/lib/python3.6/dist-packages/dash_core_components/* /usr/share/nginx/html/_dash-component-suites/dash_core_components/
sudo cp /usr/lib/python3.6/dist-packages/dash_html_components/* /usr/share/nginx/html/_dash-component-suites/dash_html_components/
fi

#Configuring livy running port
#Configuring Zeppelin

#Setup files for flame graphs

#sudo echo "Setting up flame graphs"
#cd /etc/flame
#sudo aws s3 cp s3://ux/FlameGraph-master.zip .
#sudo unzip FlameGraph-master.unzip

#Copy the scripts from s3 to local

sudo echo "Copying files from s3 to local"

cd /home/scripts
echo $PWD
#sudo aws s3 cp s3://ux/jobs.py .
#sudo aws s3 cp s3://ux/app.py .
#sudo aws s3 cp s3://ux/jobp.py .
#sudo aws s3 cp s3://ux/appp.py .
#sudo aws s3 cp s3://ux/forecastquater_1.py .
sudo aws s3 cp s3://ux/constants.py .
sudo aws s3 cp s3://ux/utils.py .
sudo aws s3 cp s3://ux/wrapper.py .
sudo aws s3 cp s3://ux/base.py .
sudo aws s3 cp s3://ux/forecast_original.csv .

# Change file permissions
sudo chmod +x *.py
sudo mv *.py /home/scripts

#Set the alias for python3
sudo export alias python3="/usr/bin/python3"

sudo docker exec jupyterhub bash -c "conda install -c conda-forge dash"
sudo echo "App installation on Master finished"
