#!/bin/bash

set -ux

SCRIPT_PATH=$(dirname $(realpath $0))

if [ "$1" = "" ]; then
    nodes=$(oc get nodes | grep worker-osp | cut -d' ' -f1)
    machines=$(oc get -n openshift-machine-api machines | grep worker-osp | cut -d' ' -f1)
    hosts=$(oc get -n openshift-machine-api baremetalhosts | grep worker-osp | cut -d' ' -f1)
else
    hosts="$1"
    machines=$(oc get bmh $1 -o custom-columns=CONSUMER:.spec.consumerRef.name --no-headers)
    nodes=$(oc get machine -o json $machines | jq .status.nodeRef.name)
fi

$SCRIPT_PATH/machineset-scale.sh ostest-worker-osp 0

for machine in $machines; do
    $SCRIPT_PATH/machine-delete-finalizers.sh $machine
done

for node in $nodes; do
    oc delete node $node
    oc patch -n openstack pod ${node}-blocker-pod  -p '{"metadata":{"finalizers":[]}}' --type merge
done

for host in $hosts; do
    $SCRIPT_PATH/baremetalhost-delete-consumerRef.sh $host
    $SCRIPT_PATH/baremetalhost-deprovision.sh $host
    $SCRIPT_PATH/baremetalhost-poweroff.sh $host
done
