#!/bin/bash

set -ux

oc patch -n openshift-machine-api bmh/$1 -p '[{"op": "remove", "path": "/spec/userData"}]' --type json
oc patch -n openshift-machine-api bmh/$1 -p '[{"op": "remove", "path": "/spec/image"}]' --type json
