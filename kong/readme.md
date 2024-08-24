```
helm repo add kong https://charts.konghq.com
```


```
echo "
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: key-auth
plugin: key-auth
config:
  key_names:
  - apikey
" | kubectl apply -f -
```

```
echo '
 apiVersion: v1
 kind: Secret
 metadata:
    name: alex-key-auth
    labels:
       konghq.com/credential: key-auth
 stringData:
    key: hello_world
 ' | kubectl apply -f -
 ```
