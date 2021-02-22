. /usr/share/ul3deg/babel.sh
. /usr/share/libubox/jshn.sh

function new_prefix {
    local inteface=$1

    # reqeust gw ids
    gw_ids=$(get_gw_ids)

    # search for the ips
    gw_ip=$(get_gw_ips $gw_ids)
    echo $gw_ip

    # get a free prefix
    prefix_call=$(ul3degc get_free_prefix --ip [$gw_ip] --user ul3deg --password ul3deg --random 1)
    prefix=$(echo $prefix_call | awk '{print $1}')
    valid=$(echo $prefix_call | awk '{print $2}')
    preferred=$(echo $prefix_call | awk '{print $3}')

    assignip=$(owipcalc $prefix add 1)
    ip -6 a add $assignip dev br-lan valid_lft $valid preferred_lft $preferred

    uci commit
    /etc/init.d/network reload
}

new_prefix lan