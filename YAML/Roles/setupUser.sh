# This will only work for local K8s servers...

# Create a private key for james...
openssl genrsa -out james.key 2048

# Create CSR for james in two groups...
openssl req -new -key james.key \
	-out james.csr \
	-subj "/CN=james/O=users/O=admin"

# Only works for locally hosted K8s installation...
openssl x509 -req -in james.csr \
	-CA /etc/kubernetes/pki/ca.crt \
	-CAkey /etc/kubernetes/pki/ca.key \
	-CAcreateserial \
	-out james.crt -days 500

mkdir /home/users/james/.certs && mv {james.crt,james.key} /home/users/james/.certs
kubectl config set-credentials james \
	--client-certificate=/home/users/james/.certs/james.crt \
	--client-key=/home/users/james/.certs/james.key

kubectl config set-context james-context \
	--cluster=kubernetes --user=james-context

# certificate-authority-data” and “server” variables are those as in the cluster admin config
#  kubectl config view
mkdir .kube
cat <<EOF >.kube/config
apiVersion: v1
clusters:
- cluster:
 certificate-authority-data: {Parse content here}
 server: {Parse content here}
name: kubernetes
contexts:
- context:
 cluster: kubernetes
 user: james
name: james-context
current-context: james-context
kind: Config
preferences: {}
users:
- name: james
user:
 client-certificate: /home/users/james/.certs/james.cert
 client-key: /home/users/james/.certs/james.key
EOF
