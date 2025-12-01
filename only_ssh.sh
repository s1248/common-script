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
    sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
    sudo sed -i 's/^PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config    
    
    # Đảm bảo PubkeyAuthentication được bật
    sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

    # Tắt sử dụng PAM (Pluggable Authentication Modules)
    sudo sed -i 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

    # Tắt sử dụng X11Forwarding để ngăn chiều tấn công từ VPS tới máy client
    sudo sed -i 's/^X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config

    # Mặc định là 120 giây (2 phút). Đây là khoảng thời gian một client có thể giữ kết nối mở trước khi xác thực thành công. Giảm xuống LoginGraceTime 30. Kẻ tấn công có thể mở nhiều kết nối và giữ chúng trong trạng thái chờ xác thực để làm cạn kiệt tài nguyên máy chủ (tấn công DoS). 30 giây là quá đủ cho một người dùng hợp lệ đăng nhập.
    sudo sed -i 's/^#LoginGraceTime 2m/LoginGraceTime 30/' /etc/ssh/sshd_config

    # Cấu hình Timeout cho Session không hoạt động. Gửi một gói tin "null" sau mỗi 5 phút (300s) để giữ kết nối. Ngắt kết nối nếu không nhận được phản hồi sau 3 lần gửi (tổng cộng 15 phút)
    sudo sed -i 's/^#ClientAliveInterval 0/ClientAliveInterval 300/' /etc/ssh/sshd_config
    sudo sed -i 's/^#ClientAliveCountMax 3/ClientAliveCountMax 3/' /etc/ssh/sshd_config

    # Vô hiệu hóa GSSAPI khi không cần thiết
    sudo sed -i 's/^#GSSAPIKeyExchange no/GSSAPIKeyExchange no/' /etc/ssh/sshd_config
    
    # Vô hiệu hóa sử dụng UseDNS để log hiển thị chính xác IP nào đã kết nối.
    sudo sed -i 's/^#UseDNS no/UseDNS no/' /etc/ssh/sshd_config

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
