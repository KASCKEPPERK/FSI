#!/bin/bash

setup_user() {
  USERNAME=$1
  PASSWORD=$2

  echo "--------------------------------------"
  echo "Setting up: $USERNAME"

  sudo adduser "$USERNAME" --disabled-password --gecos ""
  echo "$USERNAME:$PASSWORD" | sudo chpasswd

  sudo -u "$USERNAME" google-authenticator -t -d -f -w 3 -q

  SECRET=$(sudo head -n 1 /home/"$USERNAME"/.google_authenticator)
  echo "SUCCESS: User $USERNAME created."
  echo "SECRET KEY FOR APP: $SECRET"
  echo "--------------------------------------"
}

setup_user "roadwarrior1" "Warrior1"
setup_user "roadwarrior2" "Warrior2"
