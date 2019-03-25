
# Install Gravitee.io

Gravitee.io will need a MongoDB and ElasticSearch service.


```bash
. ./activate
```

# MongoDB installation

The chart documetation is available [here](https://github.com/helm/charts/tree/master/stable/mongodb)



```bash
helm del --purge my-mongodb  # delete if already installed
```


```bash
helm install --name my-mongodb stable/mongodb
```

Check that the pod is up and running


```bash
kubectl get pods,service --namespace=default -l release=my-mongodb -o wide
```

Save admin User/Password values for later


```bash
# Admin credential
MONGODB_ADMIN_USER=root
MONGODB_ADMIN_PASS=$(kubectl get secret my-mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)
```

# MongoDB configuration

First we'll create a secret for our MongoDB database


```bash
cat > config.yml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: gravitee-mongodb
type: Opaque
data:
  database: gravitee
stringData:
  username: gravitee
  password: "Sup3rStr0ngPassw0rd"
EOF
```


```bash
kubectl apply -f config.yml
```

We need now to create a user account associated with the MongoDB database we'll be using


```bash
# DB connection settings
MONGODB_HOST=$(kubectl get service -l release=my-mongodb -o jsonpath="{.items[0].metadata.name}.{.items[0].metadata.namespace}.svc")
MONGODB_PORT=$(kubectl get service -l release=my-mongodb -o jsonpath="{.items[0].spec.ports[0].port}")

# Gravitee credential
MONGODB_DB=$(kubectl get secret gravitee-mongodb -o jsonpath="{.data.database}")
MONGODB_GRAVITEE_USER=$(kubectl get secret gravitee-mongodb -o jsonpath="{.data.username}" | base64 --decode)
MONGODB_GRAVITEE_PASS=$(kubectl get secret gravitee-mongodb -o jsonpath="{.data.password}" | base64 --decode)
```


```bash
echo Host: $MONGODB_HOST, Port: $MONGODB_PORT
```


```bash
# https://docs.mongodb.com/manual/reference/built-in-roles/#database-user-roles
cat > config.js <<EOF
db = db.getSiblingDB("$MONGODB_DB") // select database
db.dropUser("$MONGODB_GRAVITEE_USER") // delete user if it exists
db.createUser({"user": "$MONGODB_GRAVITEE_USER", "pwd": "$MONGODB_GRAVITEE_PASS", "roles": ["dbOwner"]})// create new user
EOF
```


```bash
cat config.js | kubectl run my-mongodb-client --rm -i --restart='Never' \
--image bitnami/mongodb \
--command -- mongo --host $MONGODB_HOST:$MONGODB_PORT -u $MONGODB_ADMIN_USER -p $MONGODB_ADMIN_PASS
```

# ElasticSearch setup

## ~~With OVH Logs~~

Gravitee is using one index per day which is not supported by our Logs business model at the moment.


## With K8s

### Install ElasticSearch

The chart documetation is available [here](https://github.com/helm/charts/tree/master/stable/elasticsearch)

ElasticSearch will require to have at least 3 nodes available.


```bash
helm del --purge my-elasticsearch # delete if already installed
```


```bash
helm install --name my-elasticsearch stable/elasticsearch
```

**Note**: The list of `storageClassName` is available via `kubectl get sc`.

Check that the pods are up and running


```bash
kubectl get pods,service --namespace=default -l release=my-elasticsearch -o wide
```

### Collect variables

We need to gather some ElasticSearch configuration values


```bash
ES_PROTOCOL=$(kubectl get service -l release=my-elasticsearch -o jsonpath="{.items[0].spec.ports[0].name}")
ES_PORT=$(kubectl get service -l release=my-elasticsearch -o jsonpath="{.items[0].spec.ports[0].port}")
ES_HOST=$(kubectl get service -l release=my-elasticsearch -o jsonpath="{.items[0].metadata.name}.{.items[0].metadata.namespace}.svc")
```


```bash
echo Protocol: $ES_PROTOCOL, Host: $ES_HOST, Port: $ES_PORT
```

# Gravitee installation

The first step is to build the helm [chart](https://github.com/gravitee-io/gravitee-kubernetes/tree/master/gravitee).


```bash
#curl -OL https://github.com/gravitee-io/gravitee-kubernetes/archive/master.zip
curl -L https://github.com/ticapix/gravitee-kubernetes/archive/bump-1.23.1.zip -o master.zip
```


```bash
unzip -ou master.zip
```


```bash
helm package gravitee-kubernetes-*/gravitee/ # build chart
```

Generate bcrypt (`$2a$` version) hash.

You could use an online generator such as https://www.browserling.com/tools/bcrypt


```bash
ADMIN_PASSWD='$2a$10$bCwdwiJD3rv9xYH1fHBmK.PNbccheIeXT3rpdtHkvVRdaYHMrcam2'
```


```bash
cat > config.yml <<EOF

adminPasswordBcrypt: $ADMIN_PASSWD

jwtSecret: myD3m0JWT4S3cr3t

mongo:
  rsEnabled: false
  dbhost: $MONGODB_GRAVITEE_USER:$MONGODB_GRAVITEE_PASS@$MONGODB_HOST
  dbname: $MONGODB_DB
  dbport: $MONGODB_PORT

es:
  cluster: elasticsearch # default value
  index: gravitee # default value
  endpoints:
    - $ES_PROTOCOL://$ES_HOST:$ES_PORT

ui:
  ingress:
    path: /
    hosts:
      - dev.apis.ovh ## for the development team
    tls:
    - hosts:
      - dev.apis.ovh
      secretName: apis.ovh-cert

api:
  ingress:
    path: /management ## default path value for the api path
    hosts:
      - dev.apis.ovh
    tls:
    - hosts:
      - dev.apis.ovh
      secretName: apis.ovh-cert

gateway:
  ingress:
    path: /
    hosts:
      - app.apis.ovh ## public access point
    tls:
    - hosts:
      - app.apis.ovh
      secretName: apis.ovh-cert
      
EOF
```


```bash
helm del --purge gravitee # delete if already installed
```


```bash
helm install --name gravitee gravitee-1.23.1.tgz -f config.yml
```

Check that the pods are up and running


```bash
kubectl get pods -l release=gravitee
```


```bash

```
