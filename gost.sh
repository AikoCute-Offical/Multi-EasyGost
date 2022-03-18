#! /bin/bash
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[thông tin]${Font_color_suffix}"
Error="${Red_font_prefix}[sai lầm, điều sai, ngộ nhận]${Font_color_suffix}"
shell_version="1.1.0"
gost_conf_path="/etc/gost/config.json"
raw_conf_path="/etc/gost/rawconf"
function checknew() {
  checknew=$(gost -V 2>&1 | awk '{print $2}')
  check_new_ver
  echo "Phiên bản gost của bạn là:""$checknew"""
  echo -n 是否更新\(y/n\)\:
  read checknewnum
  if test $checknewnum = "y"; then
    cp -r /etc/gost /tmp/
    Install_ct
    rm -rf /etc/gost
    mv /tmp/gost /etc/
    systemctl restart gost
  else
    exit 0
  fi
}
function check_sys() {
  if [[ -f /etc/redhat-release ]]; then
    release="centos"
  elif cat /etc/issue | grep -q -E -i "debian"; then
    release="debian"
  elif cat /etc/issue | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  elif cat /proc/version | grep -q -E -i "debian"; then
    release="debian"
  elif cat /proc/version | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  fi
  bit=$(uname -m)
  if test "$bit" != "x86_64"; then
    echo "Vui lòng nhập kiến ​​trúc chip của bạn，/386/armv5/armv6/armv7/armv8"
    read bit
  else
    bit="amd64"
  fi
}
function Installation_dependency() {
  gzip_ver=$(gzip -V)
  if [[ -z ${gzip_ver} ]]; then
    if [[ ${release} == "centos" ]]; then
      yum update
      yum install -y gzip wget
    else
      apt-get update
      apt-get install -y gzip wget
    fi
  fi
}
function check_root() {
  [[ $EUID != 0 ]] && echo -e "${Error} Tài khoản không ROOT hiện tại (hoặc không có quyền ROOT) không thể tiếp tục hoạt động, vui lòng thay đổi tài khoản ROOT hoặc sử dụng ${Green_background_prefix}sudo su${Font_color_suffix} Lệnh này nhận được quyền ROOT tạm thời (bạn có thể được nhắc nhập mật khẩu của tài khoản hiện tại sau khi thực hiện)." && exit 1
}
function check_new_ver() {
  ct_new_ver=$(wget --no-check-certificate -qO- -t2 -T3 https://api.github.com/repos/ginuerzh/gost/releases/latest | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g;s/v//g')
  if [[ -z ${ct_new_ver} ]]; then
    ct_new_ver="2.11.1"
    echo -e "${Error} gost Không tải được phiên bản mới nhất, đang tải xuống v${ct_new_ver}版"
  else
    echo -e "${Info} gost Phiên bản mới nhất là ${ct_new_ver}"
  fi
}
function check_file() {
  if test ! -d "/usr/lib/systemd/system/"; then
    mkdir /usr/lib/systemd/system
    chmod -R 777 /usr/lib/systemd/system
  fi
}
function check_nor_file() {
  rm -rf "$(pwd)"/gost
  rm -rf "$(pwd)"/gost.service
  rm -rf "$(pwd)"/config.json
  rm -rf /etc/gost
  rm -rf /usr/lib/systemd/system/gost.service
  rm -rf /usr/bin/gost
}
function Install_ct() {
  check_root
  check_nor_file
  Installation_dependency
  check_file
  check_sys
  check_new_ver
  echo -e "Nếu là máy nội địa thì nên sử dụng gương đại lục để tăng tốc tải"
  read -e -p "sử dụng hay không? [y/n]:" addyn
  [[ -z ${addyn} ]] && addyn="n"
  if [[ ${addyn} == [Yy] ]]; then
    rm -rf gost-linux-"$bit"-"$ct_new_ver".gz
    wget --no-check-certificate https://gotunnel.oss-cn-shenzhen.aliyuncs.com/gost-linux-"$bit"-"$ct_new_ver".gz
    gunzip gost-linux-"$bit"-"$ct_new_ver".gz
    mv gost-linux-"$bit"-"$ct_new_ver" gost
    mv gost /usr/bin/gost
    chmod -R 777 /usr/bin/gost
    wget --no-check-certificate https://gotunnel.oss-cn-shenzhen.aliyuncs.com/gost.service && chmod -R 777 gost.service && mv gost.service /usr/lib/systemd/system
    mkdir /etc/gost && wget --no-check-certificate https://gotunnel.oss-cn-shenzhen.aliyuncs.com/config.json && mv config.json /etc/gost && chmod -R 777 /etc/gost
  else
    rm -rf gost-linux-"$bit"-"$ct_new_ver".gz
    wget --no-check-certificate https://github.com/ginuerzh/gost/releases/download/v"$ct_new_ver"/gost-linux-"$bit"-"$ct_new_ver".gz
    gunzip gost-linux-"$bit"-"$ct_new_ver".gz
    mv gost-linux-"$bit"-"$ct_new_ver" gost
    mv gost /usr/bin/gost
    chmod -R 777 /usr/bin/gost
    wget --no-check-certificate https://raw.githubusercontent.com/KANIKIG/Multi-EasyGost/master/gost.service && chmod -R 777 gost.service && mv gost.service /usr/lib/systemd/system
    mkdir /etc/gost && wget --no-check-certificate https://raw.githubusercontent.com/KANIKIG/Multi-EasyGost/master/config.json && mv config.json /etc/gost && chmod -R 777 /etc/gost
  fi

  systemctl enable gost && systemctl restart gost
  echo "------------------------------"
  if test -a /usr/bin/gost -a /usr/lib/systemctl/gost.service -a /etc/gost/config.json; then
    echo "gost được cài đặt thành công"
    rm -rf "$(pwd)"/gost
    rm -rf "$(pwd)"/gost.service
    rm -rf "$(pwd)"/config.json
  else
    echo "gost không được cài đặt thành công"
    rm -rf "$(pwd)"/gost
    rm -rf "$(pwd)"/gost.service
    rm -rf "$(pwd)"/config.json
    rm -rf "$(pwd)"/gost.sh
  fi
}
function Uninstall_ct() {
  rm -rf /usr/bin/gost
  rm -rf /usr/lib/systemd/system/gost.service
  rm -rf /etc/gost
  rm -rf "$(pwd)"/gost.sh
  echo "gost đã được xóa thành công"
}
function Start_ct() {
  systemctl start gost
  echo "đã kích hoạt"
}
function Stop_ct() {
  systemctl stop gost
  echo "dừng lại"
}
function Restart_ct() {
  rm -rf /etc/gost/config.json
  confstart
  writeconf
  conflast
  systemctl restart gost
  echo "Đọc lại cấu hình và khởi động lại"
}
function read_protocol() {
  echo -e "Bạn muốn đặt chức năng nào: "
  echo -e "-----------------------------------"
  echo -e "[1] chuyển tiếp lưu lượng tcp + udp, không có mã hóa"
  echo -e "Mô tả: Nói chung được đặt trên máy bay trung chuyển nội địa"
  echo -e "-----------------------------------"
  echo -e "[2] Chuyển tiếp lưu lượng đường hầm được mã hóa"
  echo -e "Mô tả: Nó được sử dụng để chuyển tiếp lưu lượng truy cập với mức mã hóa thấp hơn và thường được đặt trên máy bay vận chuyển nội địa"
  echo -e "     Chọn giao thức này có nghĩa là bạn vẫn có một máy để nhận lưu lượng được mã hóa này và sau đó bạn phải định cấu hình giao thức [3] trên máy đó để gắn"
  echo -e "-----------------------------------"
  echo -e "[3] Giải mã và chuyển tiếp lưu lượng truy cập từ gost"
  echo -e "Giải thích: Đối với lưu lượng được truyền qua mã hóa gost, tùy chọn này được sử dụng để giải mã và chuyển tiếp đến cổng dịch vụ proxy của máy cục bộ hoặc tới các máy từ xa khác"
  echo -e "      Nói chung được đặt trên các máy nước ngoài được sử dụng để nhận lưu lượng chuyển tuyến"
  echo -e "-----------------------------------"
  echo -e "[4] Cài đặt proxy ss / vớ5 bằng một cú nhấp chuột"
  echo -e "Mô tả: sử dụng giao thức proxy tích hợp của gost, nhẹ và dễ quản lý"
  echo -e "-----------------------------------"
  echo -e "[5] Nâng cao: Nhiều lần hạ cánh để cân bằng tải"
  echo -e "Mô tả: Cân bằng tải đơn giản hỗ trợ các phương pháp mã hóa khác nhau"
  echo -e "-----------------------------------"
  echo -e "[6] Nâng cao: Chuyển tiếp nút tự chọn CDN"
  echo -e "Mô tả: Chỉ cần đặt nó trên máy chuyển"
  echo -e "-----------------------------------"
  read -p "xin vui lòng chọn: " numprotocol

  if [ "$numprotocol" == "1" ]; then
    flag_a="nonencrypt"
  elif [ "$numprotocol" == "2" ]; then
    encrypt
  elif [ "$numprotocol" == "3" ]; then
    decrypt
  elif [ "$numprotocol" == "4" ]; then
    proxy
  elif [ "$numprotocol" == "5" ]; then
    enpeer
  elif [ "$numprotocol" == "6" ]; then
    cdn
  else
    echo "type error, please try again"
    exit
  fi
}
function read_s_port() {
  if [ "$flag_a" == "ss" ]; then
    echo -e "-----------------------------------"
    read -p "Vui lòng nhập mật khẩu ss: " flag_b
  elif [ "$flag_a" == "socks" ]; then
    echo -e "-----------------------------------"
    read -p "Vui lòng nhập mật khẩu vớ: " flag_b
  else
    echo -e "------------------------------------------------------------------"
    echo -e "Bạn muốn chuyển tiếp lưu lượng nhận được trên máy này qua cổng nào?"
    read -p "vui lòng nhập: " flag_b
  fi
}
function read_d_ip() {
  if [ "$flag_a" == "ss" ]; then
    echo -e "------------------------------------------------------------------"
    echo -e "Tôi có thể hỏi mã hóa ss mà bạn muốn đặt không (chỉ những mã được sử dụng phổ biến mới được cung cấp):"
    echo -e "-----------------------------------"
    echo -e "[1] aes-256-gcm"
    echo -e "[2] aes-256-cfb"
    echo -e "[3] chacha20-ietf-poly1305"
    echo -e "[4] chacha20"
    echo -e "[5] rc4-md5"
    echo -e "[6] AEAD_CHACHA20_POLY1305"
    echo -e "-----------------------------------"
    read -p "Vui lòng chọn phương pháp mã hóa ss: " ssencrypt

    if [ "$ssencrypt" == "1" ]; then
      flag_c="aes-256-gcm"
    elif [ "$ssencrypt" == "2" ]; then
      flag_c="aes-256-cfb"
    elif [ "$ssencrypt" == "3" ]; then
      flag_c="chacha20-ietf-poly1305"
    elif [ "$ssencrypt" == "4" ]; then
      flag_c="chacha20"
    elif [ "$ssencrypt" == "5" ]; then
      flag_c="rc4-md5"
    elif [ "$ssencrypt" == "6" ]; then
      flag_c="AEAD_CHACHA20_POLY1305"
    else
      echo "type error, please try again"
      exit
    fi
  elif [ "$flag_a" == "socks" ]; then
    echo -e "-----------------------------------"
    read -p "Vui lòng nhập tên người dùng vớ: " flag_c
  elif [[ "$flag_a" == "peer"* ]]; then
    echo -e "------------------------------------------------------------------"
    echo -e "Vui lòng nhập tên tệp danh sách đích"
    read -e -p "Không nên lặp lại các cấu hình tùy chỉnh nhưng khác nhau, không nhập hậu tố, chẳng hạn như ips1, iplist2:" flag_c
    touch $flag_c.txt
    echo -e "------------------------------------------------------------------"
    echo -e "Vui lòng nhập lần lượt ip đích và cổng bạn muốn cân bằng tải"
    while true; do
      echo -e "Bạn có muốn đổi máy từ${flag_b}IP hoặc tên miền mà lưu lượng đã nhận được chuyển tiếp đến?"
      read -p "vui lòng nhập: " peer_ip
      echo -e "Bạn có muốn đổi máy từ${flag_b}Lưu lượng đã nhận được chuyển tiếp tới${peer_ip}cảng nào của?"
      read -p "vui lòng nhập: " peer_port
      echo -e "$peer_ip:$peer_port" >>$flag_c.txt
      read -e -p "Tiếp tục thêm đổ bộ? [Y/n]:" addyn
      [[ -z ${addyn} ]] && addyn="y"
      if [[ ${addyn} == [Nn] ]]; then
        echo -e "------------------------------------------------------------------"
        echo -e "đã được tạo trong thư mục gốc$flag_c.txt, bạn có thể chỉnh sửa tệp này bất kỳ lúc nào để sửa đổi thông tin đích và khởi động lại gost để có hiệu lực"
        echo -e "------------------------------------------------------------------"
        break
      else
        echo -e "------------------------------------------------------------------"
        echo -e "Tiếp tục thêm cấu hình hạ cánh tải trọng cân bằng"
      fi
    done
  elif [[ "$flag_a" == "cdn"* ]]; then
    echo -e "------------------------------------------------------------------"
    echo -e "chuyển đơn vị từ${flag_b}IP tự chọn để chuyển tiếp lưu lượng đã nhận:"
    read -p "vui lòng nhập: " flag_c
    echo -e "Bạn có muốn đổi máy từ${flag_b}Lưu lượng đã nhận được chuyển tiếp tới${flag_c}cảng nào của?"
    echo -e "[1] 80"
    echo -e "[2] 443"
    echo -e "[3] Cổng tùy chỉnh (chẳng hạn như 8080, v.v.)"
    read -p "Vui lòng chọn một cổng: " cdnport
    if [ "$cdnport" == "1" ]; then
      flag_c="$flag_c:80"
    elif [ "$cdnport" == "2" ]; then
      flag_c="$flag_c:443"
    elif [ "$cdnport" == "3" ]; then
      read -p "Vui lòng nhập cổng tùy chỉnh: " customport
      flag_c="$flag_c:$customport"
    else
      echo "type error, please try again"
      exit
    fi
  else
    echo -e "------------------------------------------------------------------"
    echo -e "Bạn có muốn đổi máy từ${flag_b}IP hoặc tên miền mà lưu lượng đã nhận được chuyển tiếp đến?"
    echo -e "Lưu ý: IP có thể là IP công cộng của [máy từ xa / máy hiện tại] hoặc IP lặp cục bộ của máy này (tức là 127.0.0.1)"
    echo -e "Việc điền địa chỉ IP cụ thể phụ thuộc vào IP mà dịch vụ nhận lưu lượng đang nghe (xem: https://github.com/KANIKIG/Multi-EasyGost)"
    if [[ ${is_cert} == [Yy] ]]; then
      echo -e "Lưu ý: Khi máy đích mở chứng chỉ TLS tùy chỉnh, hãy nhớ điền vào${Red_font_prefix}tên miền${Font_color_suffix}"
    fi
    read -p "vui lòng nhập: " flag_c
  fi
}
function read_d_port() {
  if [ "$flag_a" == "ss" ]; then
    echo -e "------------------------------------------------------------------"
    echo -e "Tôi có thể yêu cầu bạn đặt cổng của dịch vụ proxy ss được không?"
    read -p "vui lòng nhập: " flag_d
  elif [ "$flag_a" == "socks" ]; then
    echo -e "------------------------------------------------------------------"
    echo -e "Tôi có thể yêu cầu bạn đặt cổng của dịch vụ proxy vớ được không?"
    read -p "vui lòng nhập: " flag_d
  elif [[ "$flag_a" == "peer"* ]]; then
    echo -e "------------------------------------------------------------------"
    echo -e "Chính sách cân bằng tải bạn muốn đặt: "
    echo -e "-----------------------------------"
    echo -e "[1] round - thăm dò ý kiến"
    echo -e "[2] random - ngẫu nhiên"
    echo -e "[3] fifo - từ trên xuống"
    echo -e "-----------------------------------"
    read -p "Vui lòng chọn loại cân bằng tải: " numstra

    if [ "$numstra" == "1" ]; then
      flag_d="round"
    elif [ "$numstra" == "2" ]; then
      flag_d="random"
    elif [ "$numstra" == "3" ]; then
      flag_d="fifo"
    else
      echo "type error, please try again"
      exit
    fi
  elif [[ "$flag_a" == "cdn"* ]]; then
    echo -e "------------------------------------------------------------------"
    read -p "Vui lòng nhập máy chủ:" flag_d
  else
    echo -e "------------------------------------------------------------------"
    echo -e "Bạn có muốn đổi máy từ${flag_b}Lưu lượng đã nhận được chuyển tiếp tới${flag_c}cảng nào của?"
    read -p "vui lòng nhập: " flag_d
    if [[ ${is_cert} == [Yy] ]]; then
      flag_d="$flag_d?secure=true"
    fi
  fi
}
function writerawconf() {
  echo $flag_a"/""$flag_b""#""$flag_c""#""$flag_d" >>$raw_conf_path
}
function rawconf() {
  read_protocol
  read_s_port
  read_d_ip
  read_d_port
  writerawconf
}
function eachconf_retrieve() {
  d_server=${trans_conf#*#}
  d_port=${d_server#*#}
  d_ip=${d_server%#*}
  flag_s_port=${trans_conf%%#*}
  s_port=${flag_s_port#*/}
  is_encrypt=${flag_s_port%/*}
}
function confstart() {
  echo "{
    \"Debug\": true,
    \"Retries\": 0,
    \"ServeNodes\": [" >>$gost_conf_path
}
function multiconfstart() {
  echo "        {
            \"Retries\": 0,
            \"ServeNodes\": [" >>$gost_conf_path
}
function conflast() {
  echo "    ]
}" >>$gost_conf_path
}
function multiconflast() {
  if [ $i -eq $count_line ]; then
    echo "            ]
        }" >>$gost_conf_path
  else
    echo "            ]
        }," >>$gost_conf_path
  fi
}
function encrypt() {
  echo -e "Bạn muốn đặt kiểu truyền chuyển tiếp nào?: "
  echo -e "-----------------------------------"
  echo -e "[1] đường hầm tls"
  echo -e "[2] đường hầm ws"
  echo -e "[3] đường hầm wss"
  echo -e "Lưu ý: Đối với cùng một chuyển tiếp, kiểu truyền chuyển tiếp và chuyển tiếp phải tương ứng! Tập lệnh này cho phép tcp + udp theo mặc định"
  echo -e "-----------------------------------"
  read -p "Vui lòng chọn loại hình vận tải chuyển tiếp: " numencrypt

  if [ "$numencrypt" == "1" ]; then
    flag_a="encrypttls"
    echo -e "Lưu ý: Chọn Có để bật xác minh chứng chỉ cho chứng chỉ tùy chỉnh đích để đảm bảo an ninh và đảm bảo điền vào máy đích sau này${Red_font_prefix} tên miền ${Font_color_suffix}"
    read -e -p "Máy đích có bật chứng chỉ TLS tùy chỉnh không? [y/n]:" is_cert
  elif [ "$numencrypt" == "2" ]; then
    flag_a="encryptws"
  elif [ "$numencrypt" == "3" ]; then
    flag_a="encryptwss"
    echo -e "Lưu ý: Chọn Có để bật xác minh chứng chỉ cho chứng chỉ tùy chỉnh đích để đảm bảo an ninh và đảm bảo điền vào máy đích sau này${Red_font_prefix} tên miền ${Font_color_suffix}"
    read -e -p "Máy đích có bật chứng chỉ TLS tùy chỉnh không? [y/n]:" is_cert
  else
    echo "type error, please try again"
    exit
  fi
}
function enpeer() {
  echo -e "Bạn muốn thiết lập loại truyền tải cân bằng tải nào?: "
  echo -e "-----------------------------------"
  echo -e "[1] Chuyển tiếp không được mã hóa"
  echo -e "[2] đường hầm tls"
  echo -e "[3] đường hầm ws"
  echo -e "[4] đường hầm wss"
  echo -e "Lưu ý: Đối với cùng một chuyển tiếp, kiểu truyền chuyển tiếp và đường truyền hạ cánh phải tương ứng! Tập lệnh này mặc định cho cùng một kiểu truyền trong cùng một cấu hình"
  echo -e "Tập lệnh này chỉ hỗ trợ cân bằng tải đơn giản, vui lòng tham khảo tài liệu chính thức để biết chi tiết"
  echo -e "Tài liệu chính thức về cân bằng tải của Gost: https://docs.ginuerzh.xyz/gost/load-balancing"
  echo -e "-----------------------------------"
  read -p "Vui lòng chọn loại hình vận tải chuyển tiếp: " numpeer

  if [ "$numpeer" == "1" ]; then
    flag_a="peerno"
  elif [ "$numpeer" == "2" ]; then
    flag_a="peertls"
  elif [ "$numpeer" == "3" ]; then
    flag_a="peerws"
  elif [ "$numpeer" == "4" ]; then
    flag_a="peerwss"

  else
    echo "type error, please try again"
    exit
  fi
}
function cdn() {
  echo -e "Bạn muốn thiết lập kiểu truyền CDN nào? : "
  echo -e "-----------------------------------"
  echo -e "[1] Chuyển tiếp không được mã hóa"
  echo -e "[2] đường hầm ws"
  echo -e "[3] đường hầm wss"
  echo -e "Lưu ý: Đối với cùng một chuyển tiếp, loại chuyển tiếp và chuyển tiếp hạ cánh phải tương ứng!"
  echo -e "Chức năng này chỉ cần được thiết lập trong máy chuyển"
  echo -e "-----------------------------------"
  read -p "Vui lòng chọn loại vận chuyển chuyển tiếp CDN: " numcdn

  if [ "$numcdn" == "1" ]; then
    flag_a="cdnno"
  elif [ "$numcdn" == "2" ]; then
    flag_a="cdnws"
  elif [ "$numcdn" == "3" ]; then
    flag_a="cdnwss"
  else
    echo "type error, please try again"
    exit
  fi
}
function cert() {
  echo -e "-----------------------------------"
  echo -e "[1] Ứng dụng chứng chỉ một cú nhấp chuột ACME"
  echo -e "[2] Tải lên chứng chỉ theo cách thủ công"
  echo -e "-----------------------------------"
  echo -e "Lưu ý: Nó chỉ được sử dụng cho cấu hình máy đích. Chứng chỉ gost tích hợp mặc định có thể gây ra sự cố bảo mật. Hãy sử dụng chứng chỉ tùy chỉnh để cải thiện bảo mật"
  echo -e "Sau khi cấu hình, nó sẽ có hiệu lực cho tất cả giải mã tls / wss của máy này, không cần thiết lập lại"
  read -p "Vui lòng chọn một phương pháp tạo chứng chỉ: " numcert

  if [ "$numcert" == "1" ]; then
    check_sys
    if [[ ${release} == "centos" ]]; then
      yum install -y socat
    else
      apt-get install -y socat
    fi
    read -p "Vui lòng nhập email tài khoản ZeroSSL của bạn (đăng ký tại zerossl.com):" zeromail
    read -p "Vui lòng nhập tên miền được phân giải cho máy này:" domain
    curl https://get.acme.sh | sh
    "$HOME"/.acme.sh/acme.sh --set-default-ca --server zerossl
    "$HOME"/.acme.sh/acme.sh --register-account -m "${zeromail}" --server zerossl
    echo -e "Chương trình ứng dụng chứng chỉ ACME đã được cài đặt thành công"
    echo -e "-----------------------------------"
    echo -e "[1] Ứng dụng HTTP (yêu cầu không có cổng 80) "
    echo -e "[2] Yêu cầu API Cloudflare DNS (yêu cầu APIKEY)"
    echo -e "-----------------------------------"
    read -p "Vui lòng chọn phương thức đăng ký chứng chỉ: " certmethod
    if [ "certmethod" == "1" ]; then
      echo -e "Vui lòng xác nhận đơn vị này ${Red_font_prefix} 80 ${Font_color_suffix} Cổng không bị chiếm dụng, nếu không ứng dụng sẽ bị lỗi"
      if "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --standalone -k ec-256 --force; then
        echo -e "Chứng chỉ SSL được tạo thành công và chứng chỉ ECC bảo mật cao được áp dụng theo mặc định"
        if [ ! -d "$HOME/gost_cert" ]; then
          mkdir $HOME/gost_cert
        fi
        if "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath $HOME/gost_cert/cert.pem --keypath $HOME/gost_cert/key.pem --ecc --force; then
          echo -e "Chứng chỉ SSL được định cấu hình thành công và sẽ tự động được gia hạn. Chứng chỉ và khóa nằm trong thư mục ${Red_font_prefix} gost_cert ${Font_color_suffix} trong thư mục người dùng"
          echo -e "Không thay đổi tên thư mục chứng chỉ và tên tệp chứng chỉ; xóa thư mục gost_cert và khởi động lại bằng tập lệnh, tức là tự động bật chứng chỉ tích hợp sẵn gost"
          echo -e "-----------------------------------"
        fi
      else
        echo -e "Tạo chứng chỉ SSL không thành công"
        exit 1
      fi
    else
      read -p "Vui lòng nhập email tài khoản Cloudflare của bạn: " cfmail
      read -p "Vui lòng nhập Khóa API toàn cầu của Cloudflare: " cfkey
      export CF_Key="${cfkey}"
      export CF_Email="${cfmail}"
      if "$HOME"/.acme.sh/acme.sh --issue --dns dns_cf -d "${domain}" --standalone -k ec-256 --force; then
        echo -e "Chứng chỉ SSL được tạo thành công và chứng chỉ ECC bảo mật cao được áp dụng theo mặc định"
        if [ ! -d "$HOME/gost_cert" ]; then
          mkdir $HOME/gost_cert
        fi
        if "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath $HOME/gost_cert/cert.pem --keypath $HOME/gost_cert/key.pem --ecc --force; then
          echo -e "Chứng chỉ SSL được định cấu hình thành công và sẽ tự động được gia hạn. Chứng chỉ và khóa nằm trong thư mục ${Red_font_prefix} gost_cert ${Font_color_suffix} trong thư mục người dùng"
          echo -e "Không thay đổi tên thư mục chứng chỉ và tên tệp chứng chỉ; sử dụng tập lệnh để khởi động lại sau khi xóa thư mục gost_cert, tức là bật lại chứng chỉ tích hợp trong gost"
          echo -e "-----------------------------------"
        fi
      else
        echo -e "Tạo chứng chỉ SSL không thành công"
        exit 1
      fi
    fi

  elif [ "$numcert" == "2" ]; then
    if [ ! -d "$HOME/gost_cert" ]; then
      mkdir $HOME/gost_cert
    fi
    echo -e "-----------------------------------"
    echo -e "Thư mục ${Red_font_prefix} gost_cert ${Font_color_suffix} đã được tạo trong thư mục người dùng, vui lòng tải lên tệp chứng chỉ cert.pem và tệp khóa key.pem vào thư mục này"
    echo -e "Tên tệp của chứng chỉ và khóa phải giống như ở trên và không được thay đổi tên thư mục."
    echo -e "Sau khi tải lên thành công, khởi động lại gost với tập lệnh sẽ tự động kích hoạt nó, không cần thiết lập lại; xóa thư mục gost_cert và khởi động lại với tập lệnh, tức là kích hoạt lại chứng chỉ tích hợp trong gost"
    echo -e "-----------------------------------"
  else
    echo "type error, please try again"
    exit
  fi
}
function decrypt() {
  echo -e "Bạn muốn đặt kiểu truyền giải mã nào?: "
  echo -e "-----------------------------------"
  echo -e "[1] tls"
  echo -e "[2] ws"
  echo -e "[3] wss"
  echo -e "Lưu ý: Đối với cùng một chuyển tiếp, kiểu truyền chuyển tiếp và chuyển tiếp phải tương ứng! Tập lệnh này cho phép tcp + udp theo mặc định"
  echo -e "-----------------------------------"
  read -p "Vui lòng chọn loại chuyển giải mã: " numdecrypt

  if [ "$numdecrypt" == "1" ]; then
    flag_a="decrypttls"
  elif [ "$numdecrypt" == "2" ]; then
    flag_a="decryptws"
  elif [ "$numdecrypt" == "3" ]; then
    flag_a="decryptwss"
  else
    echo "type error, please try again"
    exit
  fi
}
function proxy() {
  echo -e "------------------------------------------------------------------"
  echo -e "Bạn muốn đặt loại proxy nào?: "
  echo -e "-----------------------------------"
  echo -e "[1] shadowsocks"
  echo -e "[2] socks5(Chúng tôi thực sự khuyên bạn nên thêm một đường hầm cho Telegram proxy)"
  echo -e "-----------------------------------"
  read -p "Vui lòng chọn một loại proxy: " numproxy
  if [ "$numproxy" == "1" ]; then
    flag_a="ss"
  elif [ "$numproxy" == "2" ]; then
    flag_a="socks"
  else
    echo "type error, please try again"
    exit
  fi
}
function method() {
  if [ $i -eq 1 ]; then
    if [ "$is_encrypt" == "nonencrypt" ]; then
      echo "        \"tcp://:$s_port/$d_ip:$d_port\",
        \"udp://:$s_port/$d_ip:$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "cdnno" ]; then
      echo "        \"tcp://:$s_port/$d_ip?host=$d_port\",
        \"udp://:$s_port/$d_ip?host=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "peerno" ]; then
      echo "        \"tcp://:$s_port?ip=/root/$d_ip.txt&strategy=$d_port\",
        \"udp://:$s_port?ip=/root/$d_ip.txt&strategy=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "encrypttls" ]; then
      echo "        \"tcp://:$s_port\",
        \"udp://:$s_port\"
    ],
    \"ChainNodes\": [
        \"relay+tls://$d_ip:$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "encryptws" ]; then
      echo "        \"tcp://:$s_port\",
    	\"udp://:$s_port\"
	],
	\"ChainNodes\": [
    	\"relay+ws://$d_ip:$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "encryptwss" ]; then
      echo "        \"tcp://:$s_port\",
		  \"udp://:$s_port\"
	],
	\"ChainNodes\": [
		\"relay+wss://$d_ip:$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "peertls" ]; then
      echo "        \"tcp://:$s_port\",
    	\"udp://:$s_port\"
	],
	\"ChainNodes\": [
    	\"relay+tls://:?ip=/root/$d_ip.txt&strategy=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "peerws" ]; then
      echo "        \"tcp://:$s_port\",
    	\"udp://:$s_port\"
	],
	\"ChainNodes\": [
    	\"relay+ws://:?ip=/root/$d_ip.txt&strategy=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "peerwss" ]; then
      echo "        \"tcp://:$s_port\",
    	\"udp://:$s_port\"
	],
	\"ChainNodes\": [
    	\"relay+wss://:?ip=/root/$d_ip.txt&strategy=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "cdnws" ]; then
      echo "        \"tcp://:$s_port\",
    	\"udp://:$s_port\"
	],
	\"ChainNodes\": [
    	\"relay+ws://$d_ip?host=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "cdnwss" ]; then
      echo "        \"tcp://:$s_port\",
    	\"udp://:$s_port\"
	],
	\"ChainNodes\": [
    	\"relay+wss://$d_ip?host=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "decrypttls" ]; then
      if [ -d "$HOME/gost_cert" ]; then
        echo "        \"relay+tls://:$s_port/$d_ip:$d_port?cert=/root/gost_cert/cert.pem&key=/root/gost_cert/key.pem\"" >>$gost_conf_path
      else
        echo "        \"relay+tls://:$s_port/$d_ip:$d_port\"" >>$gost_conf_path
      fi
    elif [ "$is_encrypt" == "decryptws" ]; then
      echo "        \"relay+ws://:$s_port/$d_ip:$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "decryptwss" ]; then
      if [ -d "$HOME/gost_cert" ]; then
        echo "        \"relay+wss://:$s_port/$d_ip:$d_port?cert=/root/gost_cert/cert.pem&key=/root/gost_cert/key.pem\"" >>$gost_conf_path
      else
        echo "        \"relay+wss://:$s_port/$d_ip:$d_port\"" >>$gost_conf_path
      fi
    elif [ "$is_encrypt" == "ss" ]; then
      echo "        \"ss://$d_ip:$s_port@:$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "socks" ]; then
      echo "        \"socks5://$d_ip:$s_port@:$d_port\"" >>$gost_conf_path
    else
      echo "config error"
    fi
  elif [ $i -gt 1 ]; then
    if [ "$is_encrypt" == "nonencrypt" ]; then
      echo "                \"tcp://:$s_port/$d_ip:$d_port\",
                \"udp://:$s_port/$d_ip:$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "peerno" ]; then
      echo "                \"tcp://:$s_port?ip=/root/$d_ip.txt&strategy=$d_port\",
                \"udp://:$s_port?ip=/root/$d_ip.txt&strategy=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "cdnno" ]; then
      echo "                \"tcp://:$s_port/$d_ip?host=$d_port\",
                \"udp://:$s_port/$d_ip?host=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "encrypttls" ]; then
      echo "                \"tcp://:$s_port\",
                \"udp://:$s_port\"
            ],
            \"ChainNodes\": [
                \"relay+tls://$d_ip:$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "encryptws" ]; then
      echo "                \"tcp://:$s_port\",
	            \"udp://:$s_port\"
	        ],
	        \"ChainNodes\": [
	            \"relay+ws://$d_ip:$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "encryptwss" ]; then
      echo "                \"tcp://:$s_port\",
		        \"udp://:$s_port\"
		    ],
		    \"ChainNodes\": [
		        \"relay+wss://$d_ip:$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "peertls" ]; then
      echo "                \"tcp://:$s_port\",
                \"udp://:$s_port\"
            ],
            \"ChainNodes\": [
                \"relay+tls://:?ip=/root/$d_ip.txt&strategy=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "peerws" ]; then
      echo "                \"tcp://:$s_port\",
                \"udp://:$s_port\"
            ],
            \"ChainNodes\": [
                \"relay+ws://:?ip=/root/$d_ip.txt&strategy=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "peerwss" ]; then
      echo "                \"tcp://:$s_port\",
                \"udp://:$s_port\"
            ],
            \"ChainNodes\": [
                \"relay+wss://:?ip=/root/$d_ip.txt&strategy=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "cdnws" ]; then
      echo "                \"tcp://:$s_port\",
                \"udp://:$s_port\"
            ],
            \"ChainNodes\": [
                \"relay+ws://$d_ip?host=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "cdnwss" ]; then
      echo "                 \"tcp://:$s_port\",
                \"udp://:$s_port\"
            ],
            \"ChainNodes\": [
                \"relay+wss://$d_ip?host=$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "decrypttls" ]; then
      if [ -d "$HOME/gost_cert" ]; then
        echo "        		  \"relay+tls://:$s_port/$d_ip:$d_port?cert=/root/gost_cert/cert.pem&key=/root/gost_cert/key.pem\"" >>$gost_conf_path
      else
        echo "        		  \"relay+tls://:$s_port/$d_ip:$d_port\"" >>$gost_conf_path
      fi
    elif [ "$is_encrypt" == "decryptws" ]; then
      echo "        		  \"relay+ws://:$s_port/$d_ip:$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "decryptwss" ]; then
      if [ -d "$HOME/gost_cert" ]; then
        echo "        		  \"relay+wss://:$s_port/$d_ip:$d_port?cert=/root/gost_cert/cert.pem&key=/root/gost_cert/key.pem\"" >>$gost_conf_path
      else
        echo "        		  \"relay+wss://:$s_port/$d_ip:$d_port\"" >>$gost_conf_path
      fi
    elif [ "$is_encrypt" == "ss" ]; then
      echo "        \"ss://$d_ip:$s_port@:$d_port\"" >>$gost_conf_path
    elif [ "$is_encrypt" == "socks" ]; then
      echo "        \"socks5://$d_ip:$s_port@:$d_port\"" >>$gost_conf_path
    else
      echo "config error"
    fi
  else
    echo "config error"
    exit
  fi
}

function writeconf() {
  count_line=$(awk 'END{print NR}' $raw_conf_path)
  for ((i = 1; i <= $count_line; i++)); do
    if [ $i -eq 1 ]; then
      trans_conf=$(sed -n "${i}p" $raw_conf_path)
      eachconf_retrieve
      method
    elif [ $i -gt 1 ]; then
      if [ $i -eq 2 ]; then
        echo "    ],
    \"Routes\": [" >>$gost_conf_path
        trans_conf=$(sed -n "${i}p" $raw_conf_path)
        eachconf_retrieve
        multiconfstart
        method
        multiconflast
      else
        trans_conf=$(sed -n "${i}p" $raw_conf_path)
        eachconf_retrieve
        multiconfstart
        method
        multiconflast
      fi
    fi
  done
}
function show_all_conf() {
  echo -e "                      GOST cấu hình                        "
  echo -e "--------------------------------------------------------"
  echo -e "số sê-ri | phương thức \ t | cổng cục bộ \ t | địa chỉ đích: cổng đích"
  echo -e "--------------------------------------------------------"

  count_line=$(awk 'END{print NR}' $raw_conf_path)
  for ((i = 1; i <= $count_line; i++)); do
    trans_conf=$(sed -n "${i}p" $raw_conf_path)
    eachconf_retrieve

    if [ "$is_encrypt" == "nonencrypt" ]; then
      str="Truyền không được mã hóa"
    elif [ "$is_encrypt" == "encrypttls" ]; then
      str=" đường hầm tls "
    elif [ "$is_encrypt" == "encryptws" ]; then
      str="  đường hầm ws "
    elif [ "$is_encrypt" == "encryptwss" ]; then
      str=" đường hầm "
    elif [ "$is_encrypt" == "peerno" ]; then
      str=" cân bằng tải mà không cần mã hóa "
    elif [ "$is_encrypt" == "peertls" ]; then
      str=" cân bằng tải đường hầm tls "
    elif [ "$is_encrypt" == "peerws" ]; then
      str="  cân bằng tải đường hầm ws "
    elif [ "$is_encrypt" == "peerwss" ]; then
      str=" cân bằng tải đường hầm wss "
    elif [ "$is_encrypt" == "decrypttls" ]; then
      str=" Giải mã TLS "
    elif [ "$is_encrypt" == "decryptws" ]; then
      str="  ws giải mã "
    elif [ "$is_encrypt" == "decryptwss" ]; then
      str=" giải mã wss "
    elif [ "$is_encrypt" == "ss" ]; then
      str="   ss   "
    elif [ "$is_encrypt" == "socks" ]; then
      str=" socks5 "
    elif [ "$is_encrypt" == "cdnno" ]; then
      str="Chuyển tiếp CDN mà không cần mã hóa"
    elif [ "$is_encrypt" == "cdnws" ]; then
      str="CDN chuyển tiếp đường hầm ws"
    elif [ "$is_encrypt" == "cdnwss" ]; then
      str="CDN chuyển tiếp đường hầm wss"
    else
      str=""
    fi

    echo -e " $i  |$str  |$s_port\t|$d_ip:$d_port"
    echo -e "--------------------------------------------------------"
  done
}

cron_restart() {
  echo -e "------------------------------------------------------------------"
  echo -e "wss đường hầm để bắt đầu tác vụ khởi động lại theo lịch trình để gửi CDN: "
  echo -e "-----------------------------------"
  echo -e "[1] Định cấu hình gost để khởi động lại tác vụ theo định kỳ"
  echo -e "[2] Xóa tác vụ khởi động lại theo lịch trình gost"
  echo -e "-----------------------------------"
  read -p "xin vui lòng chọn: " numcron
  if [ "$numcron" == "1" ]; then
    echo -e "------------------------------------------------------------------"
    echo -e "loại tác vụ khởi động lại theo lịch trình gost: "
    echo -e "-----------------------------------"
    echo -e "[1] Khởi động lại sau mỗi? Giờ"
    echo -e "[2] Hàng ngày? Nhấp để khởi động lại"
    echo -e "-----------------------------------"
    read -p "xin vui lòng chọn: " numcrontype
    if [ "$numcrontype" == "1" ]; then
      echo -e "-----------------------------------"
      read -p "Mỗi? giờ khởi động lại: " cronhr
      echo "0 0 */$cronhr * * ? * systemctl restart gost" >>/etc/crontab
      echo -e "Cài đặt khởi động lại theo lịch trình thành công!"
    elif [ "$numcrontype" == "2" ]; then
      echo -e "-----------------------------------"
      read -p "每日？点重启: " cronhr
      echo "0 0 $cronhr * * ? systemctl restart gost" >>/etc/crontab
      echo -e "Cài đặt khởi động lại theo lịch trình thành công!"
    else
      echo "type error, please try again"
      exit
    fi
  elif [ "$numcron" == "2" ]; then
    sed -i "/gost/d" /etc/crontab
    echo -e "Quá trình xóa tác vụ khởi động lại theo lịch trình đã hoàn tất!"
  else
    echo "type error, please try again"
    exit
  fi
}

update_sh() {
  ol_version=$(curl -L -s --connect-timeout 5 https://raw.githubusercontent.com/KANIKIG/Multi-EasyGost/master/gost.sh | grep "shell_version=" | head -1 | awk -F '=|"' '{print $3}')
  if [ -n "$ol_version" ]; then
    if [[ "$shell_version" != "$ol_version" ]]; then
      echo -e "Có phiên bản mới, có cập nhật không [Y/N]?"
      read -r update_confirm
      case $update_confirm in
      [yY][eE][sS] | [yY])
        wget -N --no-check-certificate https://raw.githubusercontent.com/KANIKIG/Multi-EasyGost/master/gost.sh
        echo -e "hoàn thành cập nhật"
        exit 0
        ;;
      *) ;;

      esac
    else
      echo -e "                 ${Green_font_prefix} Phiên bản hiện tại là phiên bản mới nhất! ${Font_color_suffix}"
    fi
  else
    echo -e "                 ${Red_font_prefix} Không tải được phiên bản mới nhất của tập lệnh, vui lòng kiểm tra kết nối với github! ${Font_color_suffix}"
  fi
}

update_sh
echo && echo -e "                 tập lệnh cấu hình cài đặt một cú nhấp chuột gost"${Red_font_prefix}[${shell_version}]${Font_color_suffix}"
  ----------- KANIKIG -----------
  Các tính năng: (1) Tập lệnh này sử dụng tệp cấu hình systemd và gost để quản lý gost
        (2) Nhiều quy tắc chuyển tiếp có thể có hiệu lực cùng lúc mà không cần sự trợ giúp của các công cụ khác (chẳng hạn như màn hình)
        (3) Việc chuyển tiếp không bị lỗi sau khi máy khởi động lại
  Chức năng: (1) chuyển tiếp không mã hóa tcp + udp, (2) chuyển tiếp mã hóa máy chuyển tiếp, (3) máy hạ cánh được giải mã và chuyển tiếp được gắn vào đế
  Tài liệu trợ giúp: https://github.com/KANIKIG/Multi-EasyGost
 ${Green_font_prefix}1.${Font_color_suffix} cài đặt gost
 ${Green_font_prefix}2.${Font_color_suffix} cập nhật gost
 ${Green_font_prefix}3.${Font_color_suffix} gỡ cài đặt gost
————————————
 ${Green_font_prefix}4.${Font_color_suffix} bắt đầu đi
 ${Green_font_prefix}5.${Font_color_suffix} ngừng lại gost
 ${Green_font_prefix}6.${Font_color_suffix} khởi động lại gost
————————————
 ${Green_font_prefix}7.${Font_color_suffix} Đã thêm cấu hình chuyển tiếp gost
 ${Green_font_prefix}8.${Font_color_suffix} Xem cấu hình gost hiện có
 ${Green_font_prefix}9.${Font_color_suffix} xóa cấu hình gost
————————————
 ${Green_font_prefix}10.${Font_color_suffix} cấu hình khởi động lại theo lịch trình gost
 ${Green_font_prefix}11.${Font_color_suffix} Cấu hình chứng chỉ TLS tùy chỉnh
————————————" && echo
read -e -p " Vui lòng nhập số [1-9]:" num
case "$num" in
1)
  Install_ct
  ;;
2)
  checknew
  ;;
3)
  Uninstall_ct
  ;;
4)
  Start_ct
  ;;
5)
  Stop_ct
  ;;
6)
  Restart_ct
  ;;
7)
  rawconf
  rm -rf /etc/gost/config.json
  confstart
  writeconf
  conflast
  systemctl restart gost
  echo -e "Cấu hình đã có hiệu lực, cấu hình hiện tại như sau"
  echo -e "--------------------------------------------------------"
  show_all_conf
  ;;
8)
  show_all_conf
  ;;
9)
  show_all_conf
  read -p "Vui lòng nhập số cấu hình bạn muốn xóa:" numdelete
  if echo $numdelete | grep -q '[0-9]'; then
    sed -i "${numdelete}d" $raw_conf_path
    rm -rf /etc/gost/config.json
    confstart
    writeconf
    conflast
    systemctl restart gost
    echo -e "Đã xóa cấu hình, khởi động lại dịch vụ"
  else
    echo "Vui lòng nhập số chính xác"
  fi
  ;;
10)
  cron_restart
  ;;
11)
  cert
  ;;
*)
  echo "xin vui lòng nhập số lượng chính xác xin vui lòng nhập số lượng chính xác [1-9]"
  ;;
esac
