#!/bin/bash

set -eux

oc get pods -A --field-selector spec.nodeName=$1
