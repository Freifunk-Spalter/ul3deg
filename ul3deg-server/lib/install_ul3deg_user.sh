#!/bin/sh

# do not override already existing user!!!
[ "$(uci show rpcd | grep ul3deg)" ] && exit 0

# install ul3deg user with standard credentials
# user: ul3deg
# password: ul3deg
uci add rpcd login 
uci set rpcd.@login[-1].username='ul3deg'

password=$(uhttpd -m ul3deg)
uci set rpcd.@login[-1].password=$password
uci add_list rpcd.@login[-1].read='ul3deg'
uci add_list rpcd.@login[-1].write='ul3deg'
uci commit rpcd

# restart rpcd
/etc/init.d/rpcd restart

# restart uhttpd
/etc/init.d/uhttpd restart
