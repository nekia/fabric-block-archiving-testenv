#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#


#
# This script is used on Debian based linux distros.
# (i.e., linux that supports the apt packaging manager.)
#

# Update system
sudo apt-get update -qq

# Install Python, pip, behave, nose
#
# install python-dev and libyaml-dev to get compiled speedups
sudo apt-get install --yes python
sudo apt-get install --yes python-pytest
sudo apt-get install --yes python-dev
sudo apt-get install --yes libyaml-dev

sudo apt-get install --yes python-setuptools
sudo apt-get install --yes python-pip
sudo apt-get install --yes build-essential
# required dependencies for cryptography, which is required by pyOpenSSL
# https://cryptography.io/en/stable/installation/#building-cryptography-on-linux
sudo apt-get install --yes libssl-dev libffi-dev
pip install --upgrade pip
# pip install behave
# pip install nose

# updater-server, update-engine, and update-service-common dependencies (for running locally)
# pip install -I flask==0.10.1 python-dateutil==2.2 pytz==2014.3 pyyaml==3.10 couchdb==1.0 flask-cors==2.0.1 requests==2.4.3 pyOpenSSL==16.2.0 pysha3==1.0b1

# Python grpc package for behave tests
# Required to update six for grpcio
# pip install --ignore-installed six
# pip install --upgrade 'grpcio==0.13.1'

# Pip packages required for some behave tests
# pip install ecdsa python-slugify b3j0f.aop
# pip install google
# pip install protobuf
# pip install pyyaml
# pip install pykafka
# pip install requests
# pip install pyexecjs
# pip install cython
# pip install psutil
# commenting out until we can get started using Java SDK in test runs
#pip install pyjnius

# Install Tcl prerequisites for busywork
sudo apt-get install --yes tcl tclx tcllib

# Install NPM for the SDK
#sudo apt-get install --yes npm

# Verify that go is installed
GO_VERSION=$(go version || /bin/true)
if [ -z "$GO_VERSION" ]; then
        echo "Go is not installed! Attempting to install now..."
        sudo apt-get install --yes golang-go
else
        echo "Go is installed. Version info: $GO_VERSION"
fi

# Install Govendor
go get -u github.com/kardianos/govendor

pip install --user -r requirements.txt
