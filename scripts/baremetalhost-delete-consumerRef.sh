#!/bin/bash

set -eux

oc patch -n openshift-machine-api bmh/$1 -p '[{"op": "remove", "path": "/spec/consumerRef"}]' --type json
