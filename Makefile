include $(TOPDIR)/rules.mk

PKG_NAME:=ul3deg
PKG_VERSION:=2020.11.24
PKG_RELEASE:=1

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>

include $(INCLUDE_DIR)/package.mk

Build/Compile=

define Package/ul3deg/Default
	SECTION:=net
	CATEGORY:=Network
	TITLE:=ul3deg
	URL:=https://github.com/Freifunk-Spalter/ul3deg
	PKGARCH:=all
endef

define Package/ul3deg
	$(call Package/ul3deg/Default)
endef

define Package/ul3degs
	$(call Package/ul3deg/Default)
	TITLE+= (server)
	DEPENDS:=+rpcd +uhttpd +uhttpd-mod-ubus
endef

define Package/ul3degs/install
	$(INSTALL_DIR) $(1)/usr/share/ul3deg/
	$(INSTALL_BIN) ./ul3deg-server/lib/install_ul3deg_user.sh $(1)/usr/share/ul3deg/install_ul3deg_user.sh
	$(INSTALL_BIN) ./ul3deg-server/lib/babel_server.sh $(1)/usr/share/ul3deg/babel_server.sh

	$(INSTALL_DIR) $(1)/usr/libexec/rpcd/
	$(INSTALL_BIN) ./ul3deg-server/ul3degs.sh $(1)/usr/libexec/rpcd/ul3degs

	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(CP) ./ul3deg-server/config/ul3degs.json $(1)/usr/share/rpcd/acl.d/
endef

define Package/ul3degs/postinst
	#!/bin/sh
	if [ -z $${IPKG_INSTROOT} ] ; then
		. /usr/share/ul3deg/install_ul3deg_user.sh
	fi
endef

define Package/ul3degc
	$(call Package/ul3deg/Default)
	TITLE+= (client)
	DEPENDS:=+coreutils-fold +owipcalc +curl
endef

define Package/ul3degc/install
	$(INSTALL_DIR) $(1)/usr/share/ul3deg/
	$(INSTALL_BIN) ./ul3deg-client/lib/configure_gateway.sh $(1)/usr/share/ul3deg/configure_gateway.sh
	$(INSTALL_BIN) ./ul3deg-client/lib/rpcd_ubus.sh $(1)/usr/share/ul3deg/rpcd_ubus.sh
	$(INSTALL_BIN) ./ul3deg-client/lib/babel.sh $(1)/usr/share/ul3deg/babel.sh
endef

$(eval $(call BuildPackage,ul3deg))
$(eval $(call BuildPackage,ul3degs))
$(eval $(call BuildPackage,ul3degc))
