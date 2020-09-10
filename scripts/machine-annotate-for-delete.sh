#!/bin/bash

set -eux

worker=$(oc get node/$1 -o json | jq -r '.metadata.annotations["machine.openshift.io/machine"]' | cut -d/ -f2)
oc annotate -n openshift-machine-api machines $worker machine.openshift.io/cluster-api-delete-machine=1 --overwrite
