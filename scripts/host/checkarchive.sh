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
  echo "==== The number of archived blockfiles on BlockArchiver ===="
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
        docker stop ${CONTAINER_NAME} > /dev/null 2>&1
        docker-compose -f $DIR/../../docker-compose-cli-verify.yaml up -d verify.${CONTAINER_NAME} > /dev/null 2>&1
        MSPID=`echo $org | sed -e 's/^./\U&\E/'`MSP
        echo -n "    $peer: "
        docker exec -it verify.${CONTAINER_NAME} peer verify start --channelID $ch
        docker rm -f verify.${CONTAINER_NAME} > /dev/null 2>&1
        docker start ${CONTAINER_NAME} > /dev/null 2>&1
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
