# Vagrant
# Setup system
* Install Vagrant:
https://www.vagrantup.com/downloads.html

wget -O vagrant.deb https://releases.hashicorp.com/vagrant/2.0.2/vagrant_2.0.2_x86_64.deb

sudo dpkg -i vagrant.deb
* Install VirtualBox:

sudo apt-get install virtualbox
* Install Git:

sudo apt-get install git
# Run box:
git clone https://github.com/cscart/vagrant-boxes.git

cd Vagrant/vagrant/php(version)

sudo vagrant up

# Enter in box:
sudo vagrant ssh
# Shutdown box:

sudo vagrant halt #for stop machine 

and

sudo vagrant up #for start machine

or 

sudo vagrant destroy #for destroing machine
