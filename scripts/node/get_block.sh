#!/bin/bash


function fetchBlock ()
{
  n=`expr $(FABRIC_LOGGING_SPEC=FATAL peer channel getinfo -c mychannel | sed -e 's/Blockchain info: //' | jq .height) - 1`
  for i in $(seq 0 $n); do
    FABRIC_LOGGING_SPEC=FATAL peer channel fetch $i block_$i_$1.blk -c mychannel -o $1 --tls --cafile $2
    FABRIC_LOGGING_SPEC=FATAL configtxgen -inspectBlock block_$i_$1.blk | jq -r .metadata.metadata[0] | md5sum | cut -f 1 -d ' ' | xargs -I{} echo -e "$1\tblock[$i]\t{}"
  done
}

ORDERER=orderer.example.com:7050
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

fetchBlock $ORDERER $CAFILE

ORDERER=orderer2.example.com:8050
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

fetchBlock $ORDERER $CAFILE

ORDERER=orderer3.example.com:9050
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

fetchBlock $ORDERER $CAFILE

ORDERER=orderer4.example.com:10050
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer4.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

fetchBlock $ORDERER $CAFILE

ORDERER=orderer5.example.com:11050
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer5.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

fetchBlock $ORDERER $CAFILE