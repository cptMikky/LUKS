#!/bin/bash
pkgname="util-linux-2.26.2"
rm -r $pkgname
tar xf $pkgname.tar.xz
diff -rupN $pkgname $pkgname.new > $pkgname-android.patch

