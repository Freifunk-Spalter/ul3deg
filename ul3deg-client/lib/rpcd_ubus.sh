#!/bin/sh

# This script is for communicating with the gateway.

. /usr/share/libubox/jshn.sh

# Copied from:
# https://stackoverflow.com/questions/31457586/how-can-i-check-ip-version-4-or-6-in-shell-script
function isipv6 {
  local ip=$1
  # I do not like this bash behavior
  if [ "$ip" != "${1#*[0-9].[0-9]}" ]; then
    return 1
  elif [ "$ip" != "${1#*:[0-9a-fA-F]}" ]; then
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
  # ToDo: specify interface with curl --interface
  ret=$(curl http://$ip/ubus -d "$req") 2> /dev/null
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
  local secret=$3
  local random=$4

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
  # ToDo: specify interface with curl --interface
  ret=$(curl http://$ip/ubus -d "$req") 2> /dev/null
  json_load "$ret"
  json_get_vars result result
  json_select result
  json_select 2
  json_get_var prefix prefix
  echo $prefix
}
