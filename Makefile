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

	@echo Now you can "kubectl apply -f fakeagent-deployment.yaml" when you are ready to install the delegated identity client.
uninstall:
	kubectl delete -f spire-namespace.yaml
