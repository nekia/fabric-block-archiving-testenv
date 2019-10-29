#!/bin/bash
#
# dotest.sh
#
# Initialises and starts the network and issues some transactions
# in order to test the archiver functionality
#

# Stop and remove all containers and artifacts
docker rm -f $(docker ps -aq)

# Remove fabric artifacts
pushd ~/dev/fst-poc-fabric-env
sudo rm -rf crypto-config channel-artifacts/* ledgers/ ledgers-archived/

# Start network
export CORE_LEDGER_MAXBLOCKFILESIZE=65536              # it means the size of each blockfile is 64K
export CORE_PEER_ARCHIVER_INTERVAL=5                  # Archiver polling interval in secs
export CORE_PEER_ARCHIVER_EACH=10
export CORE_PEER_ARCHIVER_KEEP=5

./byfn.sh up -c mychannel -i latest

# Create a channel and make all peers join the channel
docker exec -it cli scripts/script.sh

# Create enough transactions so that some block files will be archived
echo "Waiting for network to come up..."
sleep 20
for i in $(seq 1 26); do docker exec -it cli scripts/script_write.sh; sleep 5; done

popd

# Check that the expected number of blockfiles have been archived
echo "Waiting for all block files to be archived..."
sleep 15
./checktest.sh
