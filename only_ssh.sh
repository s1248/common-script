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

    # Đảm bảo PubkeyAuthentication được bật
    sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

    # Tắt sử dụng PAM (Pluggable Authentication Modules)
    sudo sed -i 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

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
