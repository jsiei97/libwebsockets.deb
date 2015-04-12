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
popd || exit 4

mkdir -p $NAME/DEBIAN || exit 10
pushd $NAME || exit 12

echo "Package: "$APP        >  DEBIAN/control
echo "Version: "$VER"-"$NUM >> DEBIAN/control
echo "Section: base"        >> DEBIAN/control
echo "Priority: optional"   >> DEBIAN/control
echo "Architecture: "$ARCH  >>  DEBIAN/control

echo "Depends: "            >>  DEBIAN/control
echo "Maintainer: "$USER" <"$MAIL">" >>  DEBIAN/control

cat >> DEBIAN/control << EOF
Description: Canonical libwebsockets.org websocket library.
  deb created for the Funtech House project.
EOF

#Misc git info...
echo "  git describe: "$(git describe --tags)     >> DEBIAN/control
echo "  git log: "$(git log --oneline | head -n1) >> DEBIAN/control

popd || 14


# Second part:
# build it and populate the DEBIAN dir

pushd libwebsockets || exit 20

# If exist remove build to get a clean build?
#rm -rf libwebsockets/build/

mkdir -p build || exit 22
cd       build || exit 24

cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. || exit 26
#cmake .. || exit 6
make -j || exit 28

make install DESTDIR=$base/$NAME/ || exit 30

# And the create the package
popd
dpkg-deb --build $NAME || exit 40

# Cleanup
rm -rf $NAME/ || exit 50

#And install it...
sudo dpkg -i $NAME.deb || exit 60

echo "Done..."
exit 0
