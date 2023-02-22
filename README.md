This repo has YAML files for getting a SPIRE install into a Kubernetes cluster, ready to be used for working on Cilium mTLS.

It's based on the [SPIRE Kubernetes install instructions](https://spiffe.io/docs/latest/deploying/install-server/), with the following changes:
  * Swaps the Service Account Token Server [Node](https://github.com/spiffe/spire/blob/v1.5.4/doc/plugin_server_nodeattestor_k8s_sat.md) attestor plugin and Agent [Node](https://github.com/spiffe/spire/blob/v1.5.4/doc/plugin_agent_nodeattestor_k8s_sat.md) and [Workload](https://github.com/spiffe/spire/blob/v1.5.4/doc/plugin_agent_workloadattestor_k8s.md) attestor plugin for the Projected Service Account Token Server [Node](https://github.com/spiffe/spire/blob/v1.5.4/doc/plugin_server_nodeattestor_k8s_psat.md) attestor plugin and the PSAT Agent [Node](https://github.com/spiffe/spire/blob/v1.5.4/doc/plugin_server_nodeattestor_k8s_psat.md) and [Workload](https://github.com/spiffe/spire/blob/v1.5.4/doc/plugin_agent_nodeattestor_k8s_psat.md) attestor plugins. The PSAT versions are a little better security wise, but require a dedicated volume to project the service account token into the pod.
  * Changes the socket mounting options for everything to match up.
  * Sets the trust domain to `spiffe.cilium.io`.
  * Adds a fake agent deployment using delegated-client that exercises the SPIFFE DelegatedIdentity API.


Some SPIRE server commands that may prove helpful:
```
  kubectl exec -n spire spire-server-0 -- \
      /opt/spire/bin/spire-server entry create \
      -spiffeID spiffe://spiffe.cilium.io/cilium-agent \
      -parentID spiffe://spiffe.cilium.io/ns/spire/sa/spire-agent \
      -selector k8s:ns:default \
      -selector k8s:sa:test-client
  
  kubectl exec -n spire spire-server-0 -- \
      /opt/spire/bin/spire-server entry create \
      -spiffeID spiffe://spiffe.cilium.io/dclient \
      -parentID spiffe://spiffe.cilium.io/ns/spire/sa/spire-agent \
      -selector k8s:ns:default \
      -selector k8s:sa:fakeagent
      
  kubectl exec -n spire spire-server-0 -- \
      /opt/spire/bin/spire-server entry create \
      -spiffeID spiffe://spiffe.cilium.io/sclient \
      -parentID spiffe://spiffe.cilium.io/dclient \
      -selector k8s:ns:default \
      -selector k8s:label:k8s-app:sclient
  
  kubectl exec -n spire spire-server-0 -- \
      /opt/spire/bin/spire-server entry create \
      -spiffeID spiffe://spiffe.cilium.io/sclient2\
      -parentID spiffe://spiffe.cilium.io/dclient \
      -selector k8s:ns:default \
      -selector k8s:label:k8s-app:sclient2

# Get the list of entries from the SPIRE server:
kubectl exec -n spire spire-server-0 -- \
      /opt/spire/bin/spire-server entry show
```
