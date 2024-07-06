#!/bin/bash

# Kiểm tra xem script được chạy với quyền root hay không
if [ "$(id -u)" -ne 0 ]; then
    echo "Bạn cần chạy script này với quyền root (sudo)." >&2
    exit 1
fi

# Hỏi người dùng nhập dung lượng swap
read -p "Nhập dung lượng swap (ví dụ: 2G): " SWAP_SIZE
if [ -z "$SWAP_SIZE" ]; then
    echo "Dung lượng swap không được để trống. Hủy thực thi." >&2
    exit 1
fi

# Hỏi người dùng nhập giá trị swappiness
read -p "Nhập giá trị swappiness (ví dụ: 10): " SWAPPINESS
if [ -z "$SWAPPINESS" ]; then
    echo "Giá trị swappiness không được để trống. Hủy thực thi." >&2
    exit 1
fi

# Tạo swap file với dung lượng đã chọn
echo "Tạo swap file với dung lượng $SWAP_SIZE ..."
fallocate -l "$SWAP_SIZE" /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Thêm vào /etc/fstab để swap tự động được kích hoạt sau khi khởi động
echo "/swapfile none swap sw 0 0" >> /etc/fstab

# Cấu hình swappiness theo yêu cầu
echo "Cấu hình swappiness thành $SWAPPINESS ..."
echo "vm.swappiness=$SWAPPINESS" | tee -a /etc/sysctl.conf >/dev/null
sysctl -p

echo "Đã tạo swap với dung lượng $SWAP_SIZE và cấu hình swappiness thành $SWAPPINESS thành công."
