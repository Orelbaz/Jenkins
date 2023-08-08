#!/bin/bash

TAG=$1
CLUSTER=$2

export USE_GKE_GCLOUD_AUTH_PLUGIN=True
gcloud container clusters get-credentials --project gke-first-393008 $CLUSTER --zone us-central1-c

cd /var/lib/jenkins/workspace/K8-pipeline/Jenkins/K8-jenkins
helm package .
helm install Stock-site Stock-site-chart-0.1.0.tgz

if [[$2 == eks-test]]; then

    EXTERNAL_IP=$(kubectl get service flask-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

    # Test the http status
    http_response=$(curl -s -o /dev/null -w "%{http_code}" ${EXTERNAL-IP}:80)

    if [[ $http_response == 200 ]]; then
        echo "Flask app returned a 200 status code. Test passed!"
    else
        echo "Flask app returned a non-200 status code: $http_response. Test failed!"
        exit 1
    fi
fi


