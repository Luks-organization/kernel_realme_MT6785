# SPDX-License-Identifier: GPL-2.0-only

obj-$(CONFIG_EROFS_FS) += erofs.o
erofs-objs := super.o inode.o data.o namei.o dir.o utils.o pcpubuf.o
erofs-$(CONFIG_EROFS_FS_XATTR) += xattr.o
erofs-$(CONFIG_EROFS_FS_ZIP) += decompressor.o zmap.o zdata.o
erofs-$(CONFIG_EROFS_FS_ZIP) += lz4.o
erofs-$(CONFIG_ARM64) += $(addprefix lz4armv8/, \
                          lz4accel.o           \
                          lz4armv8.o           \
                          )
