#!/bin/bash

# Kiểm tra xem script được chạy với quyền root hay không
if [ "$(id -u)" -ne 0 ]; then
    echo "Bạn cần chạy script này với quyền root (sudo)." >&2
    exit 1
fi

# Cấu hình SSH Server
configure_ssh() {
    # Sửa file cấu hình SSH (/etc/ssh/sshd_config)
    sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#KerberosAuthentication yes/KerberosAuthentication no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    
    # Đảm bảo PubkeyAuthentication được bật
    sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

    # Tắt sử dụng PAM (Pluggable Authentication Modules)
    sudo sed -i 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

    # Tắt sử dụng X11Forwarding để ngăn chiều tấn công từ VPS tới máy client
    sudo sed -i 's/^X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config

    # Thêm vào cuối file nếu chưa tồn tại
    sudo tee -a /etc/ssh/sshd_config <<EOF
# Vô hiệu hóa GSSAPI khi không cần thiết
GSSAPIKeyExchange no

# Vô hiệu hóa sử dụng PAM nếu không cần thiết
UseDNS no
EOF

    # Khởi động lại SSH service để áp dụng các thay đổi
    sudo systemctl restart sshd
}

# Vô hiệu hóa các dịch vụ Remote Desktop (VNC, XRDP)
disable_remote_desktop() {
    # Ngừng và vô hiệu hóa dịch vụ VNC (nếu có)
    sudo systemctl stop vncserver
    sudo systemctl disable vncserver

    # Ngừng và vô hiệu hóa dịch vụ XRDP (nếu có)
    sudo systemctl stop xrdp
    sudo systemctl disable xrdp
}

# Gọi các hàm để cấu hình SSH và vô hiệu hóa Remote Desktop
configure_ssh
disable_remote_desktop

echo "Đã cấu hình máy ảo Ubuntu chỉ cho phép đăng nhập qua SSH bằng private key và vô hiệu hóa các phương thức xác thực khác, cũng như vô hiệu hóa các dịch vụ Remote Desktop."

# Vô hiệu hóa các dịch vụ desktop environment
disable_desktop_services() {
    # Kiểm tra và vô hiệu hóa các dịch vụ quản lý màn hình
    
    # GNOME (GDM)
    if systemctl -q is-active gdm; then
        sudo systemctl stop gdm
        sudo systemctl disable gdm
    fi

    # LightDM (Ubuntu, Xubuntu, Lubuntu, ...)
    if systemctl -q is-active lightdm; then
        sudo systemctl stop lightdm
        sudo systemctl disable lightdm
    fi

    # KDE (KDM)
    if systemctl -q is-active kdm; then
        sudo systemctl stop kdm
        sudo systemctl disable kdm
    fi

    # XFCE (XDM)
    if systemctl -q is-active xdm; then
        sudo systemctl stop xdm
        sudo systemctl disable xdm
    fi

    # LXDE (LXDM)
    if systemctl -q is-active lxdm; then
        sudo systemctl stop lxdm
        sudo systemctl disable lxdm
    fi

    # Các desktop environment khác nếu có
    # Thêm các dịch vụ desktop environment khác nếu cần thiết
}

# Vô hiệu hóa các dịch vụ Remote Desktop
disable_remote_desktop() {
    # VNC Server
    if systemctl -q is-active vncserver; then
        sudo systemctl stop vncserver
        sudo systemctl disable vncserver
    fi

    # XRDP
    if systemctl -q is-active xrdp; then
        sudo systemctl stop xrdp
        sudo systemctl disable xrdp
    fi

    # Các dịch vụ Remote Desktop khác nếu có
    # Thêm các dịch vụ Remote Desktop khác nếu cần thiết
}

# Gọi các hàm để vô hiệu hóa các dịch vụ desktop và Remote Desktop
disable_desktop_services
disable_remote_desktop

# Hiển thị thông báo sau khi hoàn thành
echo "Đã vô hiệu hóa các dịch vụ desktop environment và Remote Desktop liên quan đến Xorg."
