#!/bin/sh

cd $1
mkdir $2
mv $2-osx-installer.app $2/
case $OSTYPE in
  darwin*)
    hdiutil create -ov -srcfolder $2/ $2-osx-installer.dmg
    ;;
  linux*)
    echo "running genisoimage"
    echo "genisoimage -D -V $2 -no-pad -r -apple -o $2-osx-installer.dmg $2"
    genisoimage -D -V $2 -no-pad -r -apple -o $2-osx-installer.dmg $2
    ;;
esac
if [ -e $2-osx-installer.dmg ]
then
  rm -rf $2
fi
cd -
