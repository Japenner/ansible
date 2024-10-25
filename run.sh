#!/usr/bin/env bash

# Check if a filename is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <playbook-file>"
  exit 1
fi

# Run the specified Ansible playbook
ansible-playbook --ask-vault-pass --ask-become-pass "$1"
