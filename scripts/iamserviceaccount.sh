# !bin/sh
eksctl create iamserviceaccount \
       --cluster=attractive-gopher \
       --namespace=kube-system \
       --name=alb-ingress-controller \
       --attach-policy-arn=$PolicyARN \
       --override-existing-serviceaccounts \
       --approve