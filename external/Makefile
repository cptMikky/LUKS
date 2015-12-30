# To build, install the Android NDK on GNU/Linux or Mac OS X:
#    http://developer.android.com/sdk/ndk/index.html

### these modify the calling shell
# point pkg-config to the .pc files generated from these builds
export PKG_CONFIG_PATH=$(LOCAL)/lib/pkgconfig
# workaround for cross-compiling bug in autoconf
export ac_cv_func_malloc_0_nonnull=yes

CWD = $(shell pwd)
PROJECT_ROOT = $(CWD)
EXTERNAL_ROOT = $(PROJECT_ROOT)/external

# Android NDK setup
NDK_BASE ?=  /opt/android-ndk
NDK_PLATFORM_LEVEL ?= 21
NDK_SYSROOT=$(NDK_BASE)/platforms/android-$(NDK_PLATFORM_LEVEL)/arch-arm
NDK_UNAME := $(shell uname -s | tr '[A-Z]' '[a-z]')
NDK_TOOLCHAIN=$(NDK_BASE)/toolchains/arm-linux-androideabi-4.8/prebuilt/$(NDK_UNAME)-x86_64

# to use the real HOST tag, you need the latest libtool files:
# http://stackoverflow.com/questions/4594736/configure-does-not-recognize-androideabi
HOST := arm-linux-androideabi

# install root for built files
DESTDIR = $(CWD)
# TODO try adding the Android-style /data/app.name here
prefix = 
LOCAL := $(DESTDIR)$(prefix)

PATH := ${PATH}:$(NDK_TOOLCHAIN)/bin:$(LOCAL)/bin

CC := $(NDK_TOOLCHAIN)/bin/arm-linux-androideabi-gcc --sysroot=$(NDK_SYSROOT)
CXX := $(NDK_TOOLCHAIN)/bin/arm-linux-androideabi-g++
CPP := $(NDK_TOOLCHAIN)/bin/arm-linux-androideabi-cpp
LD := $(NDK_TOOLCHAIN)/bin/arm-linux-androideabi-ld
RANLIB := $(NDK_TOOLCHAIN)/bin/arm-linux-androideabi-ranlib
STRIP := $(NDK_TOOLCHAIN)/bin/arm-linux-androideabi-strip \
	--strip-unneeded -R .note -R .comment

CFLAGS = -I$(LOCAL)/include
LDFLAGS = -L$(LOCAL)/lib -Wl,--rpath,$(LOCAL)/lib
#ALL_LDFLAGS = -Wl,--entry=main,-rpath=$(ANDROID_NDK_ROOT)/build/platforms/android-$(NDK_PLATFORM_VER)/arch-arm/usr/lib,-dynamic-linker=/system/bin/linker -L$(NDK_SYSROOT)/usr/lib  -nostdlib -lc -ldl
#LIBS = -lc -ldl

_lge-version = "1.21"
_lgcV = "1.6.4"
_poptV = "1.16"
_csV = "1_7_0"
_csVhash = "e2637c5d497db72c37ba20d4986da36b6bc8bc7f"
_lvmV = "2.2.02.103"
_utilVmajor = "2.26"
_utilV = "$(_utilVmajor).2"

#------------------------------------------------------------------------------#
# download sources and verify


SOURCEDIRS = libgpg-error-$(_lge-version) libgcrypt-$(_lgcV) popt-$(_poptV) cryptsetup-$(_csV) LVM2.2.02.79 util-linux-$(_utilV)

all: cryptsetup-install


#------------------------------------------------------------------------------#
# libgpg-error


libgpg-error.tar.bz2.sig: libgpg-error.tar.bz2
	wget https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-$(_lge-version).tar.bz2.sig
#TODO verify

libgpg-error.tar.bz2: 
	wget -c https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-$(_lge-version).tar.bz2
	#sha1sum -c libgpg-error-$(_lge-version).tar.bz2.sha1

libgpg-error: libgpg-error.tar.bz2
	tar xjf libgpg-error-$(_lge-version).tar.bz2
	cp config.guess config.sub libgpg-error-$(_lge-version)/

libgpg-error/config.sub: libgpg-error config.sub
	cp config.sub libgpg-error-$(_lge-version)/config.sub

libgpg-error/config.guess: libgpg-error config.guess
	cp config.guess libgpg-error-$(_lge-version)/config.guess

libgpg-error-build: libgpg-error/config.sub libgpg-error/config.guess
	cd libgpg-error-$(_lge-version) && \
		./configure CC="$(CC)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" \
			--disable-languages --enable-static --host=$(HOST)
	$(MAKE) -C libgpg-error-$(_lge-version)

$(LOCAL)/lib/libgpg-error.a: libgpg-error-build
	$(MAKE) -C libgpg-error-$(_lge-version) DESTDIR=$(DESTDIR) prefix= install

