# Cross compiling Qt 4.8.6 for Hi3520D 
Feasible checking for compiling on HOST
```
$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 18.04.6 LTS
Release:	18.04
Codename:	bionic

$ uname -r
5.4.0-90-generic
```

## Setup cross compiler 
```
source /etc/profile
```

(*) For install cross compiler please refer to Hi3520D_V100R001C01SPC022_osdrv 


## Compile

> https://blog.karthisoftek.com/a?ID=01700-11afe579-5fbb-4b0a-8b6d-335bcdcb8e04
> https://blog.birost.com/a?ID=00400-6686cffe-5b8c-4536-9350-3cb1164c746a

```
wget https://download.qt.io/archive/qt/4.8/4.8.6/qt-everywhere-opensource-src-4.8.6.tar.gz
tar -xvzf qt-everywhere-opensource-src-4.8.6.tar.gz
cd qt-everywhere-opensource-src-4.8.6/

cp -rvf mkspecs/qws/linux-arm-g++/ mkspecs/qws/linux-3520d-g++
sed -i 's/arm-linux/arm-hisiv100nptl-linux/g' mkspecs/qws/linux-3520d-g++/qmake.conf
echo "#undef O_CLOEXEC" >> mkspecs/qws/linux-3520d-g++/qplatformdefs.h

mkdir /opt/Qt4.8.6-hi3520

./configure --prefix=/opt/Qt4.8.6-hi3520 -opensource -confirm-license -qt-sql-sqlite -qt-gfx-linuxfb -plugin-sql-sqlit -no-qt3support -no-phonon -no-svg -no-webkit -no-javascript-jit -no-script -no-scripttools -no-declarative -no-declarative-debug -qt-zlib -no-gif -qt-libtiff -qt-libpng -no-libmng -qt-libjpeg -no-rpath -no-pch -no-3dnow -no-avx -no-neon -no-openssl -no-nis -no-cups -no-dbus -embedded arm -platform linux-g++ -xplatform qws/linux-3520d-g++ -little-endian -qt-freetype -no-opengl -no-glib -nomake demos -nomake examples -nomake docs -nomake tools

make -j8
make install
```


