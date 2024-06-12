#!/bin/bash

# Defining AKS values
AKS_CLUSTER_NAME="myAKSCluster"
RESOURCE_GROUP_NAME="myResourceGroup"
NODE_COUNT=4
NODE_SIZE="Standard_B2s"

# Creating the AKS cluster
az aks create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$AKS_CLUSTER_NAME" \
    --node-count $NODE_COUNT \
    --node-vm-size "$NODE_SIZE" \
    --enable-addons http_application_routing

# credentials for kubectl
az aks get-credentials --resource-group "$RESOURCE_GROUP_NAME" --name "$AKS_CLUSTER_NAME"

# Verify the cluster creation
kubectl get nodes