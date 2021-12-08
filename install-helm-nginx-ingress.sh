#! /bin/sh

# will trigger gcloud auth process
gcloud init --console-only

# will add all necessary API's and registries
echo "Adding Container Google API's..."
gcloud services enable container.googleapis.com
echo "Adding Container Registry..."
gcloud services enable containerregistry.googleapis.com

# will create GKE cluster with with predefined specs
echo "Creating Defined Cluster..."
gcloud beta container clusters create "cluster-1" --zone "europe-west1-c" --no-enable-basic-auth --cluster-version "1.21.5-gke.1302" --release-channel "regular" --machine-type "e2-standard-2" --image-type "COS_CONTAINERD" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "3" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --no-enable-intra-node-visibility --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --node-locations "europe-west1-c"

# after we need to install helm and nginx ingress
echo "Installing Helm..."
# echo -ne '\n' | helm upgrade --install ingress-nginx ingress-nginx \
#  --repo https://kubernetes.github.io/ingress-nginx \
#  --namespace ingress-nginx --create-namespace
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install nginx-ingress ingress-nginx/ingress-nginx
# will wait for nginx ingress to start
echo "Waiting for NGINX to start..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# clone github repo and get into the working folder
echo "Cloning GitHub Repository..."
git clone https://github.com/andrey-zh/app.git
cd app/

# will install deployment / service / ingress from yaml manifest files

echo "Creating app-deployment-v1..."
kubectl apply -f app-deployment-v1.yaml
echo "Creating app-deployment-v2..."
kubectl apply -f app-deployment-v2.yaml
echo "Creating app-service v1 and v2..."
kubectl apply -f app-service-v1-v2.yaml
echo "Creating ingress v1..."
kubectl apply -f ingress-v1.yaml
echo "Creating ingress v2..."
kubectl apply -f ingress-v2.yaml
bash -c echo -ne '\n' | gcloud container clusters get-credentials cluster-1 --zone europe-west1-c
bash -c echo $DEVSHELL_PROJECT_ID
