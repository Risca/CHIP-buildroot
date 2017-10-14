################################################################################
#
# squeezelite
#
################################################################################

SQUEEZELITE_VERSION = master
SQUEEZELITE_SITE = $(call github,ralph-irving,squeezelite,$(SQUEEZELITE_VERSION))
SQUEEZELITE_LICENSE = GPL-3.0+
SQUEEZELITE_LICENSE_FILES = LICENSE.txt
SQUEEZELITE_DEPENDENCIES = alsa-lib faad2 ffmpeg flac libmad libogg libvorbis mpg123 libsoxr

SQUEEZELITE_OPTS = -DRESAMPLE -DFFMPEG -DVISEXPORT -DDSD
define SQUEEZELITE_BUILD_CMDS
    $(MAKE) -C $(@D) CC="$(TARGET_CC)" \
            CFLAGS="$(TARGET_CFLAGS) $(SQUEEZELITE_OPTS)" \
            LDFLAGS="$(TARGET_LDFLAGS) -lasound -lpthread -lFLAC -lmad -lfaad -lsoxr -lavcodec -lmpg123 -lvorbisfile -lvorbis -logg -lavformat -lavcodec -lswresample -lavutil -lm -ldl -lrt -pthread" \
            all
    $(TARGET_STRIP) $(TARGET_STRIP_ALL) $(@D)/squeezelite
endef

define SQUEEZELITE_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/squeezelite $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
