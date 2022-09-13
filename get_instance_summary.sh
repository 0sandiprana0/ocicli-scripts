#!/bin/bash

## Author: Sandip Rana
## Purpose: This script produces a summary report of instances across all regions across your tenancy. 
##          It will include the lifecycle state of the Compute instance.
## How to run : (a) from the OCI Cloud Shell
##              (b) from a Linux host where OCI CLI is installed. 

for i in $(oci iam region-subscription list --query "data[].\"region-name\"" | jq '.[]' | sed 's/"//g')
do
  echo ">>>>>>>>>>>>>>>  Region: " $i "<<<<<<<<<<<<<<<<<< "
  oci search resource structured-search \
    --region $i \
    --query-text "QUERY instance resources" \
    --query 'data.items[*].{ad:"availability-domain",instancename:"display-name",state:"lifecycle-state"}' | \
    jq 'sort_by(.state, .ad) | [ "ad", "state", "count" ], (group_by((.state|ascii_downcase),.ad)[] | 
		{ad: .[0].ad, state: (.[0].state|ascii_downcase), occurances: length} | [.ad, .state,.occurances])|@tsv' |\
    sed 's/"//g' | sed 's/\\t/|/g' |\
    awk 'BEGIN {printf("---------------------------------------------------------\n");}
         {
           if (NR == 2) printf("---------------------------------------------------------\n");
           printf("| %-30s | %-12s | %-5s |\n",$1,$2,$3);
         }
         END {printf("---------------------------------------------------------\n\n");}' FS='|'
done
