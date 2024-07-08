sudo apt install ubuntu-server -y
sudo systemctl set-default multi-user.target
sudo apt purge ubuntu-desktop -y && sudo apt autoremove -y && sudo apt autoclean -y
