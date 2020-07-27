#!/bin/bash

set -eux

# Each of these patches are already in 16.1, however not in 16.0z1.
cd /usr/share/openstack-tripleo-heat-templates; curl https://review.opendev.org/changes/706850/revisions/8316a6142b4748370cf11e61df1bbbb0ca5a14b3/patch?download | base64 -d | patch -p1 -t || :
cd /usr/lib/python3.6/site-packages; curl https://review.opendev.org/changes/706852/revisions/629a35f00b62ebae25e805835cb0d53fbac935a8/patch?download | base64 -d | patch -p1 -t || :
cd /usr/share/ansible; curl https://review.opendev.org/changes/706846/revisions/edbaa07ea440de7e1bcb56d90c794463d6bc1ce2/patch?download | base64 -d | patch -p2 -t || :
cd

sed -i "/# We only get here if no errors/a \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ rc=0" /usr/lib/python3.6/site-packages/tripleoclient/v1/tripleo_deploy.py
sed -i "s/clouds_home_dir = .*/clouds_home_dir = os.path.expanduser('~')/" /usr/lib/python3.6/site-packages/tripleoclient/utils.py

rm -rf /root/tripleo-deploy/cnv-ansible*

openstack tripleo deploy \
    --templates /usr/share/openstack-tripleo-heat-templates \
    -r /config/roles-data.yaml \
    -n /usr/share/openstack-tripleo-heat-templates/network_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/overcloud-resource-registry-puppet.yaml \
    -e /config/passwords.yaml \
    -e /config/stack-action-create.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/deployed-server-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker-ha.yaml \
    -e /config/deploy-identifier.yaml \
    -e /config/network-environment.yaml \
    -e /config/role-counts.yaml \
    -e /config/hostnamemap.yaml \
    -e /config/deployed-server-port-map.yaml \
    -e /config/root-stack-name.yaml \
    -e /config/glance-backend-nfs.yaml \
    -e /config/containers-prepare-parameter.yaml \
    -e /config/custom.yaml \
    -e /config/software-config-transport.yaml \
    --stack cnv \
    --output-dir /root/tripleo-deploy \
    --standalone \
    --local-ip 192.168.24.6 \
    --deployment-user root \
    --output-only

cd /root/tripleo-deploy
output_dir=$(ls -dtr cnv-ansible-* | tail -1)
ln -sf ${output_dir} cnv-ansible
cd ${output_dir}
sed -i '/transport/d' ansible.cfg
sed -i "/blockinfile/a \ \ \ \ unsafe_writes: yes" /usr/share/ansible/roles/tripleo-hosts-entries/tasks/main.yml

ansible-playbook -i inventory.yaml --become deploy_steps_playbook.yaml

cp /etc/openstack/clouds.yaml /root/tripleo-deploy/
