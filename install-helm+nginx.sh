#! /bin/sh
wget https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz
tar xfz helm-v3.7.1-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin/
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install nginx-ingress ingress-nginx/ingress-nginx
