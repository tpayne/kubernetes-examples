# This works for AKS...

# Can also just use az aks get-credentials...

cat <<EOF | cfssl genkey - | cfssljson -bare james
{
"CN": "james",
"key": {
"algo": "rsa",
"size": 4096
}
}
EOF

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: james
spec:
  request: $(cat james.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - client auth
EOF

kubectl certificate james approve

kubectl get csr james-o jsonpath='{.status.certificate}' | base64 -d > james.pem

# kubectl config set-credentials kubeuser/foo.kubernetes.com --username=kubeuser --password=kubepassword
kubectl config set-credentials james \
    --client-certificate=james.pem \
    --client-key=james.pem

kubectl config set-context james-context \
    --cluster=kubernetes --user=james-context

