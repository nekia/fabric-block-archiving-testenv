#!/bin/bash

#
# checktest.sh
# Helper script for use by dotest.sh
# It checks that the number of blockfiles archived for org1 and org2 match those expected
#

./checkarchive.sh status
echo
echo

# Verify the BlockArchiver - peer0
PEER_CMD='peer blockfile verify -c mychannel --mspID Org1MSP --mspPath /etc/hyperledger/fabric/msp'
json=`docker exec -e CORE_LOGGING_LEVEL=CRITICAL -e FABRIC_LOGGING_SPEC=fatal -it peer0.org1.example.com $PEER_CMD`
if [ $? -ne 0 ]; then
	echo "**** TEST FAILED - Error running: " $PEER_CMD
	echo "->" $json
	exit
fi

# Ensure the verification passed
ok=`echo $json | jq -r '.pass'`
if [ $ok != 'true' ]; then
	echo "**** TEST FAILED - peer0 blockfile verify returned: " $json
	exit
fi

# Verify the BlockArchiver - peer1
json=`docker exec -e CORE_LOGGING_LEVEL=CRITICAL -e FABRIC_LOGGING_SPEC=fatal -it peer1.org1.example.com $PEER_CMD`
if [ $? -ne 0 ]; then
	echo "**** TEST FAILED - Error running: " $PEER_CMD
	echo "->" $json
	exit
fi

# Ensure the verification passed
ok=`echo $json | jq -r '.pass'`
if [ $ok != 'true' ]; then
	echo "**** TEST FAILED - peer1 blockfile verify returned: " $json
	exit
fi





pushd ~/dev/fst-poc-fabric-env >/dev/null


# Count the BlockArchiver files for ORG1
expected=20
n=`find ./ledgers-archived/org1 -type f | grep blockfile | grep mychannel | wc -l`
if [ "$n" -ne "$expected" ]; then
	echo "**** TEST FAILED - Expected $expected archived blockfiles for org1 - got: $n"
	exit
fi

# Count the BlockArchiver files for ORG2
expected=20
n=`find ./ledgers-archived/org2 -type f | grep blockfile | grep mychannel | wc -l`
if [ "$n" -ne "$expected" ]; then
	echo "**** TEST FAILED - Expected $expected archived blockfiles for org2 - got: $n"
	exit
fi

# Count the local blockfiles for ORG1 - peer0
expected=7
n=`find ./ledgers -type f | grep blockfile | grep mychannel | grep org1 | grep peer0 | wc -l`
if [ "$n" -ne "$expected" ]; then
	echo "**** TEST FAILED - Expected $expected local blockfiles for org1.peer0 - got: $n"
	exit
fi

# Count the local blockfiles for ORG1 - peer1
expected=7
n=`find ./ledgers -type f | grep blockfile | grep mychannel | grep org1 | grep peer1 | wc -l`
if [ "$n" -ne "$expected" ]; then
	echo "**** TEST FAILED - Expected $expected local blockfiles for org1.peer1 - got: $n"
	exit
fi

# Count the local blockfiles for ORG2 - peer0
expected=7
n=`find ./ledgers -type f | grep blockfile | grep mychannel | grep org2 | grep peer0 | wc -l`
if [ "$n" -ne "$expected" ]; then
	echo "**** TEST FAILED - Expected $expected local blockfiles for org2.peer0 - got: $n"
	exit
fi

# Count the local blockfiles for ORG2 - peer1
expected=27
n=`find ./ledgers -type f | grep blockfile | grep mychannel | grep org2 | grep peer1 | wc -l`
if [ "$n" -ne "$expected" ]; then
	echo "**** TEST FAILED - Expected $expected local blockfiles for org2.peer1 - got: $n"
	exit
fi

popd >/dev/null

echo "*** TESTS PASSED ***"
