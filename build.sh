#!/bin/bash

base=$PWD

#Make sure we dont have any old debs here...
rm *.deb 

# First part: 
# collect data and create a control file.

pushd libwebsockets || exit 2

APP="libwebsockets"
#Or some git info...
VER=$(date +'%Y%m%d%H%M')
NUM="1"
ARCH=$(dpkg --print-architecture)

USER=$(git config user.name)
MAIL=$(git config user.email)

NAME=$APP"_"$VER"-"$NUM"_"$ARCH

mkdir -p $base/$NAME/DEBIAN || exit 10
control=$base/$NAME/DEBIAN/control

echo "Package: "$APP        >  $control
echo "Version: "$VER"-"$NUM >> $control
echo "Section: base"        >> $control
echo "Priority: optional"   >> $control
echo "Architecture: "$ARCH  >>  $control

echo "Depends: "            >>  $control
echo "Maintainer: "$USER" <"$MAIL">" >>  $control

cat >> $control << EOF
Description: Canonical libwebsockets.org websocket library.
  deb created for the Funtech House project.
EOF

#Misc git info...
echo "  git describe: "$(git describe --tags)     >> $control
echo "  git log: "$(git log --oneline | head -n1) >> $control

# Second part:
# build it and populate the DEBIAN dir

# If exist remove build to get a clean build?
#rm -rf libwebsockets/build/

mkdir -p build || exit 22
cd       build || exit 24

cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. || exit 26
make -j || exit 28

make install DESTDIR=$base/$NAME/ || exit 30

# And the create the package
popd
dpkg-deb --build $NAME || exit 40

#And install it...
sudo dpkg -i $NAME.deb || exit 60

# Cleanup
rm -rf $NAME/ || exit 50

echo "Done..."
exit 0
