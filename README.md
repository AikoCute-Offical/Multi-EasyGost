# Multi-EasyGost一Nguyên tắc sử dụng Key Script
***
## Cảm ơnn: 
1. Cảm ơn @ginuerzh vì sự phát triển [gost](https://github.com/ginuerzh/gost) Chương trình đường hầm, mạnh mẽ và dễ sử dụng, bạn bè nào muốn biết thêm về nó có thể xem qua[官方文档](https://docs.ginuerzh.xyz/gost/)
2. Cảm ơn anh chàng lớn @fengxiaoxiaoxiyishuihan [原始脚本](https://www.fiisi.com/?p=125)
3. Nhờ tập lệnh EasyGost (thư viện đã xóa) do @STSDUST cung cấp, tập lệnh này được sửa đổi và nâng cao dựa trên nó
***
## Giới thiệu

> Địa chỉ dự án và tài liệu trợ giúp: 
> https://github.com/AikoCute/Multi-EasyGost
***
## kịch bản

* kịch bản khởi động
  `wget --no-check-certificate -O gost.sh https://raw.githubusercontent.com/KANIKIG/Multi-EasyGost/master/gost.sh && chmod +x gost.sh && ./gost.sh`  
* Để chạy lại tập lệnh, chỉ cần nhập`./gost.sh` Quay lại thôi 

## Chức năng
### Chức năng tập lệnh gốc

- Các tệp cấu hình systemd và gost được triển khai để quản lý gost
- Nhiều quy tắc chuyển tiếp có hiệu lực cùng lúc mà không cần sự trợ giúp của các công cụ khác (chẳng hạn như màn hình)
- Việc chuyển tiếp không bị lỗi sau khi máy khởi động lại
- Các loại chuyển được hỗ trợ:
   - chuyển tiếp tcp + udp mà không cần mã hóa
   - mã hóa relay + tls

### Có gì mới trong tập lệnh này

- Đã thêm chức năng lựa chọn loại chuyển
- Loại chuyển mới được hỗ trợ
   - relay + ws
   - relay + wss
- Một cú nhấp chuột tạo proxy ss hoặc vớ5 trên máy đích (tích hợp sẵn gost)
- Cân bằng tải đơn giản đa điểm hạ cánh hỗ trợ nhiều kiểu truyền dẫn
- Đã thêm nhân bản tải xuống tăng tốc trong nước gost
- Tạo hoặc xóa đơn giản các tác vụ khởi động lại theo lịch trình gost
- Tập lệnh để tự động kiểm tra các bản cập nhật
- Chuyển tiếp ip của nút tự chọn CDN
- Hỗ trợ chứng chỉ TLS tùy chỉnh, ứng dụng một cú nhấp chuột cho chứng chỉ khi hạ cánh và xác minh chứng chỉ để chuyển tuyến

## hiển thị chức năng

![iShot2020-12-14下午05.42.23.png](https://i.loli.net/2020/12/14/q75PO6s2DMIcUKB.png)

![iShot2020-12-14下午05.42.39.png](https://i.loli.net/2020/12/14/vzpGlWmPtCrneOY.png)

![2](https://i.loli.net/2020/10/16/fBHgwStVQxc821z.png)

![3](https://i.loli.net/2020/10/16/xgZ6eVAwSzDUFjO.png)

![4](https://i.loli.net/2020/10/16/lt6uAzI5X7yYWhr.png)

![iShot2020-12-14下午05.43.46.png](https://i.loli.net/2020/12/14/YjiFTMCKs8lANbI.png)

![iShot2020-12-14下午05.43.11.png](https://i.loli.net/2020/12/14/VIcQSsoUaqpzx5T.png)