libgpg-error-install: $(LOCAL)/lib/libgpg-error.a


#------------------------------------------------------------------------------#
# 

libgcrypt.tar.bz2.sig: libgcrypt.tar.bz2
	wget https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-$(_lgcV).tar.bz2.sig
#TODO verify

libgcrypt.tar.bz2:
	wget -c https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-$(_lgcV).tar.bz2
	#sha1sum -c libgcrypt-$(_lgcV).tar.bz2.sha1

libgcrypt: libgcrypt.tar.bz2.sig
	tar xjf libgcrypt-$(_lgcV).tar.bz2
	#patch -p0 < libgcrypt-$(_lgcV)-android.diff

libgcrypt/config.sub: libgcrypt config.sub
	cp config.sub libgcrypt-$(_lgcV)/config.sub

libgcrypt/config.guess: libgcrypt config.guess
	cp config.guess libgcrypt-$(_lgcV)/config.guess

libgcrypt-build: libgpg-error-install libgcrypt libgcrypt/config.sub libgcrypt/config.guess
	cd libgcrypt-$(_lgcV) && \
		CC="$(CC)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" \
			./configure --enable-maintainer-mode --enable-static --host=$(HOST) --with-gpg-error-prefix=$(LOCAL) --prefix=$(prefix)
	$(MAKE) -C libgcrypt-$(_lgcV)

$(LOCAL)/lib/libgcrypt.a: libgcrypt-build
	$(MAKE) -C libgcrypt-$(_lgcV) DESTDIR=$(DESTDIR) prefix= install
	ls -l $(LOCAL)/lib/libgcrypt.a

libgcrypt-install: $(LOCAL)/lib/libgcrypt.a

#------------------------------------------------------------------------------#
# 

# TODObuild libuuid from e2fsprogs

#------------------------------------------------------------------------------#
# LVM2

LVM.tgz.asc: LVM.tgz
	wget ftp://sources.redhat.com/pub/lvm2/LVM$(_lvmV).tgz.asc
# TODO verify

LVM.tgz:
	wget -c ftp://sources.redhat.com/pub/lvm2/LVM$(_lvmV).tgz
	#sha1sum -c LVM$(_lvmV).tgz.sha1

LVM: LVM.tgz.asc
	tar xzf LVM$(_lvmV).tgz
	patch -p0 < LVM$(_lvmV)-android.patch

LVM/autoconf/config.sub: LVM config.sub
	cp config.sub LVM$(_lvmV)/autoconf/config.sub

LVM/autoconf/config.guess: LVM config.guess
	cp config.guess LVM$(_lvmV)/autoconf/config.guess

#Now we have to get LVM2
lvm2-build: LVM/autoconf/config.sub LVM/autoconf/config.guess
	cd LVM$(_lvmV) && \
		autoreconf && \
		CC="$(CC)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" ./configure --host=$(HOST) --prefix=$(prefix) --enable-static_link --enable-lvm1_fallback --enable-fsadm --with-clvmd=cman --with-cluster=internal --with-pool=internal --with-user= --with-group= --with-dmdir=device-mapper.0 --with-device-uid=0 --with-device-gid=6 --with-device-mode=0660 --with-clvmd=none --with-pool=none --with-cluster=none --with-snapshots=none --with-mirrors=none --enable-pkgconfig
	$(MAKE) CC="$(CC)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" -C LVM$(_lvmV) device-mapper

$(LOCAL)/lib/libdevmapper.a: lvm2-build
	$(MAKE) -C LVM$(_lvmV) DESTDIR=$(DESTDIR) prefix= install

lvm2-install: $(LOCAL)/lib/libdevmapper.a


#------------------------------------------------------------------------------#
# popt

popt.tar.gz.asc: popt.tar.gz
#	wget http://rpm5.org/files/popt/popt-$(_poptV).tar.gz.asc
# TODO verify

popt.tar.gz:
	wget -c http://rpm5.org/files/popt/popt-$(_poptV).tar.gz
	#sha1sum -c popt-$(_poptV).tar.gz.sha1

popt: popt.tar.gz.asc
	tar xzf popt-$(_poptV).tar.gz
#	patch -p0 < popt-$(_poptV)-android.diff

popt/config.sub: popt config.sub
	cp config.sub popt-$(_poptV)/config.sub

popt/config.guess: popt config.guess
	cp config.guess popt-$(_poptV)/config.guess

popt-build: popt popt/config.sub popt/config.guess
	cd popt-$(_poptV) && \
		./autogen.sh && \
		CC="$(CC)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" \
			./configure --prefix=$(prefix) --host=$(HOST) --enable-static
	$(MAKE) -C popt-$(_poptV)

$(LOCAL)/lib/libpopt.a: popt-build
	$(MAKE) -C popt-$(_poptV) DESTDIR=$(DESTDIR) prefix= install

