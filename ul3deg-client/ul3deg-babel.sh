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
    json_load "$prefix_call"
    json_get_keys keys
    for key in $keys; do
        json_select "$key"
        json_get_var prefix prefix
        break
    done
    echo $prefix

    # first get the old prefix
    old_prefix=$(uci get dhcp.$interface.prefix_filter)

    # now set the new prefix and remove the old one
    uci add_list network.$inteface.ip6prefix=''${prefix}''

    # we need to have at least 3 prefixes... do not delete this after next call...
    uci del_list network.$inteface.ip6prefix=''${old_prefix}''
    uci commit

    # now set the new prefix as prefix_filter
    uci set dhcp.$inteface.prefix_filter=''${prefix}''
    uci commit

    ul3degc install --ip [$gw_ip] --user ul3deg --password ul3deg --prefix $prefix

    /etc/init.d/odhcpd reload # enable prefixfilter
    /etc/init.d/network reload # we have to check clients
}

function configure_odhcpd {
    local interface=$1
    local pref=$2
    local valid=$3

    # convert pref and valid into absolute date
    pref_abs=$(date '+%d %b %Y %T' --date="@$(($(date +%s)+$pref))")
    valid_abs=$(date '+%d %b %Y %T' --date="@$(($(date +%s)+$valid))")

    uci set dhcp.$intefaces.ra_useleasetime=1
    uci set dhcp.$intefaces.preferred_lifetime=$pref_abs
    uci set dhcp.$intefaces.leasetime=$valid_abs

    # Apply settings
    uci commit
    /etc/init.d/odhcpd reload
}

new_prefix lan