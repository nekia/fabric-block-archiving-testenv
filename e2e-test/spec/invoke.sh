#!/bin/bash

sleep 3

docker exec peer0-org1 peer chaincode invoke \
-o orderer0-ordererorg1:30000 \
--tls \
--cafile /etc/hyperledger/fabric/artifacts/msp/crypto-config/ordererOrganizations/ordererorg1/users/Admin@ordererorg1/msp/tlscacerts/tlsca.ordererorg1-cert.pem \
-C commonchannel \
-n samplecc \
--peerAddresses peer0-org1:31000 \
--tlsRootCertFiles /etc/hyperledger/fabric/artifacts/msp/crypto-config/peerOrganizations/org1/peers/peer0-org1.org1/tls/ca.crt \
--peerAddresses peer0-org2:31002 \
--tlsRootCertFiles /etc/hyperledger/fabric/artifacts/msp/crypto-config/peerOrganizations/org2/peers/peer0-org2.org2/tls/ca.crt \
-c '{"Args":["write","16384"]}'
