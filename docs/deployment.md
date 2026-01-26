# Deployment Documentation
## Overview

This project implements the deployment of the provided spam detection web application and its associated spam classification model within a Kubernetes-based environment. This document reports on the document on the final deployment structure as well as the end-to-end flow of the system.

As specified in Assignment 4, this document will skip provisioning details and focus on the abstract level of Kubernetes, used for container orchestration and service discovery, and Istio, which is integrated as a service mesh to enable efficient traffic management, observability and controlled experimentation. 

## Kubernetes Architecture

### Deployments

The entirety of the application is deployed using multiple Kubernetes Deployments, with different deployments defined for each version of app and model-service (version 1 and 2). These versions are required for traffic splitting and experimentation, allowing for multiple versions of the same service to exist within the cluster.

### Services

Kubernetes Services provide stable network identities for the deployed pods. These services abstract away from individual pod IPs and enable reliable communication between components as the pods are ephemeral and can be recreated at any time. They also expose the app and model-service internally within the cluster, with requests being routed to the appropriate pods based on label selectors, thus enabling load balancing.

### Ingress Gateway
External access to the app is provided through an Ingress Gateway. This is what enables users to go to a URL and interact with the frontend by acting as an entry point into the cluster and routing incoming traffic appropriately.

Additionally, considering the context of the project, the deployment runs on bare-metal virtual machines (VMs) without native cloud load balancers. Thus, MetalLB is used to assign external IP addresses to LoadBalancer-type services, allowing for the istio ingress gateway to be reachable from outside the cluster and make the app accessible via HTTP.

### Configuration Maps and Secrets

Application configuration is all managed using Kubernetes ConfigMaps and Secrets, with ConfigMaps storing non-sensitive configuration settings (i.e. any URLs, runtime parameters, etc.) and Secrets, as the name suggests, store sensitive values such as tokens and credentials. 

Further configuration this way improves maintainability and portability, allowing for small changes to be made without having to rebuild container images. These files can also be reused across multiple deployments and versions, creating a centralized configuration source within the cluster.

### Namespaces and access control

Resources are organized using Kubernetes Namespaces. These are used to logically divide them inside the cluster and can be compared to some kind of 'partition'. Namespaces are used to group related objects such as Pods, Services and Deployments for several different purposes. These are handy as they can help avoid name collisions and can enable access control. 

Access control is implemented using Role-Based Access Control (RBAC) and ServiceAccounts. RBAC policies can define which actions are allowed within a Namespace, while ServiceAccounts represent identities used by applications when interacting with the Kubernetes API. Access control as a whole helps set up permission management and can limit access to sensitive resources. This is required, for example, when trying to access the Kubernetes Dashboard.

## Istio Service Mesh Architecture

As mentioned in the overview, Istio extends the Kubernetes deployment with a service mesh. This would enable advanced traffic control, observability and so on, without having to modify any application code. 

### Sidecar proxies
As is configured, Istio would inject a sidecar proxy into the app pods. These intercept all inbound and outbound traffic, allowing Istio to apply the configured routing rules and enforce any policies. 

### Istio Ingress Gateway
In this case, the deployment relies on the Istio Ingress Gateway which integrates directly with Istio's routing and policy mechanisms. This serves as the main entry point for HTTP traffic. Incoming requests are processed by this gateway and routed according to the previously mentioned configuration resources.

### Traffic management
Traffic management is implemented using VirtualService and DestinationRule resources.

DestinationRule defines subsets corresponding to different versions of app and model-service while the VirtualService resource specifies how incoming traffic is routed to those different subsets. This is what allows for experimentation.

The routing decision splits traffic using a 90/10 canary strategy, meaning that 90% of traffic is routed to the stable version (version 1), while 10% is routed to the canary version (version 2).

#### Sticky Sessions

Sticky sessions have been implemented as well, ensuring that users consistently interact with the same version across multiple requests. 

Routing decisions can be influenced using an HTTP cookie ("experiment=v1" or "experiment=v2"). When the cookie is present, Istio routing rules will ensure that all subsequent requests from the user will be routed to the corresponding version. If the cookie is not present, the routing will follow the initial 90/10 strategy and update the cookie accordingly. 

Should a version be preferred, the user can specify by altering the cookie value. This can be done by opening DevTools in the browser and changing the version in Cookies. 

## Additional use case (rate-limiting)

Gabriel TODO

### Monitoring and observability

To monitor the behaviour of the system as well as its performance, several observability tools were deployed. 
- Prometheus: This tool collects metrics from an exposed port (/metrics) in app. This looks at all the metrics defined in FrontendController, and generally looks at application behaviour and request traffic. 
- Grafana: This tool is able to provide visualizations tuned to whatever metrics have been defined. This enables the analysis of these metrics, and allows for the comparison of the different deployment versions.
- Kubernetes Dashboard: This provides a cluster-level overview of everything going on within the cluster. This can look at the deployments, pods, services and so on.


## Flow of incoming requests
An incoming HTTP request flows through the system
1. A user sends an HTTP request to the application using the external IP exposed by the Istio Ingress Gateway on port 80.
2. The request is received by the Istio Ingress Gateway and then is evaluated against Istio VirtualService rules. This will apply traffic routing logic (splitting and sticky sessions). 
3. The request is then routed to the frontend Kubernetes Service
4. The frontend Service will forward the requestto one of the frontend pods listening on port 8080.
5. The frontend app processes the request and sends an internal HTTP request to the appropriate backend (model-service) version via its Kubernetes Service. 
6. The backend (model-service) Service will then forward the request to the model-service pod listening on port 8081, where the spam classification model is then executed. 
7. The backend returns the result of the model to the frontned, which then displays it to the user. 




