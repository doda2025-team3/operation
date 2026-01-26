# Operation repository for SMS Checker

This repository contains all the information required to run the SMS Checker application and operate the cluster. Please refer to the following repositories for more information:

The [app] repository that contains the frontend Spring Boot service: (https://github.com/doda2025-team3/app/tree/A1) 

The [model-service] repository that contains the backend Python service: (https://github.com/doda2025-team3/model-service/tree/A1)

The [lib-version] repository that includes a version aware Maven Library: (https://github.com/doda2025-team3/lib-version/tree/A1)


# Assignment 1: Version Release and Containerization

## Requirements
In order to run the application with Docker, the following products need to be installed - **Docker** and **Docker Compose**.

## Starting the application

After cloning all the repositories mentioned above and navigating to the operation directory, run the following command:

```bash
docker compose up --pull always
```

This command ensures that the latest version of the images are pulled before deploying.

- The frontend of the application can then be accessed via (http://localhost:8080/sms)
- The backend of the application can be accessed via (http://localhost:8081)

## Versioning
In order to change the version for the app image, change the project version in the [pom.xml] file and push the change onto main. This will automatically trigger the workflow. 

To change the version of the lib-version package, like with the app image, change the version in the [pom.xml] file and push to main.

To change the version for the model-service image, change the version in the VERSION_CONTROL file and push to main once again. Alternatively, the version can also be changed manually in GitHub Actions. 

## Environment variables

There exists an .env file in the repository wherein you can change the following variables: 
- MODEL_URL
- APP_IMAGE
- MODEL_IMAGE
- APP_VERSION
- MODEL_VERSION
- MODEL_PORT
- SERVER_PORT

## Cleaning up
Run the following command to stop running the application:
```bash
docker compose down
```

# Assignment 2: Provisioning a Kubernetes Cluster

## Requirements
VirtualBox, Ansible and Vagrant need to be install onto the host to enable the setting up of the Kubernetes cluster.

## Running the cluster
In order to run the cluster, run the following command:
```bash
vagrant up --no-provision
```

Assuming no changes have been made to the node count (which is configurable), this command will bring up three nodes:
- the [ctrl] node
- two worker nodes, [node-1] and [node-2]

This command also automatically generates the appropriate [inventory.cfg] file with only the active nodes appended to it. 

After the nodes have been set up, run the following command to provision the VMs:
```bash
ansible-playbook -i inventory.cfg ansible/general.yml && ansible-playbook -i inventory.cfg ansible/ctrl.yml && ansible-playbook -i inventory.cfg ansible/node.yml && ansible-playbook -i inventory.cfg ansible/finalization.yml
```

Note: if you are in a different directory, please edit, for example [.ansible/finalization.yml], accordingly!

## Kubernetes dashboard

To access the Kubernetes Dashboard, please add the following into /etc/hosts:
```bash
echo "192.168.56.95 dashboard.local" | sudo tee -a /etc/hosts
```

Then, to create the token, run:
```bash
kubectl -n kubernetes-dashboard create token admin-user
```

Visit the site (http://dashboard.local) and copy-paste the output to gain access to the dashboard. 


## Cleaning up
Run the following command to stop the cluster:
```bash
vagrant destroy
```

# Assignment 3: Operate and Monitor Kubernetes

## Requirements
Helm needs to be installed on the host.

## Deploying with Helm

Please run the commands shown previously to set up the Kubernetes cluster.

Once the cluster has been finalized, run the following command:
```bash
export KUBECONFIG=$(pwd)/kubeconfig
```

To ensure that everything has been set up correctly, run:
```bash
kubectl get nodes
```

All three nodes should be visible.

Finally, run the following commands to install the helm chart:

```bash
helm dependency update
helm upgrade --install myapp .
```

The app frontend can then be accessed by following the steps below:
- Add the IP address to /etc/hosts.
```bash
echo "192.168.56.91 operation.local operation-canary.local" | sudo tee -a /etc/hosts
```
- Open the link (http://operation.local/sms/) to access the frontend of the application. 

## Prometheus
This tool scrapes for application-specific metrics on the /metrics endpoint of the app. To view the dashboard, port-forward using the command below, and then visit the site (http://localhost:9090).

```bash
kubectl port-forward pod/prometheus-myapp-kube-prometheus-stac-prometheus-0 9090:9090
```

## Alerting
A PrometheusRule was used to define the alert. Here, we are looking at a high request rate. When the application received more than 7 requests per minute, for two minutes, then the alert can be seen firing in Prometheus.

To view the dashboard, port-forward like so:
```bash
kubectl port-forward pod/alertmanager-myapp-kube-prometheus-stac-alertmanager-0 9093:9093
```

Then visit this site,(http://localhost:9093).

Run the following command to trigger this:
```
END=$((SECONDS+130))
i=0
while [ $SECONDS -lt $END ]; do
  curl -s -o /dev/null \
    -H "Content-Type: application/json" \
    -H "Cookie: user_id=user-$i" \
    -X POST http://operation.local/sms/ \
    -d '{"sms":"this is a spam test message"}'
  i=$((i+1))
  sleep 5
done

```

After a while, the alert on Prometheus can be seen as 'firing', and the alert should be visible in the Alertmanager dashboard. 

To receive an email, please also add your credentials like to the values.yaml file accordingly, under monitoring. Note that password refers to your app password!  

An email should then be sent to your email after triggering the alert like shown above.

## Grafana
Grafana is used to visualize the metrics of the application. Similarly to the previous two tools, to view the dashboard, please port-forward using the command below and then visit the site (http://localhost:3000).

```bash
kubectl port-forward svc/myapp-grafana 3000:80
```

# Assignment 4: Istio Service Mesh

For this, traffic management was made possible via the use of Gateways, DestinationRules and VirtualServices. 
- Gateways acted as the entry point for incoming traffic and passes them into the Istio service mesh on port 80.
- DestinationRules defined the two subsets, v1 and v2.
- VirtualService defined the traffic rules. Here is where the 90/10 split was defined, where 90% of traffic gets taken to the stable release and 10% of the traffic gets taken to the canaray release. 

The split can be tested by running the following command:
```bash
for i in $(seq 1 200); do
  curl -sk -D - http://operation.local/sms/ \
  -o /dev/null \
  | awk 'BEGIN{IGNORECASE=1} /^app-subset:/{print $2}' \
  | tr -d '\r'
done | sort | uniq -c
```

The split can be seen to roughly follow 90%/10%.

## Sticky sessions

Sticky sessions was implemented in the VirtualService resource by cookie-based assignment. One first request, the request matches the catch-all rule and is directed via the 90/10 split. Following that, it sets the appropriate cookie value. On subsequent requests, it gets taken to corresponding version based on the value of the cookie. 

This can be tested by running the following commands:

Set the initial cookie:
```bash
rm -f /tmp/cookies.txt
curl -sk -c /tmp/cookies.txt -D - http://operation.local/sms/ -o /dev/null | egrep -i 'set-cookie|app-subset'
```
Test out 40 requests:
```bash
for i in {1..40}; do
  curl -sk -b /tmp/cookies.txt -I http://operation.local/sms/ | grep -i app-subset
done | sort | uniq -c
```

The result should show that the same version was seen every time. 

Should a specific version want to be seen, you can simple change the cookie to the appropriate version. 

## Additional Use case: Rate limiting



