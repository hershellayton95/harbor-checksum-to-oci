#!/bin/bash

source .env

helm repo add tmp $SOURCE_REPO_CHART_ENTPOINT

echo $SINK_PASSWORD | helm registry login $SINK_HTTPS_HOST -u $SINK_USERNAME --password-stdin 

charts_name=($(curl -s -X GET "$SOURCE_CHARTS_API_ENDPOINT/$SOURCE_PROJECT/charts" | jq -r '.[].name'))

mkdir -p /tmp/helm

for chart_name in "${charts_name[@]}"; do

    chart_version=($(curl -s -X GET "$SOURCE_CHARTS_API_ENDPOINT/$SOURCE_PROJECT/charts/$chart_name" | jq -r '.[].version'))
    
    min=0
    max=$(( ${#chart_version[@]} -1 ))

    while [[ min -lt max ]]
    do
        x="${chart_version[$min]}"
        chart_version[$min]="${chart_version[$max]}"
        chart_version[$max]="$x"
        
        (( min++, max-- ))
    done

    for i in "${!chart_version[@]}"; do
        exist_chart_version=($(curl -s -X GET "$SINK_PROJECTS_API_ENDPOINT/$SINK_PROJECT/repositories/$chart_name/artifacts/${chart_version[$i]}" | jq -r '.tags[].name' 2> /dev/null))

        if [[ -n $exist_chart_version ]]; then
            echo $chart_name:${chart_version[$i]} already exist
            continue;
        fi

        helm pull tmp/${chart_name} --version ${chart_version[$i]} --destination /tmp/helm
        tgz_file_path="/tmp/helm/${chart_name}-${chart_version[$i]}.tgz"
        
        i=0
        while [ ! -e $tgz_file_path ] && [ "$i" -lt 50 ]; do
            echo $tgz_file_path are being downloading
            sleep 0.5
            if [ "$i" -eq 50 ]; then
                echo $tgz_file_path has been downloaded
                exit 1
            fi
        done
        
        echo $tgz_file_path has been downloaded

        helm push $tgz_file_path $SINK_OCI_HOST/$SINK_PROJECT

        exist_chart_version=""
        j=0
        while [ "$chart_version" != "$exist_chart_version" ] && [ "$j" -lt 50 ]; do
            exist_chart_version=($(curl -s -X GET "$SINK_PROJECTS_API_ENDPOINT/$SINK_PROJECT/repositories/$chart_name/artifacts/${chart_version[$i]}" | jq -r '.tags[].name'))
            j=$((i + 1)) 
            sleep 1
            if [ "$j" -eq 50 ]; then
                echo "Chart version not found after 50 attempts, exiting."
                exit 1
            fi
        done
        rm -r $tgz_file_path

    done
done

helm repo remove tmp
helm registry logout $SINK_HTTPS_HOST