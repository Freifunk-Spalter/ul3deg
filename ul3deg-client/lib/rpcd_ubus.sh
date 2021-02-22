#!/bin/sh

# This script is for communicating with the gateway.

. /usr/share/libubox/jshn.sh

function query_gw {
  local ip=$1
	local req=$2
	
	# first try https
	ret=$(curl http://$ip/ubus -d "$req") 2>/dev/null
	if [ $? -eq 0 ]; then
		echo $ret
		return 0
	fi

	return 1
}

function request_token {
  local ip=$1
  local user=$2
  local password=$3

  json_init
  json_add_string "jsonrpc" "2.0"
  json_add_int "id" "1"
  json_add_string "method" "call"
  json_add_array "params"
  json_add_string "" "00000000000000000000000000000000"
  json_add_string "" "session"
  json_add_string "" "login"
  json_add_object
  json_add_string "username" $user
  json_add_string "password" $password
  json_close_object
  json_close_array
  req=$(json_dump)
	ret=$(query_gw $ip "$req") 2>/dev/null
	if [ $? != 0 ]; then
		return 1
	fi
  json_load "$ret"
  json_get_vars result result
  json_select result
  json_select 2
  json_get_var ubus_rpc_session ubus_rpc_session
  echo $ubus_rpc_session
}

function get_free_prefix {
  local token=$1
  local ip=$2
  local random=$3

  json_init
  json_add_string "jsonrpc" "2.0"
  json_add_int "id" "1"
  json_add_string "method" "call"
  json_add_array "params"
  json_add_string "" $token
  json_add_string "" "ul3degs"
  json_add_string "" "get_free_prefix"
  json_add_object
  json_add_boolean "random" $random
  json_close_object
  json_close_array
  req=$(json_dump)
	ret=$(query_gw $ip "$req") 2>/dev/null
	if [ $? != 0 ]; then
		return 1
	fi
  json_load "$ret"
  json_get_vars result result
  json_select result
  json_select 2

  json_get_keys keys
  for key in $keys; do
    json_get_var val "$key"
    json_select "$key"
    json_get_var prefix prefix
    echo $prefix
    break
  done
}
