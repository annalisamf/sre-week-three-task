#!/bin/bash

# Define the namespace and deployment details
NAMESPACE="sre"
DEPLOYMENT_NAME="swype-app"
MAX_RESTARTS=3

# Infinite loop to monitor pod restarts
while true; do
    # Get the current number of restarts from the relevant pod
    CURRENT_RESTARTS=$(kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT_NAME -o jsonpath='{.items[*].status.containerStatuses[*].restartCount}' | awk '{s+=$1} END {print s}')

    # Display the current number of restarts
    echo "Current restarts: $CURRENT_RESTARTS"

    # Check if the current restarts exceed the maximum allowed
    if [[ $CURRENT_RESTARTS -gt $MAX_RESTARTS ]]; then
        echo "Restart limit exceeded, scaling down the deployment..."
        # Scale down the deployment
        kubectl scale deployment -n $NAMESPACE $DEPLOYMENT_NAME --replicas=0
        # Break the loop as the condition has been met
        break
    else
        # Pause for 60 seconds before checking again
        sleep 60
    fi
done
