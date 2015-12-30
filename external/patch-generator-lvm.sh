#!/bin/bash
pkgname="LVM2.2.02.104"
rm -r $pkgname
tar xf $pkgname.tgz
diff -rupN $pkgname $pkgname.new > $pkgname-android.patch

