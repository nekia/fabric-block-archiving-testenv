#!/bin/bash

echo "#### Downloaded fabric-test repo"

set -e

mkdir -p $GOPATH/src/github.com/hyperledger

pushd $GOPATH/src/github.com/hyperledger
if [ ! -d fabric-test ]; then
  git clone https://github.com/hyperledger/fabric-test.git -b release-2.0
fi
cd fabric-test
git checkout 78b2c83c4e194ab475789b39378d4f5ddbead511
echo "#### Updated each sub-module under fabric-test repo"
popd

pushd $GOPATH/src/github.com/hyperledger/fabric-test/tools/PTE
rm -rf node_modules package-lock.json
npm install fabric-client@1.4.8
npm install fabric-ca-client@1.4.8
echo "#### Installed required node packages"
popd

rm -f PTE
ln -s $GOPATH/src/github.com/hyperledger/fabric-test/tools/PTE ./PTE

pushd specs
echo "#### Starting Ginkgo based test suite"
ginkgo -v -stream
popd