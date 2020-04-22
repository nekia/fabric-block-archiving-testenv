#!/bin/bash

echo "#### Downloaded fabric-test repo"

set -e

mkdir -p $GOPATH/src/github.com/hyperledger

pushd $GOPATH/src/github.com/hyperledger
if [ ! -d fabric-test ]; then
  git clone https://github.com/hyperledger/fabric-test.git -b release-2.1
fi
cd fabric-test
git checkout 85bfeb408d589a543cd71e4c7e692a572a6b85f5
echo "#### Updated each sub-module under fabric-test repo"
popd

pushd $GOPATH/src/github.com/hyperledger/fabric-test/tools/PTE
rm -rf node_modules package-lock.json
npm install
echo "#### Installed required node packages"
popd

rm -f PTE
ln -s $GOPATH/src/github.com/hyperledger/fabric-test/tools/PTE ./PTE

pushd specs2
echo "#### Starting Ginkgo based test suite"
ginkgo -v -stream
popd