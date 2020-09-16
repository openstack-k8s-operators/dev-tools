#!/bin/bash

set -eux

oc patch -n openshift-machine-api bmh/$1 -p '{"spec":{"online":false}}' --type merge
