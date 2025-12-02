# Add user dockremap
sudo userdel -r dockremap 2>/dev/null || true
sudo groupdel dockremap 2>/dev/null || true
sudo groupadd -g 100000 dockremap
sudo useradd \
  -u 100000 \
  -g 100000 \
  -s /usr/sbin/nologin \
  -d /nonexistent \
  -M \
  -c "Docker User Namespace" \
  dockremap
sudo mkdir /etc/docker
sudo cat > /etc/docker/daemon.json <<EOF
{
  "userns-remap": "dockremap"
}
EOF
echo "dockremap:100000:65536" | sudo tee /etc/subuid
echo "dockremap:100000:65536" | sudo tee /etc/subgid

# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
