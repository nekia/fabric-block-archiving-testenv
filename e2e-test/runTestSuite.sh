#!/bin/bash

echo "#### Downloaded fabric-test repo"

ROOTDIR="$(cd "$(dirname "$0")"/.. && pwd)"

set -e

mkdir -p $ROOTDIR/github.com/hyperledger

pushd $ROOTDIR/github.com/hyperledger
if [ ! -d fabric-test ]; then
  git clone https://github.com/hyperledger/fabric-test.git -b release-2.1
fi
cd fabric-test
git checkout 85bfeb408d589a543cd71e4c7e692a572a6b85f5
echo "#### Updated each sub-module under fabric-test repo"
popd

pushd $ROOTDIR/github.com/hyperledger/fabric-test/tools/PTE
rm -rf node_modules package-lock.json
npm install
echo "#### Installed required node packages"
popd

pushd $ROOTDIR/e2e-test
rm -f PTE
ln -s $ROOTDIR/github.com/hyperledger/fabric-test/tools/PTE ./PTE

cd spec
echo "#### Starting Ginkgo based test suite"
ginkgo -v -stream
popd