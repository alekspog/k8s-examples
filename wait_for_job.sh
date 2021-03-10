while [[ $(kubectl get jobs --sort-by=.metadata.creationTimestamp -o jsonpath='{..items[-1:]..conditions[0].status}') != "True" ]]
do
sleep 1
done
