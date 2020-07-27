#!/bin/bash

set -x

worker=$(oc get node/worker-4 -o json | jq -r '.metadata.annotations["machine.openshift.io/machine"]' | cut -d/ -f2)
oc annotate -n openshift-machine-api machines $worker machine.openshift.io/cluster-api-delete-machine=1

oc rsh pod/openstackclient openstack server delete demo-scale

oc scale -n openshift-machine-api machineset/ostest-worker-osp-0 --replicas 1

id=$(oc rsh pod/openstackclient openstack compute service list | grep worker-4 | awk '{print $2}')
oc rsh pod/openstackclient openstack compute service delete $id

oc scale -n openshift-machine-api machineset/ostest-worker-0 --replicas 5

id=$(ssh -q -t root@undercloud sudo -u stack ssh -q -t 192.168.25.21 sudo -i podman exec -it ovn-dbs-bundle-podman-0 ovn-sbctl --format json find Chassis hostname=worker-4 | jq -r .data[0][4])
ssh -q -t root@undercloud sudo -u stack ssh -q -t 192.168.25.21 sudo -i podman exec -it ovn-dbs-bundle-podman-0 ovn-sbctl chassis-del $id

ssh -q -t root@undercloud sudo -u stack ssh -q -t 192.168.25.20 sudo -i systemctl stop tripleo_neutron_api
ssh -q -t root@undercloud sudo -u stack ssh -q -t 192.168.25.21 sudo -i systemctl stop tripleo_neutron_api
ssh -q -t root@undercloud sudo -u stack ssh -q -t 192.168.25.22 sudo -i systemctl stop tripleo_neutron_api
ssh -q -t root@undercloud sudo -u stack ssh -q -t 192.168.25.20 sudo -i systemctl start tripleo_neutron_api
ssh -q -t root@undercloud sudo -u stack ssh -q -t 192.168.25.21 sudo -i systemctl start tripleo_neutron_api
ssh -q -t root@undercloud sudo -u stack ssh -q -t 192.168.25.22 sudo -i systemctl start tripleo_neutron_api

oc rsh pod/openstackclient openstack server list
oc rsh pod/openstackclient openstack compute service list
oc rsh pod/openstackclient openstack network agent list
oc rsh pod/openstackclient openstack hypervisor stats show
