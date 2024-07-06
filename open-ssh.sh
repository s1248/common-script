sudo apt install ufw -y
sudo ufw allow 22/tcp
sudo ufw enable
sudo ufw status verbose
sudo apt-get install openssh-server -y
sudo systemctl enable ssh --now
sudo systemctl start ssh
