#!/bin/bash

echo "#### Downloaded fabric-test repo"

ROOTDIR="$(cd "$(dirname "$0")"/.. && pwd)"

set -e

mkdir -p $ROOTDIR/github.com/hyperledger

pushd $ROOTDIR/github.com/hyperledger
if [ ! -d fabric-test ]; then
  git clone https://github.com/hyperledger/fabric-test.git -b master
fi
cd fabric-test
git checkout a22a51517b4b6ffa28a4bd840b7256b0fedc04f6
echo "#### Updated each sub-module under fabric-test repo"
popd

pushd $ROOTDIR/github.com/hyperledger/fabric-test/tools/PTE
rm -rf node_modules package-lock.json
npm install fabric-client@2.0.0-snapshot.326
npm install fabric-ca-client@2.0.0-snapshot.326
echo "#### Installed required node packages"
popd

pushd $ROOTDIR/e2e-test
rm -f PTE
ln -s $ROOTDIR/github.com/hyperledger/fabric-test/tools/PTE ./PTE

cd spec
echo "#### Starting Ginkgo based test suite"
ginkgo -v -stream
popd