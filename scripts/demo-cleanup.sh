#!/bin/bash

set -ux

SCRIPT_PATH=$(dirname $(realpath $0))

$SCRIPT_PATH/deprovision.sh

oc get crds | grep openstack.org | cut -f1 -d ' ' | xargs -r -t oc delete crds --cascade

oc delete --ignore-not-found namespace openstack
