#!/usr/bin/env bash
#
# Support Kit — menu xử lý sự cố nhanh cho máy chủ Linux.
# Các thao tác tương ứng tài liệu Support-Linux.md.

# ---------------------------------------------------------------------------
# Tiện ích chung
# ---------------------------------------------------------------------------
pause() {
    read -rp $'\nNhấn Enter để quay lại menu...' _
}

# ---------------------------------------------------------------------------
# 1) Cấu hình DNS qua NetworkManager
# ---------------------------------------------------------------------------
configure_dns_nm() {
    local DNS DEV CON

    read -rp "Nhập DNS (VD 8.8.8.8,1.1.1.1): " DNS
    [ -z "$DNS" ] && { echo "Bạn chưa nhập DNS"; return 1; }

    DEV=$(ip -4 route show default | awk '{print $5; exit}')
    [ -z "$DEV" ] && { echo "Không tìm thấy interface đang online"; return 1; }

    CON=$(nmcli -t -f DEVICE,CONNECTION dev status | grep "^${DEV}:" | cut -d: -f2-)
    [ -z "$CON" ] && { echo "Interface $DEV không do NetworkManager quản lý"; return 1; }

    echo "Đang cấu hình DNS cho: $CON ($DEV) -> $DNS"
    sudo nmcli con mod "$CON" ipv4.dns "$DNS" || return 1
    sudo nmcli con mod "$CON" ipv4.ignore-auto-dns yes || return 1
    sudo nmcli dev reapply "$DEV" || return 1
    echo "✔ Đã cấu hình DNS xong."
}

# ---------------------------------------------------------------------------
# TODO: Bổ sung các chức năng khác tại đây
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Menu chính
# ---------------------------------------------------------------------------
show_menu() {
    cat <<'EOF'

============================================
        SUPPORT KIT — Linux Server
============================================
  1) Cấu hình DNS (NetworkManager)
  exit) Thoát
============================================
EOF
}

main() {
    while true; do
        show_menu
        read -rp "Nhập lựa chọn: " CHOICE
        echo
        case "$CHOICE" in
            1) configure_dns_nm; pause ;;
            # TODO: thêm case cho các chức năng mới ở đây
            exit | q | 0) echo "Thoát."; break ;;
            *) echo "Lựa chọn không hợp lệ. Vui lòng thử lại." ;;
        esac
    done
}

main "$@"
