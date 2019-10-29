#!/bin/bash

FABRIC_ROOT=$GOPATH/src/github.com/hyperledger/fabric
DIR=$(dirname "$0")
LOCAL_LEDGER_DIR=$DIR/../../ledgers
ARCHIVED_LEDGER_DIR=$DIR/../../ledgers-archived
ORGS="org1 org2"
CHANNELS="mychannel yourchannel"
PEERS="peer0 peer1"

# Print the usage message
function printHelp() {
  echo "Usage: "
  echo "  $0 <mode>"
  echo "    <mode> - one of 'status' or 'verify'"
  echo "      - 'status' - show the stats of archived/local blockfiles"
  echo "      - 'verify' - verify the consitency of blockchain on each peer"
}

showStatus() {
  echo "==== The number of archived blockfiles on blockVault ===="
  for ch in ${CHANNELS}; do
    echo "$ch"
    for org in ${ORGS}; do
      echo -n "  $org: "
      sh -c 'find '${ARCHIVED_LEDGER_DIR}'/'$org' -type f 2>/dev/null | grep blockfile | grep -E "\b'$ch'\b" | wc -l'
    done
  done

  echo "==== The number of blockfiles on local file system ===="
  for ch in ${CHANNELS}; do
    echo "$ch"
    for org in ${ORGS}; do
      echo "  $org"
      for peer in ${PEERS}; do
        echo -n "    $peer: "
        sh -c 'find '${LOCAL_LEDGER_DIR}' -type f | grep blockfile | grep -E "\b'$ch'\b" | grep -E "\b'$org'\b" | grep -E "\b'$peer'\b" | wc -l'
      done
    done
  done
}

verifyChain() {
  for ch in ${CHANNELS}; do
    echo "$ch"
    for org in ${ORGS}; do
      echo "  $org"
      for peer in ${PEERS}; do
        CONTAINER_NAME=$peer.$org.example.com
        MSPID=`echo $org | sed -e 's/^./\U&\E/'`MSP
        echo -n "    $peer: "
        docker exec -e FABRIC_LOGGING_SPEC=CRITICAL -it ${CONTAINER_NAME}  peer blockfile verify -c ${ch} --mspID ${MSPID} --mspPath /etc/hyperledger/fabric/msp
      done
    done
  done
}

MODE=$1

#Create the network using docker compose
if [ "${MODE}" == "status" ]; then
  showStatus
elif [ "${MODE}" == "verify" ]; then ## Clear the network
  verifyChain
else
  printHelp
  exit 1
fi
