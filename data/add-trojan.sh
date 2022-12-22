#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
purple='\e[0;35m'
blue='\e[0;34m'
yellow='\e[1;33m'
cyan='\e[1;96m'
NC='\e[0m'
# Getting Online Date
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
dateayena=`date +"%Y-%m-%d" -d "$dateFromServer"`
# MYIP IP & GET EXPIRED
MYIP=$(curl -4 -sS ipv4.icanhazip.com)
IZIN=$(curl -4 -sS https://raw.githubusercontent.com/gustipwa009/server-sragen/main/list.txt | awk '{print $1}' | grep -w $MYIP)
EXP=$(curl -4 -sS https://raw.githubusercontent.com/gustipwa009/server-sragen/main/list.txt | grep -w $MYIP | awk '{print $2}')
USERVPS=$(curl -4 -sS https://raw.githubusercontent.com/gustipwa009/server-sragen/main/list.txt | grep -w $MYIP | awk '{print $3}')
# Cek Database
echo "Checking..."
if [[ $MYIP = $IZIN ]]; then
	echo -e "${green}IP Diterima...${NC}"
else
	echo -e "${red}IP Belum Terdaftar!${NC}";
	echo "Hubungi @stance999 Untuk Daftar Premium"
	exit 0
fi
# Cek Tanggal
d1=(`date -d "$EXP" +%s`)
d2=(`date -d "$dateayena" +%s`)
exp2=$(( (d1 - d2) / 86400 ))
if [[ "$exp2" -le "0" ]]; then
	echo "${red}Masa Aktif Habis ! Silahkan Perpanjang${NC}";
	exit 0
else
	echo -e "${green}Masa Aktif Berjalan${NC}";
fi
clear
# Telegram Stuff
BOT_TOKEN="5908043509:AAFJZR_zG47YLEl1SIyqHyBdTQYz92H_Zrc"
CHAT_ID="-5357978438"
IPADRESS=$( curl -4 -s ipv4.appspot.com)
REGION=$( curl -s https://ipapi.co/${IPADRESS}/country_name/)
ISP=$( curl -s https://ipapi.co/${IPADRESS}/org/)
telegram_curl() {
	local ACTION=${1}
	shift
	local HTTP_REQUEST=${1}
	shift
	if [ "$HTTP_REQUEST" != "POST_FILE" ]; then
			curl -s -X $HTTP_REQUEST "https://api.telegram.org/bot$BOT_TOKEN/$ACTION" "$@" | jq .
	else
			curl -s "https://api.telegram.org/bot$BOT_TOKEN/$ACTION" "$@" | jq .
	fi
}
telegram_main() {
	local ACTION=${1}
	local HTTP_REQUEST=${2}
	local CURL_ARGUMENTS=()
	while [ "${#}" -gt 0 ]; do
		case "${1}" in
			--animation | --audio | --document | --photo | --video )
					local CURL_ARGUMENTS+=(-F $(echo "${1}" | sed 's/--//')=@"${2}")
					shift
					;;
			--* )
					if [ "$HTTP_REQUEST" != "POST_FILE" ]; then
							local CURL_ARGUMENTS+=(-d $(echo "${1}" | sed 's/--//')="${2}")
					else
							local CURL_ARGUMENTS+=(-F $(echo "${1}" | sed 's/--//')="${2}")
					fi
					shift
					;;
		esac
		shift
	done
	telegram_curl "$ACTION" "$HTTP_REQUEST" "${CURL_ARGUMENTS[@]}"
}
tg_send_message() {
	telegram_main sendMessage POST "$@"
}
## End of Telegram Stuff
# ENV
domain=$(cat /etc/adi/domain)
porttls="443"
portnontls="80"
fix=%26
# Read User Info
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
	read -rp "User: " -e user
	CLIENT_EXISTS=$(grep -w $user /usr/local/etc/xray/netz/trojantcp.json | wc -l)
	if [[ ${CLIENT_EXISTS} == '2' ]]; then
			echo ""
			echo "User ini telah ada, Tolong gunakan nama lain."
			exit 1
	fi
done
uuid=$(xray uuid)
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
# Buat Akun
# TCP TLS
sed -i '/#membertrojantcp$/a\### '"$user $exp"'\
},{"email": ''"'"$user"'"'',"password": ''"'"$user"'"''' /usr/local/etc/xray/netz/trojantcp.json
# TCP NON TLS
sed -i '/#membertrojantcpnon$/a\### '"$user $exp"'\
},{"email": ''"'"$user"'"'',"password": ''"'"$user"'"''' /usr/local/etc/xray/netz/trojantcpnon.json
# WS TLS
sed -i '/#membertrojanws$/a\### '"$user $exp"'\
},{"email": ''"'"$user"'"'',"password": ''"'"$user"'"''' /usr/local/etc/xray/netz/trojanws.json
# WS NON TLS
sed -i '/#membertrojanwsnon$/a\### '"$user $exp"'\
},{"email": ''"'"$user"'"'',"password": ''"'"$user"'"''' /usr/local/etc/xray/netz/trojanwsnon.json
# WS NON TLS ORBIT
sed -i '/#membertrojankuotahabis$/a\### '"$user $exp"'\
},{"email": ''"'"$user"'"'',"password": ''"'"$user"'"''' /usr/local/etc/xray/netz/trojankuota.json
# GRPC
sed -i '/#membertrojangrpc$/a\### '"$user $exp"'\
},{"email": ''"'"$user"'"'',"password": ''"'"$user"'"''' /usr/local/etc/xray/netz/trojangrpc.json
# Converted
trojantcp="trojan://${user}@${domain}:$porttls?security=tls&headerType=none&type=tcp#${user}"
trojanws="trojan://${user}@${domain}:$porttls?path=/netztrojan&security=tls&type=ws#${user}"
trojanwsnon="trojan://${user}@${domain}:$portnontls?path=/netztrojan&security=none&encryption=none&type=ws&host=${domain}#${user}"
trojankuota="trojan://${user}@${domain}:$portnontls?path=/kuota-habis/netztrojan&security=none&encryption=none&type=ws&host=${domain}#${user}"
trojangrpc="trojan://${user}@${domain}:$porttls?mode=gun&security=tls&type=grpc&serviceName=netztrojangrpc#${user}"
# Converted Telegram
trojantcptelegram="trojan://${user}@${domain}:$porttls?security=tls${fix}headerType=none${fix}type=tcp#${user}"
trojanwstelegram="trojan://${user}@${domain}:$porttls?path=/netztrojan${fix}security=tls${fix}type=ws#${user}"
trojanwsnontelegram="trojan://${user}@${domain}:$portnontls?path=/netztrojan${fix}security=none${fix}encryption=none${fix}type=ws${fix}host=${domain}#${user}"
trojankuotatelegram="trojan://${user}@${domain}:$portnontls?path=/kuota-habis/netztrojan${fix}security=none${fix}encryption=none${fix}type=ws${fix}host=${domain}#${user}"
trojangrpctelegram="trojan://${user}@${domain}:$porttls?mode=gun${fix}security=tls${fix}type=grpc${fix}serviceName=netztrojangrpc#${user}"
# Cleanup
clear
# Post Telegram
if [[ -z $BOT_TOKEN ]]; then
	echo "Terimakasih Telah Menggunakan Layanan NetzXRay Bot"
elif [[ -z $CHAT_ID ]]; then
	echo -e " "
else
tg_send_message --chat_id "$CHAT_ID" --text "*TROJAN BERHASIL DIBUAT !*
*ISP*   : $ISP
*IP*    : $IPADRESS
*Domain*        : $domain
*Client*        : $user
*Password*      : $user
*Aktif Sampai* : $exp
TROJAN
TROJAN TCP TLS  : \`$trojantcptelegram\`
TROJAN WS TLS   : \`$trojanwstelegram\`
TROJAN NON TLS  : \`$trojanwsnontelegram\`
TROJAN ORBIT    : \`$trojankuotatelegram\`
TROJAN GRPC TLS : \`$trojangrpctelegram\`
AutoScript By Adi Subagja" --parse_mode "Markdown" >/dev/null
echo "Terimakasih Telah Menggunakan Layanan NetzXRay"
fi
# Informasi Akun
echo -e
XRAY/TROJAN
echo -e Remarks     : "$user"
echo -e Password    : "$user"
echo -e Domain      : "$domain"
echo -e Port        : "$porttls & $portnontls"
echo -e Masa Aktif  : "$exp"
echo -e Path        : "/netztrojan"
echo -e Path Orbit      : "/kuota-habis/netztrojan"
echo -e ServiceName : "netztrojangrpc"
echo -e
echo -e TCP TLS     : "$trojantcp"
echo -e ""
echo -e
echo -e WS TLS      : "$trojanws"
echo -e ""
echo -e
echo -e WS NON      : "$trojanwsnon"
echo -e ""
echo -e
echo -e ORBIT       : "$trojankuota"
echo -e ""
echo -e
echo -e GRPC        : "$trojangrpc"
echo -e ""
echo -e
echo -e NO TORRENT
echo -e NO SEEDING
echo -e NO MULTILOGIN
echo -e
# Trigger Reload Services
echo -e "Halaman akan ditutup dalam 5-10 detik"
sleep 10
systemctl restart xray
clear
echo -e "Sucessfully Created"
welcome
