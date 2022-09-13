#!/bin/bash

## Purpose: This script produces a report of all instances across all regions across your tenancy that are in a "STOPPED" state.
## How to run : (a) from the OCI Cloud Shell
##              (b) from a Linux host where OCI CLI is installed.

for i in $(oci iam region-subscription list --query "data[].\"region-name\"" | jq '.[]' | sed 's/"//g')
do
  echo "Region: " $i
  oci search resource structured-search \
    --region $i \
    --query-text "QUERY instance resources where lifeCycleState = 'STOPPED' " \
    --query 'data.items[*].{ad:"availability-domain",instancename:"display-name"}' --output table
done
