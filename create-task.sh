#!/bin/bash


# Create x tasks with the given port
# Usage: ./create-task.sh 100 8081

tasks=$1
port=$2

for i in "$@"
do
    case $i in
        -h|--help)
            echo "Usage: ./create-task.sh 100 8081"
            echo "Create 100 tasks with the given port"
            exit 0
            ;;
    esac
done

if [ -z "$tasks" ] || [ -z "$port" ]; then
    echo "Usage: ./create-task.sh 100 8081"
    exit 1
fi

for i in $(seq 1 $tasks)
do
    id=$(uuidgen)
    curl -X POST -H "Content-Type: application/json" -d '{"id":"'$id'", "description":"Created task '$i'"}' http://localhost:$port/task
done
