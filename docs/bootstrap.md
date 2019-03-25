
# Install kubctl

Official [documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

Below is the lazy non-root method.


```bash
curl -LOC - https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
```


```bash
export PATH=`pwd`:$PATH
```


```bash
which kubectl
```

# Install helm

Official [documentation](https://helm.sh/docs/using_helm/).

Below is the lazy non-recommended non-root method


```bash
export HELM_INSTALL_DIR=`pwd`
export USE_SUDO=false
curl -C - https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
```


```bash
export PATH=`pwd`:$PATH
```


```bash
which helm
```

# Install Linkerd

Official [documentation](https://linkerd.io/2/getting-started/)

Below is the lazy non-root method


```bash
curl -sLC - https://run.linkerd.io/install | sh
```


```bash
export PATH=$PATH:$HOME/.linkerd2/bin
```


```bash
which linkerd
```

# Install kubetail

Official [documentation](https://github.com/johanhaleby/kubetail)

Below is the lazy non-root method


```bash
curl -LO https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
chmod +x ./kubetail
```


```bash
export PATH=`pwd`:$PATH
```


```bash
which kubetail
```
