#!/bin/bash

helm repo add navarcos https://harbor.navarcos.ccoe-nc.com/chartrepo/navarcos
helm repo update navarcos

API_ENDPOINT="https://harbor.navarcos.ccoe-nc.com/api/chartrepo/navarcos/charts"

charts_name=($(curl -s -X GET "$API_ENDPOINT" | jq -r '.[].name'))

mkdir -p /tmp/helm

for chart_name in "${charts_name[@]}"; do
    chart_name=($(curl -s -X GET "$API_ENDPOINT/$chart_name" | jq -r '.[].name'))
    chart_version=($(curl -s -X GET "$API_ENDPOINT/$chart_name" | jq -r '.[].version'))
    
    for i in "${!chart_name[@]}"; do
        helm pull navarcos/${chart_name[$i]} --version ${chart_version[$i]} --destination /tmp/helm
    done
done

