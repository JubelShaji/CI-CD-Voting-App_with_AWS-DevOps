## User data script for aws ec2 instance :
```
#!/bin/bash
set -euxo pipefail

# Update package list and install necessary dependencies
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https

# Install Docker dependencies
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update and install Docker
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Add the 'ubuntu' user to the 'docker' group to allow running Docker without 'sudo'
sudo usermod -aG docker ubuntu

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create kind-config.yaml for the Kubernetes cluster configuration
cat <<EOF | sudo tee /home/ubuntu/kind-config.yaml > /dev/null
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30000
        hostPort: 8080
        protocol: TCP
      - containerPort: 30001
        hostPort: 80
        protocol: TCP
      - containerPort: 30002
        hostPort: 81
        protocol: TCP
  - role: worker
EOF

# Change ownership of the kind-config.yaml file to 'ubuntu' user
sudo chown ubuntu:ubuntu /home/ubuntu/kind-config.yaml

# Notify the user to log out and log back in
echo "The ubuntu user has been added to the docker group. Please log out and log back in for the changes to take effect."

# Create the Kubernetes cluster using the generated config (run as ubuntu)
sudo -u ubuntu kind create cluster --config /home/ubuntu/kind-config.yaml

```
