#!/bin/bash

#Remove old ansible as workaround for https://github.com/ansible/ansible-modules-core/issues/5144
dpkg -r ansible
apt-get autoremove -y

#install ansible 2.4.2 (latest stable in jan. 2018) with python $PYTHON_VER
# Dependencies
apt-get update
apt-get install -y autotools-dev blt-dev bzip2 dpkg-dev g++-multilib gcc-multilib libbluetooth-dev libbz2-dev libexpat1-dev libffi-dev libffi6 libffi6-dbg libgdbm-dev libgpm2 libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev libtinfo-dev mime-support net-tools netbase python-crypto python-mox3 python-dev python-pil python-pip python3-dev python3-pip python-ply quilt tk-dev zlib1g-dev

##
# Python from source
# PYTHON_VER="2.7.14"
# PYTHON_PATH=/usr/local/lib/python$PYTHON_VER
# # Compile Python
# cd /tmp
# wget https://www.python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz
# tar -xzvf Python-$PYTHON_VER.tgz
# cd Python-$PYTHON_VER/
# ./configure --prefix $PYTHON_PATH --enable-ipv6
# make -j4
# make install
# # Install pip
# wget https://bootstrap.pypa.io/get-pip.py
# $PYTHON_PATH/bin/python get-pip.py
# $PYTHON_PATH/bin/pip install --upgrade pip
# # Install ansible
# $PYTHON_PATH/bin/pip install ansible==2.4.2
# ln -s $PYTHON_PATH/bin/ansible* /usr/bin/
# # Back to home dir
# cd /root

##
# Use system python
# update pip and install ansible
pip install --upgrade pip
pip install ansible==2.4.2
pip install -U cryptography
pip install jmespath  # for json features in ansble

# workaround for https://github.com/ansible/ansible/issues/20332
sed -i 's:#remote_tmp:remote_tmp:' /etc/ansible/ansible.cfg
sed -i 's:#log_path:log_path:' /etc/ansible/ansible.cfg

# Install ansible roles
echo $role_list
IFS=','
###########################################
# NOTE: you can test a feature branch for #
# ansible roles using git clone instead   #
# of ansible-galaxy as follows:           #
###########################################
# for role in $role_list; do 
#      ansible-galaxy install indigo-dc.$role;
# done

###########################################
# NOTE: you can test a feature branch for #
# ansible roles using git clone instead   #
# of ansible-galaxy as follows:           #
###########################################
#
for role in $role_list; do 
  if [ "$role" == "mesos-rexray" ]; then
     git clone https://github.com/indigo-dc/ansible-role-mesos.git -b enable_dvdi_mod /etc/ansible/roles/indigo-dc.mesos
  elif [ "$role" == "htcondor_config" ]; then
     git clone https://github.com/indigo-dc/ansible-role-htcondor_config.git -b condor_base /etc/ansible/roles/indigo-dc.htcondor_config
  elif [ "$role" == "ams_config" ]; then
     git clone https://github.com/indigo-dc/ansible-role-ams_config.git -b condor_base /etc/ansible/roles/indigo-dc.ams_config
  elif [ "$role" == "gateway_config" ]; then
     git clone TODOURL -b master /etc/ansible/roles/Cloud-PG.gateway_config
  else
     ansible-galaxy install -vvv indigo-dc.$role;
  fi
done 
