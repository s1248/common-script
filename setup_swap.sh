#!/bin/bash

# Sử dụng lệnh sau để cài đặt
# wget --no-cache -O setup_swap.sh https://raw.githubusercontent.com/s1248/common-script/master/setup_swap.sh && chmod +x setup_swap.sh && sudo ./setup_swap.sh

# Kiểm tra xem script được chạy với quyền root hay không
if [ "$(id -u)" -ne 0 ]; then
    echo "Bạn cần chạy script này với quyền root (sudo)." >&2
    exit 1
fi

# Hàm hỏi người dùng và xác nhận giá trị
ask_user() {
    local prompt="$1"
    local default_value="$2"
    local value
    read -p "$prompt [$default_value]: " value
    echo "${value:-$default_value}"  # Trả về giá trị mới hoặc mặc định
}

# Hỏi người dùng dung lượng swap muốn tạo
SWAP_SIZE=$(ask_user "Nhập dung lượng swap muốn tạo (ví dụ: 2G)" "2G")
if [ -z "$SWAP_SIZE" ]; then
    echo "Dung lượng swap không được để trống. Hủy thực thi." >&2
    exit 1
fi

# Hỏi người dùng giá trị swappiness muốn đặt
SWAPPINESS=$(ask_user "Nhập giá trị swappiness muốn đặt (ví dụ: 10)" "10")
if [ -z "$SWAPPINESS" ]; then
    echo "Giá trị swappiness không được để trống. Hủy thực thi." >&2
    exit 1
fi

# Tắt tất cả các swap hiện tại
echo "Tắt tất cả các swap hiện tại..."
sudo swapoff -a

# Xóa tệp swap hiện tại (nếu tồn tại)
if [ -f /swapfile ]; then
    echo "Xóa tệp swap hiện tại..."
    sudo rm /swapfile
fi

# Xóa tất cả các dòng liên quan đến swap trong /etc/fstab
echo "Xóa tất cả các dòng liên quan đến swap trong /etc/fstab..."
sudo sed -i '/swap/d' /etc/fstab

# Tạo swap file mới với dung lượng đã chọn
echo "Tạo swap file với dung lượng $SWAP_SIZE ..."
sudo fallocate -l "$SWAP_SIZE" /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Thêm vào /etc/fstab để swap tự động được kích hoạt sau khi khởi động
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null

# Xóa cài đặt swappiness hiện tại
echo "Xóa cài đặt swappiness hiện tại..."
sudo sed -i '/vm.swappiness/d' /etc/sysctl.conf

# Cấu hình swappiness mới theo yêu cầu
echo "Cấu hình swappiness thành $SWAPPINESS ..."
echo "vm.swappiness=$SWAPPINESS" | sudo tee -a /etc/sysctl.conf >/dev/null
sudo sysctl -p

echo "Đã tạo swap với dung lượng $SWAP_SIZE và cấu hình swappiness thành $SWAPPINESS vĩnh viễn thành công."
