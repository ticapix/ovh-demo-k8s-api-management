# OVH Managed Kubernetes use case: API Gateway deployment

This repo contains notebooks which guide you with the deployment of [Gravitee.io](https://gravitee.io/) on a [K8s cluster](https://www.ovh.com/fr/kubernetes/).

## Online reading

[Documentation](https://ticapix.github.io/ovh-demo-k8s-api-management/)

(generated from `make docs`)

## Local reading with interractive shell

To start, type `make run` and navigate the printed url

```shell
make run
[I 16:41:48.688 NotebookApp] Serving notebooks from local directory: /mnt/c/Users/pgronlie/workspace/articles/k8s_201
[I 16:41:48.689 NotebookApp] The Jupyter Notebook is running at:
[I 16:41:48.689 NotebookApp] http://localhost:8888/?token=2f575e761b9647fd8426184e121401a5b37f347e1ef13d76
[I 16:41:48.690 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[W 16:41:48.842 NotebookApp] No web browser found: could not locate runnable browser.
[C 16:41:48.843 NotebookApp]

    To access the notebook, open this file in a browser:
        file:///home/pierre/.local/share/jupyter/runtime/nbserver-16723-open.html
    Or copy and paste one of these URLs:
        http://localhost:8888/?token=2f575e761b9647fd8426184e121401a5b37f347e1ef13d76
```

The starting point is `main.ipynb`