#!/bin/bash

# Hiển thị danh sách các ổ đĩa và phân vùng
echo "Danh sách các ổ đĩa và phân vùng:"
lsblk
echo ""

# Hỏi người dùng chọn ổ đĩa cần mở rộng
read -p "Nhập tên ổ đĩa (ví dụ: /dev/sda): " disk
read -p "Nhập số phân vùng (ví dụ: 1): " partition

# Xác định tên đầy đủ của phân vùng
partition_name="${disk}${partition}"

# Xác nhận lại lựa chọn của người dùng
echo "Bạn đã chọn mở rộng phân vùng ${partition_name} trên ổ đĩa ${disk}."
read -p "Bạn có chắc chắn muốn tiếp tục? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "Quá trình mở rộng đã bị hủy."
    exit 1
fi

# Mở rộng phân vùng
echo "Đang mở rộng phân vùng..."
sudo growpart $disk $partition

# Mở rộng hệ thống tệp
echo "Đang mở rộng hệ thống tệp..."
sudo resize2fs $partition_name

# Kiểm tra kết quả
echo "Kết quả sau khi mở rộng:"
df -h

echo "Quá trình mở rộng phân vùng và hệ thống tệp đã hoàn tất."

