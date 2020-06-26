include $(TOPDIR)/rules.mk

PKG_NAME:=https-dns-proxy
PKG_VERSION:=2020-04-09
PKG_RELEASE=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/aarond10/https_dns_proxy
PKG_SOURCE_DATE:=2020-04-09
PKG_SOURCE_VERSION:=40647ce94c62a47e9d53efae8018fb3142e277b9
PKG_MIRROR_HASH:=4a8052b8bd482a17b769bcd4ee2620368f8c91955c5e976088be8d2ab002dde6
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DCLANG_TIDY_EXE=

define Package/https-dns-proxy
	SECTION:=net
	CATEGORY:=Network
	TITLE:=DNS Over HTTPS Proxy
	DEPENDS:=+libcares +libcurl +libev +ca-bundle
	CONFLICTS:=https_dns_proxy
endef

define Package/https-dns-proxy/description
https_dns_proxy is a light-weight DNS<-->HTTPS, non-caching translation proxy for the RFC 8484 DNS-over-HTTPS standard. It receives regular (UDP) DNS requests and issues them via DoH.
Please see https://github.com/openwrt/packages/blob/master/net/https-dns-proxy/files/README.md for further information.
endef

define Package/https-dns-proxy/conffiles
/etc/config/https-dns-proxy
endef

define Package/https-dns-proxy/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d ${1}/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/https_dns_proxy $(1)/usr/sbin/https-dns-proxy
	$(INSTALL_BIN) ./files/https-dns-proxy.init $(1)/etc/init.d/https-dns-proxy
	$(INSTALL_CONF) ./files/https-dns-proxy.config $(1)/etc/config/https-dns-proxy
endef

define Package/https-dns-proxy/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		/etc/init.d/https-dns-proxy enable
	fi
	exit 0
endef

define Package/https-dns-proxy/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Stopping service and removing rc.d symlink for https-dns-proxy"
		/etc/init.d/https-dns-proxy stop || true
		/etc/init.d/https-dns-proxy disable || true
	fi
	exit 0
endef

$(eval $(call BuildPackage,https-dns-proxy))
