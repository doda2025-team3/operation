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

## Cleaning up
Run the following command to stop running the application:
```bash
docker compose down
```

# Assignment 2: Provisioning a Kubernetes Cluster

## Requirements
VirtualBox, Ansible and Vagrant need to be install onto the host to enable the setting up of the kubernestes cluster.

## Running the cluster
In order to run the cluster, run the following command:
```bash
vagrant up --no-provision
```

Assuming no changes have been made to the node count, this command will bring up three nodes:
- the [ctrl] node
- two worker nodes, [node-1] and [node-2]

This command also automatically generates the appropriate [inventory.cfg] file with only the active nodes added to it. 

After the nodes have been set up, run the following command to provision the VMs:
```bash
vagrant provision
```

Once all the nodes have been provisioned, run this command to finalize the cluster:
```bash
ansible-playbook -i inventory.cfg ./ansible/finalization.yml
```
Note: if you are in a different directory, please edit [.ansible/finalization.yml] accordingly!

## Cleaning up
Run the following command to stop the cluster:
```bash
vagrant destroy
```

# Assignment 3: Operate and Monitor Kubernetes

## Requirements
Helm needs to be installed on the host.

## Deploying with Helm

Please run the commands shown previously to set up the kubernetes cluster.

Once the cluster has been finalized, run the following commands:

```bash
helm dependency update
export KUBECONFIG=$(pwd)/kubeconfig
```

To ensure that everything has been set up correctly, run:
```bash
kubectl get nodes
```

All three nodes should be visible.

Finally, run the command:

```bash
helm upgrade --install myapp ./k8s
```

The app can then be accessed by following the steps below:
- Add the IP address to /etc/hosts.
```bash
echo "192.168.56.95 operation.local operation-canary.local" | sudo tee -a /etc/hosts
```
- Open the link (http://operation.local/sms/) to access the frontend of the application. 
