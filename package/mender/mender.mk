################################################################################
#
# mender
#
################################################################################

MENDER_VERSION = 1.3.0b1
MENDER_SITE = $(call github,mendersoftware,mender,$(MENDER_VERSION))
MENDER_LICENSE = Apache-2.0
MENDER_LICENSE_FILES = LICENSE

MENDER_DEPENDENCIES = host-go

MENDER_GOPATH = "$(@D)/vendor"
MENDER_MAKE_ENV = $(HOST_GO_TARGET_ENV) \
	GOPATH="$(MENDER_GOPATH)" \
	PATH=$(BR_PATH)

ifeq ($(BR2_PACKAGE_MENDER)$(call qstrip,$(BR2_PACKAGE_MENDER_CONFIG)),y)
$(error No mender configuration file specified, check your BR2_PACKAGE_MENDER_CONFIG setting)
endif

define MENDER_CONFIGURE_CMDS
	mkdir -p $(@D)/bin
	mkdir -p $(MENDER_GOPATH)/src/github.com/mendersoftware
	ln -s $(@D) $(MENDER_GOPATH)/src/github.com/mendersoftware/mender
endef

define MENDER_BUILD_CMDS
	cd $(MENDER_GOPATH)/src/github.com/mendersoftware/mender && $(MENDER_MAKE_ENV) $(MAKE) V=1 install
endef

define MENDER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(MENDER_GOPATH)/bin/linux_$(GO_GOARCH)/mender $(TARGET_DIR)/usr/bin/
	$(INSTALL) -d $(TARGET_DIR)/usr/share/mender/identity
	$(INSTALL) -t $(TARGET_DIR)/usr/share/mender/identity -m 0755 $(@D)/support/mender-device-identity
	$(INSTALL) -d $(TARGET_DIR)/usr/share/mender/inventory
	$(INSTALL) -t $(TARGET_DIR)/usr/share/mender/inventory -m 0755 $(@D)/support/mender-inventory-*
	$(INSTALL) -d $(TARGET_DIR)/etc/mender
	$(INSTALL) -m 0644 $(BR2_PACKAGE_MENDER_CONFIG) $(TARGET_DIR)/etc/mender/mender.conf
endef

ifneq ($(call qstrip,$(BR2_PACKAGE_MENDER_SERVER_CERT)),)
define MENDER_INSTALL_SERVER_CERT
	$(INSTALL) -m 0444 $(MENDER_SERVER_CERT) $(TARGET_DIR)/etc/mender/server.crt
endef
MENDER_POST_INSTALL_TARGET_HOOKS += MENDER_INSTALL_SERVER_CERT
endif

ifneq ($(call qstrip,$(BR2_PACKAGE_MENDER_ARTIFACT_VERIFY_KEY)),)
define MENDER_INSTALL_ARTIFACT_VERIFY_KEY
	$(INSTALL) -m 0444 $(MENDER_ARTIFACT_VERIFY_KEY) $(TARGET_DIR)/etc/mender/artifact-verify-key.pem
endef
MENDER_POST_INSTALL_TARGET_HOOKS += MENDER_INSTALL_ARTIFACT_VERIFY_KEY
endif

ifeq ($(BR2_PACKAGE_MENDER_PERSISTENT_DATA),y)
define MENDER_CREATE_VAR_LIB_MENDER
	$(RM) -rf $(TARGET_DIR)/var/lib/mender
	ln -s /data/mender $(TARGET_DIR)/var/lib/mender
endef
else
define MENDER_CREATE_VAR_LIB_MENDER
	$(RM) -rf $(TARGET_DIR)/var/lib/mender
	$(INSTALL) -d $(TARGET_DIR)/var/lib/mender
endef
endif
MENDER_POST_INSTALL_TARGET_HOOKS += MENDER_CREATE_VAR_LIB_MENDER

define MENDER_INSTALL_INIT_SYSV
	$(INSTALL) -m 755 -D package/mender/S60mender \
		$(TARGET_DIR)/etc/init.d/
endef

$(eval $(generic-package))
