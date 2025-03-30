#!/bin/bash

sudo dnf install -y ansible
sudo ansible-galaxy collection install -r requirements.yml
