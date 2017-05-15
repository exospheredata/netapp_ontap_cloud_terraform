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

echo "Remove existing chef files and configurations"
rm -rf /var/chef/cookbooks /var/chef/data_bags /var/chef/solo.rb /var/chef/dna.json

echo "Setup the repositories"
mkdir -p /var/chef/cookbooks /var/chef/data_bags
chmod -R 777 /var/chef

location=${PWD}
cd /var/chef/cookbooks
git clone https://github.com/exospheredata/netapp_ontap_cloud.git > /dev/null 2>&1
cd netapp_ontap_cloud

echo 'Clean up files not required for CHEF actions'
rm -rf tasks
rm -rf test
rm -rf spec
rm -rf terraform
cd $location

mv /tmp/chef/* /var/chef/

rm -rf /tmp/chef
echo "Start the CHEF Client and configuration bootstrap"
`which chef-solo` -c /var/chef/solo.rb -j /var/chef/dna.json -L /var/chef/client.log -l info
