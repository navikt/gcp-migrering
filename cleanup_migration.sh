#!/bin/bash

kubectl delete -f gcloud.yaml
kubectl delete -f secret.yaml
kubectl delete -f network.yaml
