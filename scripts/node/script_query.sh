#!/bin/bash

# CHANNEL_NAME="$1"
# DELAY="$2"
# LANGUAGE="$3"
# TIMEOUT="$4"
# VERBOSE="$5"
EXPECTVAL=$1
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="3"}
: ${VERBOSE:="false"}
: ${EXPECTVAL:=95}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5

CC_SRC_PATH="github.com/chaincode/chaincode_example02/go/"
if [ "$LANGUAGE" = "node" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/node/"
fi

echo "Channel name : "$CHANNEL_NAME

# import utils
. scripts/utils.sh

echo "Querying chaincode on peer1.org2..."
chaincodeQuery 0 1 $EXPECTVAL

exit 0
