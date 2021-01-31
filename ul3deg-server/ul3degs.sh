#!/bin/sh

. /usr/share/libubox/jshn.sh

. /usr/share/ul3deg/delete_prefix.sh
. /usr/share/ul3deg/install_prefix.sh
. /usr/share/ul3deg/manage_prefixes.sh
. /usr/share/ul3deg/babel_server.sh

case "$1" in
	list)
		cmd='{ "get_free_prefix": {"random":"true"} })'
		echo $cmd
	;;
	call)
		case "$2" in
			get_free_prefix)
				read input;
				logger -t "ul3degs" "call" "$2" "$input"
				get_free_prefix_json $input
			;;
		esac
	;;
esac
