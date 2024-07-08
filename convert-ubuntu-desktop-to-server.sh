sudo apt install ubuntu-server -y
sudo systemctl set-default multi-user.target
sudo apt purge ubuntu-desktop -y && sudo apt autoremove -y && sudo apt autoclean -y
sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y
