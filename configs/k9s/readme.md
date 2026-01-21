# Configuration

## add to your profile
### XDG Base Directory Specification
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share


use yq to merge yaml files so we can have simple skins that overload the default.
> a script would be cool here to generate skins when the profile is loaded
> it would do the following
> - get kubectl contexts
> - if context has "lab" in the name
> - generate a new skin file
```
yq '. *= load("_lab.yaml")' monokai.yaml > lab.yaml
```

kubectl run debug-busybox \
  --namespace $NAMESPACE \
  --image=busybox \
  --restart=Never \
  --overrides='{"spec":{"nodeName":"'$(kubectl get pod $NAME -n $NAMESPACE -o jsonpath='{.spec.nodeName}')'"}}' \
  -- /bin/sh -c "sleep infinity"