extension.md

# Extension Proposal: Release Drift Detection and Self-Healing Using ArgoCD

## Identified Release-Engineering Shortcoming
As it stands now, the current project deployment strategy is manual and subject to many inconsistencies. As a result, there is a lack of post-deployment release state enforcement. The system currently does not verify whether or not the Kubernetes cluster matches the release specification defined by version control. 

Manual interventions such as rollbacks, configuration changes, and so on, can lead to release drift, a state where the deployed system no longer reflects the declared release state. 

This provided many issues when testing out certain features on different laptops and environments. This issue is especially problematic during canary releases and continuous experimentation, which assumes deployment conditions to be controlled and stable. This can complicate debugging, and release reliability is reduced. 

## Extension proposal

To address this shortcoming, we propose integrating ArgoCD to enable continuous drift detection and automated self-healing. This ensures that the system always converges back to the declared release state in Git.

At a high level, this is how the ArgoCD process is meant to go:
- A developer makes changes to the application and pushes a new version of the Kubernetes resource definitions to a Git repo.
- CI is triggered and thus creates a new container image saved to a registry.
- A developer makes a pull request (PR) that includes changing Kubernetes manifests.
- The PR is reviewed and changes are merged onto the main branch, triggering a webhook that lets ArgoCD know that a change has been made. 
- ArgoCD clones the repository and compares application state with current state of the Kubernetes cluster, applying the required changes to the cluster configuration.
- Kubernetes uses its controllers to reconcile changes required to cluster resources.
- ArgoCD monitors progress and reports that the application is in sync when the Kubernetes cluster is ready.
- Alternatively, ArgoCD also monitors changes in the Kubernetes cluster and discards them if they don't match the configuration specified in Git.

This extension introduces the following:
- Declarative release definitions stored in Git
- Continuous comparison between target and live cluster state
- Automated synchronization when a drift is detected. 

## Conceptual design comparison

### Current situation
- Deployments are applied manually using Helm
- No detection of post-deployment changes
- Drifts remain undetected

### Extended situation
- Git becomes a single source of truth
- Drifts get detected automatically
- The system then self-heals to restore intended release state

## Implementation plan
The following plan can be followed to try and implement ArgoCD:
- Install ArgoCD into the Kubernetes cluster
- Define ArgoCD applications pointing to the Helm charts repository
- Enable automated sync, pruning and self-healing
- Integrate ArgoCD status checks into the CI/CD workflow
- Document operational guidelines and limitations. 

## Expected Outcomes
Once implemented, teams can expected to see these changes:
- Reduced configuration drift
- More reliable canary releases
- Fast recovery from unintended changes
- Improved release visibility through ArgoCD web UI
- A single source of truth in Git
- Safer deployments

## Evaluation plan
### Hypothesis
Automated drift detection and self-healing reduce release inconsistencies and improve deployment reliability.

### Metrics
These are the metrics that could be compared before and after introducing ArgoCD into the deployment:
- Number of detected drift events
- Time to detect drift
- Time to restore desired state


## Assumptions and possible limitations
- Over-enforcement can be problematic - not all drift is unintended as some emergency fixes might be legitimate
- Teams must commit all release changes through Git
- Kubernetes specific
- Initial setup is complex and has a learning curve. 


## Closing remarks
While this proposal highlights ArgoCD as a concrete implementation, the underlying extension is the integration of a GitOps-based release enforcement method that is broadly applicable across Kubernetes-based release pipelines.

By integrating this and continuously reconciling the live state of the Kubernetes cluster against the declared release state stored in Git, this approach automatically detects configuration drift and triggers self-healing, thereby eliminating silent drifts and their resulting release failures. 


## References
Narni, V. (2024, April 5). A complete overview of argocd with a practical example | by Veerababu Narni | medium. Medium. https://medium.com/@veerababu.narni232/a-complete-overview-of-argocd-with-a-practical-example-f4a9a8488cf9 
Understanding Argo CD: Kubernetes Gitops made simple. Codefresh. (2025b, June 4). https://codefresh.io/learn/argo-cd/ 