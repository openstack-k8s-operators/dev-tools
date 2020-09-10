#!/bin/bash

set -eux

oc patch machines  -p '{"metadata":{"finalizers":[]}}' --type merge $1
