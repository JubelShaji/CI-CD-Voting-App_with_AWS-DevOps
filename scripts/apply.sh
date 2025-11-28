#!/bin/bash
echo "Applying Kubernetes manifests..."
kubectl apply -f /home/ubuntu/app/k8s-specifications/
