#!/bin/bash

set -eux
oc get bmh -o custom-columns=NAME:.metadata.name,STATUS:.status.operationalStatus,PROVISIONING:.status.provisioning.state,CONSUMER:.spec.consumerRef.name,POWER:.status.poweredOn