popt-install: $(LOCAL)/lib/libpopt.a


#------------------------------------------------------------------------------#
# util-linux

util-linux.tar.xz.sign: util-linux.tar.xz
	wget http://www.kernel.org/pub/linux/utils/util-linux/v$(_utilVmajor)/util-linux-$(_utilV).tar.sign

util-linux.tar.xz:
	wget -c http://www.kernel.org/pub/linux/utils/util-linux/v$(_utilVmajor)/util-linux-$(_utilV).tar.xz
	#sha1sum -c util-linux-$(_utilV).tar.xz.sha1

util-linux: util-linux.tar.xz.sign
	tar xf util-linux-$(_utilV).tar.xz
	patch -p0 < util-linux-$(_utilV)-android.patch

util-linux/autoconf/config.sub: util-linux config.sub
	cp config.sub util-linux-$(_utilV)/config/config.sub

util-linux/autoconf/config.guess: util-linux config.guess
	cp config.guess util-linux-$(_utilV)/config/config.guess

util-linux-build: util-linux/autoconf/config.guess util-linux/autoconf/config.sub
	cd util-linux-$(_utilV) && \
		./autogen.sh && \
		CC="$(CC)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" \
			./configure --host=$(HOST) --prefix=$(prefix) --disable-all-programs --enable-libuuid --enable-static --without-ncurses 
			#./configure --host=$(HOST) --prefix=$(prefix) --enable-static --without-ncurses --disable-unshare --disable-rename --disable-wall --disable-mount --disable-fsck --disable-libblkid --disable-libmount  --disable-use-agetty --disable-fdisk --disable-mkswap
	$(MAKE) -C util-linux-$(_utilV)

$(LOCAL)/lib/libuuid.a: util-linux-build
	$(MAKE) -C util-linux-$(_utilV) DESTDIR=$(DESTDIR) prefix= install

util-linux-install: $(LOCAL)/lib/libuuid.a


#------------------------------------------------------------------------------#
# cryptsetup

cryptsetup.tar.gz.asc: cryptsetup.tar.gz
	#wget http://cryptsetup.googlecode.com/files/cryptsetup-$(_csV).tar.bz2.asc
# TODO verify

cryptsetup.tar.gz: 
	wget -c https://gitlab.com/cryptsetup/cryptsetup/repository/archive.tar.gz?ref=v$(_csV) -O cryptsetup-v$(_csV).tar.gz
	#sha1sum -c cryptsetup-$(_csV).tar.bz2.sha1

cryptsetup: cryptsetup.tar.gz.asc
	touch cryptsetup-v$(_csV)
	rm -rd cryptsetup-v$(_csV)
	tar xf cryptsetup-v$(_csV).tar.gz
	mv cryptsetup-v$(_csV)-$(_csVhash) cryptsetup-v$(_csV)
	#patch -p0 < cryptsetup-$(_csV)-android.diff

cryptsetup/config.sub: cryptsetup config.sub
	#cp config.sub cryptsetup-v$(_csV)/config.sub

cryptsetup/config.guess: cryptsetup config.guess
	#cp config.guess cryptsetup-v$(_csV)/config.guess

cryptsetup-build: $(LOCAL)/lib/libgpg-error.a $(LOCAL)/lib/libgcrypt.a $(LOCAL)/lib/libdevmapper.a $(LOCAL)/lib/libpopt.a $(LOCAL)/lib/libuuid.a cryptsetup cryptsetup/config.sub cryptsetup/config.guess
	touch lib/xxx.la
	rm lib/*.la
	cd cryptsetup-v$(_csV) && \
		./autogen.sh && \
		CC="$(CC)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" \
			./configure --host=$(HOST) --prefix=$(prefix) --enable-static --enable-libgcrypt --enable-libdevmapper --disable-selinux --enable-static-cryptsetup
	$(MAKE) -C cryptsetup-v$(_csV)

$(LOCAL)/sbin/cryptsetup: cryptsetup-build
	$(MAKE) -C cryptsetup-v$(_csV) DESTDIR=$(DESTDIR) prefix= install

cryptsetup-install: $(LOCAL)/sbin/cryptsetup

#------------------------------------------------------------------------------#
# clean

tarballs_clean:
	rm -f -- rm *.sig *.bz2 *.gz *.tgz *.xz *.asc

install_clean:
	rm -rf -- bin include lib sbin share

sourcedirs_clean:
	rm -rf -- $(SOURCEDIRS)

clean: sourcedirs_clean install_clean

distclean: clean tarballs_clean

.PHONY = libgpg-error-build libgcrypt-build lvm2-build popt-build	\
	cryptosetup-build util-linux-ng-build libgpg-error-install		\
	libgcrypt-install lvm2-install popt-install cryptosetup-install	\
	util-linux-ng-install clean tarballs_clean sourcedirs_clean


