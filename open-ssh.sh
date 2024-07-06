sudo apt install ufw -y
sudo ufw allow 22/tcp
sudo ufw enable
sudo ufw status verbose
sudo apt-get install openssh-server -y
sudo systemctl enable ssh --now
sudo systemctl start ssh
mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
sudo apt autoremove -y
