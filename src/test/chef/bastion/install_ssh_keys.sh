#!/bin/sh

VAGRANT_USER_SSH=/home/vagrant/.ssh

echo "Installing app and web server security keys in $VAGRANT_USER_SSH"

cp -f /vagrant/*.pem $VAGRANT_USER_SSH/
chown vagrant:vagrant $VAGRANT_USER_SSH/*.pem
chmod 400 $VAGRANT_USER_SSH/*.pem