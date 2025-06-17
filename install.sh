#!/bin/bash
# install.sh - Install and set up environements requeired for the RAVEN workflow.

set -euo pipefail

echo "Installing Conda Environments"
for env_file in envs/*.yml; do
 echo "Installing: $env_file"
 conda env create -f "$env_file" || conda env update -f "$env_file"
done

echo "All environments installed"