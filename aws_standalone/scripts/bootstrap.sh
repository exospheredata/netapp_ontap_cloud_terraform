#!/bin/bash
set -e
exists()
{
  command -v "$1" >/dev/null 2>&1
}

if ! exists git; then
  yum install -y git
fi

if ! exists chef-solo; then
  echo "Install Chef-Solo"
  curl -L https://www.opscode.com/chef/install.sh | bash
fi

if ! exists chef; then
  wget -nv https://packages.chef.io/files/stable/chefdk/1.5.0/el/7/chefdk-1.5.0-1.el7.x86_64.rpm
  yum install -y chefdk-1.5.0-1.el7.x86_64.rpm
fi

location=${PWD}
cd /tmp/ontap_cloud_cookbooks && \
  berks package --berksfile=Berksfile && \
  mv cookbooks-*.tar.gz /tmp/cookbooks.tar.gz
cd $location

echo "Remove existing chef files and configurations"
rm -rf /var/chef/cookbooks /var/chef/data_bags /var/chef/solo.rb /var/chef/dna.json

echo "Setup the repositories"
mkdir -p /var/chef/cookbooks /var/chef/data_bags
chmod -R 777 /var/chef

mv /tmp/chef/* /var/chef/

rm -rf /tmp/chef
echo "Start the CHEF Client and configuration bootstrap"
`which chef-solo` --recipe-url /tmp/cookbooks.tar.gz -c /var/chef/solo.rb -j /var/chef/dna.json -l info
