#!/bin/bash

set -eux

oc scale -n openshift-machine-api --replicas $2 machineset $1
