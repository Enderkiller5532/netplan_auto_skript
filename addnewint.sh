#!/bin/bash
clear

function validate_gateway() {
    local gateway="$1"
    local regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
    
    if [[ ! $gateway =~ $regex ]]; then
        echo "Invalid gateway format"
        return 1
    fi
    
    IFS='.' read -r i1 i2 i3 i4 <<< "$gateway"
    
    if (( i1 > 255 || i2 > 255 || i3 > 255 || i4 > 255 )); then
        echo "Invalid gateway range"
        return 1
    fi
    
    return 0
}

function validate_nameserver() {
    local nameserver="$1"
    local regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

    if [[ ! $nameserver =~ $regex ]]; then
        echo "Invalid nameserver format"
        return 1
    fi

    IFS='.' read -r i1 i2 i3 i4 <<< "$nameserver"

    if (( i1 > 255 || i2 > 255 || i3 > 255 || i4 > 255 )); then
        echo "Invalid dns range"
        return 1
    fi

    return 0
}


function add (){
	sudo netplan apply /etc/netplan/$int.yaml
}

function try (){
	sudo netplan try /etc/netplan/$int.yaml
}

function sucase () {
        case $sure in
        yes) sudo rm -f /etc/netplan/$dfile ;echo "Done" ;;
        no) printf "okay" ; app_case ;;
        *)sucase;;
	esac
        }


function check_all_info (){
	clear
	printf "All ints,what we watch?"
	ls -lah /etc/netplan/
	read intfileforchek
	sudo cat /etc/netplan/$intfileforchek
	sleep 60
	app_case
}

function delete_int (){
	clear
	printf "Now we delete intfiles,what file i delete now?\n"
	ls -lah /etc/netplan
	read dfile
	printf "Are you sure ? $dfile = delete yes/no "
	read sure
	sucase
}


function validate_ip() {
    local ip="$1"
    local regex="^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$"
    
    if [[ ! $ip =~ $regex ]]; then
        echo "Invalid IP format"
        return 1
    fi
    
    IFS='./' read -r i1 i2 i3 i4 subnet <<< "$ip"
    
    if (( i1 > 255 || i2 > 255 || i3 > 255 || i4 > 255 || subnet > 32 )); then
        echo "Invalid IP range"
        return 1
    fi
    
    return 0
}


function intinfo(){

printf "Let's start \n 1)I need your Render:"
read render
printf "2)I need your int here all ints Example:ens130"
 ip a
read int
while true; do
        printf "3)Now ip address that int will use (Example: 192.168.0.1/24): "
        read address
        validate_ip "$address" && break
        echo "Invalid IP. Please enter again."
    done
printf "now add domain or not"
read domain
    while true; do
        printf "Now add gateway (leave blank or type 'no' if not needed): "
        read df
        [[ "$df" == "no" || "$df" == "" ]] && break
        validate_gateway "$df" && break
        echo "Invalid gateway. Please enter again."
    done
printf "Last is nameserver default:'8.8.8.8' you need to delete it manualy for safe"
	while true; do
	read nameserver
	validate_nameserver "$nameserver" && break
	done

case $df in
	no)sudo echo "
 network:
    version: 2
    renderer: networkd
    ethernets:
        $int:
            addresses:
                - $address
            nameservers:
                search: [$domain]
                addresses: [$nameserver , 8.8.8.8]
">/etc/netplan/$int.yaml;;
	*)sudo echo "
network:
    version: 2
    renderer: networkd
    ethernets:
        $int:
            addresses:
                - $address
            nameservers:
                search: [$domain]
                addresses: [$nameserver , 8.8.8.8]
            routes:
                - to: default
                  via: $df
">/etc/netplan/$int.yaml;;

esac
chmod -u=rw,g=r,o=r /etc/netplan/$int.yaml

}


function app_case (){
clear
printf "Wellcome, this app can \n 1)Add new interface with yaml file and apply it \n 2)Create yaml file and try it \n 3)Check all int and info \n 4)Delete int file but not int \n 5)Exit \n"
        read operation
        case $operation in
           1) intinfo ; add ;;
           2) intinfo ; try ;;
           3)check_all_info;;
           4)delete_int;;
           5)echo "Have a nice day";;
           *)app_case;;
esac
}

printf "Am i sudo ? [yes/no]"
read sudosu
while true;do
case $sudosu in
	yes) printf 'allok' ; break ;;
 	no) printf 'restart me pls with sudo' ; test=`ps aux | grep addnewint.sh | head -n 1 | awk '{print $2}' ` ; kill $test ;;
  	*) echo 'Huh?';;
esac
done
app_case
