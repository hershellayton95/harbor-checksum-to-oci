#!/bin/bash

SOURCE_API_ENDPOINT="https://harbor.navarcos.ccoe-nc.com/api/chartrepo/navarcos/charts"
SOURCE_CHART_ENTPOINT="https://harbor.navarcos.ccoe-nc.com/chartrepo/navarcos"

SINK_HOST="https://harbor.git.ccoe.internal/"
SINK_PROJECT="test-harbor"
SINK_USERNAME='robot$test-harbor+test'
SINK_PASSWORD="pO5BhskMKoghK9hxy1yghHvl1Rz10SFg"

helm repo add tmp $SOURCE_CHART_ENTPOINT

echo $SINK_PASSWORD | helm registry login $SINK_HOST -u $SINK_USERNAME --password-stdin 

charts_name=($(curl -s -X GET "$SOURCE_API_ENDPOINT" | jq -r '.[].name'))

mkdir -p /tmp/helm

for chart_name in "${charts_name[@]}"; do
    chart_name=($(curl -s -X GET "$SOURCE_API_ENDPOINT/$chart_name" | jq -r '.[].name'))
    chart_version=($(curl -s -X GET "$SOURCE_API_ENDPOINT/$chart_name" | jq -r '.[].version'))
    
    for i in "${!chart_name[@]}"; do
        helm pull navarcos/${chart_name[$i]} --version ${chart_version[$i]} --destination /tmp/helm
        tgz_file_path="/tmp/helm/${chart_name[$i]}-${chart_version[$i]}.tgz"
        while [ ! -e $tgz_file_path ]; do
            sleep 1
        done
        echo $tgz_file_path
        # helm push $tgz_file_path oci://$SINK_HOST/$SINK_PROJECT
    done
done

helm repo remove tmp
helm registry logout $SINK_HOST
rm -r /tmp/helm