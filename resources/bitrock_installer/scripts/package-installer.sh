#!/bin/sh

cd $1
mkdir $2
mv $2-osx-installer.app $2/
hdiutil create -ov -srcfolder $2/ $2-osx-installer.dmg
rm -rf $2
cd -