#!/bin/bash

PEER=$1
ORG=$2
CHANNEL=$3

CONTAINERID=$PEER-$ORG
ORDERERURL=orderer0-ordererorg1:30000
CAFILE=/etc/hyperledger/fabric/artifacts/msp/crypto-config/ordererOrganizations/ordererorg1/users/Admin@ordererorg1/msp/tlscacerts/tlsca.ordererorg1-cert.pem

docker exec $CONTAINERID peer channel fetch 0 config_block.pb -o $ORDERERURL -c $CHANNEL --tls --cafile $CAFILE
docker exec $CONTAINERID peer channel join -b config_block.pb -o $ORDERERURL --tls --cafile $CAFILE