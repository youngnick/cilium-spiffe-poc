.PHONY: install add-new-identities uninstall

install:
# Create namespace
	kubectl apply -f spire-namespace.yaml

# Then, install the server (order important)
	kubectl apply -f server-account.yaml
	kubectl apply -f spire-bundle-configmap.yaml
	kubectl apply -f server-cluster-role.yaml
	kubectl apply -f server-configmap.yaml
	kubectl apply -f server-statefulset.yaml
	kubectl apply -f server-service.yaml

# Then, install the SPIRE agent
	kubectl apply -f agent-account.yaml
	kubectl apply -f agent-cluster-role.yaml

	kubectl apply -f agent-configmap.yaml
	kubectl apply -f agent-daemonset.yaml

# Wait for the SPIRE server to be ready
	kubectl wait -n spire -l statefulset.kubernetes.io/pod-name=spire-server-0 --for=condition=ready pod --timeout=-1s

# First, create a standard Node entry for the spire agent, this will be the parent identity for the other ones
	kubectl exec -n spire spire-server-0 -- \
		/opt/spire/bin/spire-server entry create \
		-spiffeID spiffe://spiffe.cilium.io/ns/spire/sa/spire-agent \
		-selector k8s_psat:cluster:cilium-spiffe \
		-selector k8s_psat:agent_ns:spire \
		-selector k8s_psat:agent_sa:spire-agent \
		-node

# Then add the cilium-agent identity to the server (required for the delegated identity to work)
	kubectl exec -n spire spire-server-0 -- \
		/opt/spire/bin/spire-server entry create \
		-spiffeID spiffe://spiffe.cilium.io/cilium-agent \
		-parentID spiffe://spiffe.cilium.io/ns/spire/sa/spire-agent \
		-selector k8s:ns:default \
		-selector k8s:label:k8s-app:spiffetest

	kubectl exec -n spire spire-server-0 -- \
		/opt/spire/bin/spire-server entry create \
		-spiffeID spiffe://spiffe.cilium.io/dclient \
		-parentID spiffe://spiffe.cilium.io/ns/spire/sa/spire-agent \
		-selector k8s:ns:default \
		-selector k8s:sa:fakeagent

	@echo Now you can "kubectl apply -f fakeagent-deployment.yaml" when you are ready to install the delegated identity client.

add-new-identities:
	kubectl exec -n spire spire-server-0 -- \
		/opt/spire/bin/spire-server entry create \
		-spiffeID spiffe://spiffe.cilium.io/sclient \
		-parentID spiffe://spiffe.cilium.io/dclient \
		-selector k8s:ns:default \
		-selector k8s:label:k8s-app:sclient

	kubectl exec -n spire spire-server-0 -- \
		/opt/spire/bin/spire-server entry create \
		-spiffeID spiffe://spiffe.cilium.io/sclient2 \
		-parentID spiffe://spiffe.cilium.io/dclient \
		-selector k8s:ns:default \
		-selector k8s:label:k8s-app:sclient2

uninstall:
	kubectl delete -f spire-namespace.yaml
