                                   Plugin keys | Supported project versions
-----------------------------------------------+----------------------------
           ansible.sdk.operatorframework.io/v1 |                          3
              declarative.go.kubebuilder.io/v1 |                       2, 3
       deploy-image.go.kubebuilder.io/v1-alpha |                          3
                          go.kubebuilder.io/v2 |                       2, 3
                          go.kubebuilder.io/v3 |                          3
                    go.kubebuilder.io/v4-alpha |                          3
               grafana.kubebuilder.io/v1-alpha |                          3
              helm.sdk.operatorframework.io/v1 |                          3
 hybrid.helm.sdk.operatorframework.io/v1-alpha |                          3
           quarkus.javaoperatorsdk.io/v1-alpha |                          3


```console
rm -fr Dockerfile Makefile \
    PROJECT config go.mod \
    go.sum hack \
    main.go \
    api \
    bin \
    controllers

operator-sdk init --plugins go/v3 --domain github.actions.io --owner "Tim Payne" \
    --repo github.com/tpayne/kubernetes-examples
```

```console
operator-sdk create api github-actions-api-operator \
    --group "github.actions.io" \
    --version "v1alpha1" \
    --kind "GitHubActions" \
    --force \
    --plural "ghactions" << EOF
y
y
EOF
```


```console
operator-sdk create webhook github-actions-webhook \
    --group "github.actions.io" \
    --version "v1alpha1" \
    --kind "GitHubActions" \
    --force \
    --conversion \
    --plural "ghactions" << EOF
y
y
EOF
```

```console
make manifests
```

