export XDG_CONFIG_HOME=$HOME/.config

echo $XDG_CONFIG_HOME










kubectl run debug-busybox \
  --namespace $NAMESPACE \
  --image=busybox \
  --restart=Never \
  --overrides='{"spec":{"nodeName":"'$(kubectl get pod $NAME -n $NAMESPACE -o jsonpath='{.spec.nodeName}')'"}}' \
  -- /bin/sh -c "sleep infinity"