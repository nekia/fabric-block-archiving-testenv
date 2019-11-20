# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

Feature: BlockArchiver service
    As a user I expect the archiving/discarding work correctly

# @doNotDecompose
@dev
@basic
  Scenario: Quick sanity-check archiving test.

  # Select Peer0 of both org as leader and turn leader election off
  Given the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG1 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG2 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG2 environment variable is false
  # the size of blockfile is 32KB
  And the CORE_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  And the ORDERER_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  # BlockArchiver is working on only Org1
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVER_EACH environment variable is 2
  And the CORE_PEER_ARCHIVER_KEEP environment variable is 1
  And I have a bootstrapped fabric network of type solo without tls

  When an admin sets up a channel named "mychannel"
  Then there are no errors

  When an admin deploys chaincode at path "github.com/hyperledger/fabric-test/chaincodes/chaincode_example02/go" with args ["init","a","100","b","200"] with name "mycc" with language "GOLANG" to "peer0.org1.example.com" on channel "mychannel"
  And a user invokes 4 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  And I wait "10" seconds

  # We expect each peer enabled BlockArchiver has
  #  ( CORE_PEER_ARCHIVER_KEEP
  #    + 1(blockfile_000000)
  #    + ( (the total number of blockfiles - ( CORE_PEER_ARCHIVER_KEEP + 1 ) ) % CORE_PEER_ARCHIVER_EACH ) blockfiles
  # And also we expect total 4 + 1(blockfile_000000) blockfile have been created
  Then the number of blockfiles on "peer0.org1.example.com" is 3 on the channel "mychannel"
  And the number of blockfiles on "peer1.org1.example.com" is 3 on the channel "mychannel"
  And the number of blockfiles on "peer0.org2.example.com" is 5 on the channel "mychannel"
  And the number of blockfiles on "peer1.org2.example.com" is 5 on the channel "mychannel"
  And the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 2 on the channel "mychannel"
  And the data integrity in "peer0.org1.example.com" of "org1.example.com" is valid on the channel "mychannel"
  And the data integrity in "peer1.org1.example.com" of "org1.example.com" is valid on the channel "mychannel"

@basic
  Scenario: Start archiving under multiple organization env.

  # Select Peer0 of both org as leader and turn leader election off
  Given the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG1 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG2 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG2 environment variable is false
  # the size of blockfile is 32KB
  And the CORE_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  And the ORDERER_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  # BlockArchiver is working on both Orgs
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG2 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG2 environment variable is true
  And the CORE_PEER_ARCHIVER_EACH environment variable is 2
  And the CORE_PEER_ARCHIVER_KEEP environment variable is 1
  And I have a bootstrapped fabric network of type solo without tls

  When an admin sets up a channel named "mychannel"
  Then there are no errors

  When an admin deploys chaincode at path "github.com/hyperledger/fabric-test/chaincodes/chaincode_example02/go" with args ["init","a","100","b","200"] with name "mycc" with language "GOLANG" to "peer0.org1.example.com" on channel "mychannel"
  And a user invokes 4 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  And I wait "10" seconds

  Then the number of blockfiles on "peer0.org1.example.com" is 3 on the channel "mychannel"
  And the number of blockfiles on "peer1.org1.example.com" is 3 on the channel "mychannel"
  And the number of blockfiles on "peer0.org2.example.com" is 3 on the channel "mychannel"
  And the number of blockfiles on "peer1.org2.example.com" is 3 on the channel "mychannel"
  And the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 2 on the channel "mychannel"
  And the number of archived blockfiles on "blkarchiver-repo.org2.example.com" is 2 on the channel "mychannel"
  And the data integrity in "peer0.org1.example.com" of "org1.example.com" is valid on the channel "mychannel"
  And the data integrity in "peer1.org1.example.com" of "org1.example.com" is valid on the channel "mychannel"
  And the data integrity in "peer0.org2.example.com" of "org2.example.com" is valid on the channel "mychannel"
  And the data integrity in "peer1.org2.example.com" of "org2.example.com" is valid on the channel "mychannel"

@basic
  Scenario: Start archiving under a single organization env and multiple channel.

  # Select Peer0 of both org as leader and turn leader election off
  Given the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG1 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG2 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG2 environment variable is false
  # the size of blockfile is 32KB
  And the CORE_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  And the ORDERER_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  # BlockArchiver is working on only Org1
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVER_EACH environment variable is 2
  And the CORE_PEER_ARCHIVER_KEEP environment variable is 1
  And I have a bootstrapped fabric network of type solo without tls

  When an admin sets up a channel named "mychannel1"
  Then there are no errors

  When an admin sets up a channel named "mychannel2"
  Then there are no errors

  When an admin deploys chaincode at path "github.com/hyperledger/fabric-test/chaincodes/chaincode_example02/go" with args ["init","a","100","b","200"] with name "mycc1" with language "GOLANG" to "peer0.org1.example.com" on channel "mychannel1"
  And a user invokes 4 times on the channel "mychannel1" using chaincode named "mycc1" with args ["write","65536"] on "peer0.org1.example.com"

  When an admin deploys chaincode at path "github.com/hyperledger/fabric-test/chaincodes/chaincode_example02/go" with args ["init","a","100","b","200"] with name "mycc2" with language "GOLANG" to "peer0.org1.example.com" on channel "mychannel2"
  And a user invokes 5 times on the channel "mychannel2" using chaincode named "mycc2" with args ["write","131072"] on "peer0.org1.example.com"
  And I wait "10" seconds

  Then the number of blockfiles on "peer0.org1.example.com" is 3 on the channel "mychannel1"
  And the number of blockfiles on "peer0.org1.example.com" is 2 on the channel "mychannel2"
  And the number of blockfiles on "peer1.org1.example.com" is 3 on the channel "mychannel1"
  And the number of blockfiles on "peer1.org1.example.com" is 2 on the channel "mychannel2"
  And the number of blockfiles on "peer0.org2.example.com" is 5 on the channel "mychannel1"
  And the number of blockfiles on "peer0.org2.example.com" is 6 on the channel "mychannel2"
  And the number of blockfiles on "peer1.org2.example.com" is 5 on the channel "mychannel1"
  And the number of blockfiles on "peer1.org2.example.com" is 6 on the channel "mychannel2"
  And the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 2 on the channel "mychannel1"
  And the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 4 on the channel "mychannel2"
  And the data integrity in "peer0.org1.example.com" of "org1.example.com" is valid on the channel "mychannel1"
  And the data integrity in "peer0.org1.example.com" of "org1.example.com" is valid on the channel "mychannel2"
  And the data integrity in "peer1.org1.example.com" of "org1.example.com" is valid on the channel "mychannel1"
  And the data integrity in "peer1.org1.example.com" of "org1.example.com" is valid on the channel "mychannel2"

@basic
  Scenario: Start archiving under multiple organization env and multiple channel.

  # Select Peer0 of both org as leader and turn leader election off
  Given the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG1 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG2 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG2 environment variable is false
  # the size of blockfile is 32KB
  And the CORE_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  And the ORDERER_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  # BlockArchiver is working on both Orgs
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG2 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG2 environment variable is true
  And the CORE_PEER_ARCHIVER_EACH environment variable is 2
  And the CORE_PEER_ARCHIVER_KEEP environment variable is 1
  And I have a bootstrapped fabric network of type solo without tls

  When an admin sets up a channel named "mychannel1"
  Then there are no errors

  When an admin sets up a channel named "mychannel2"
  Then there are no errors

  When an admin deploys chaincode at path "github.com/hyperledger/fabric-test/chaincodes/chaincode_example02/go" with args ["init","a","100","b","200"] with name "mycc1" with language "GOLANG" to "peer0.org1.example.com" on channel "mychannel1"
  And a user invokes 4 times on the channel "mychannel1" using chaincode named "mycc1" with args ["write","65536"] on "peer0.org1.example.com"

  When an admin deploys chaincode at path "github.com/hyperledger/fabric-test/chaincodes/chaincode_example02/go" with args ["init","a","100","b","200"] with name "mycc2" with language "GOLANG" to "peer0.org1.example.com" on channel "mychannel2"
  And a user invokes 5 times on the channel "mychannel2" using chaincode named "mycc2" with args ["write","131072"] on "peer0.org1.example.com"
  And I wait "10" seconds

  Then the number of blockfiles on "peer0.org1.example.com" is 3 on the channel "mychannel1"
  And the number of blockfiles on "peer0.org1.example.com" is 2 on the channel "mychannel2"
  And the number of blockfiles on "peer1.org1.example.com" is 3 on the channel "mychannel1"
  And the number of blockfiles on "peer1.org1.example.com" is 2 on the channel "mychannel2"
  And the number of blockfiles on "peer0.org2.example.com" is 3 on the channel "mychannel1"
  And the number of blockfiles on "peer0.org2.example.com" is 2 on the channel "mychannel2"
  And the number of blockfiles on "peer1.org2.example.com" is 3 on the channel "mychannel1"
  And the number of blockfiles on "peer1.org2.example.com" is 2 on the channel "mychannel2"
  And the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 2 on the channel "mychannel1"
  And the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 4 on the channel "mychannel2"
  And the number of archived blockfiles on "blkarchiver-repo.org2.example.com" is 2 on the channel "mychannel1"
  And the number of archived blockfiles on "blkarchiver-repo.org2.example.com" is 4 on the channel "mychannel2"
  And the data integrity in "peer0.org1.example.com" of "org1.example.com" is valid on the channel "mychannel1"
  And the data integrity in "peer0.org1.example.com" of "org1.example.com" is valid on the channel "mychannel2"
  And the data integrity in "peer1.org1.example.com" of "org1.example.com" is valid on the channel "mychannel1"
  And the data integrity in "peer1.org1.example.com" of "org1.example.com" is valid on the channel "mychannel2"
  And the data integrity in "peer0.org2.example.com" of "org2.example.com" is valid on the channel "mychannel1"
  And the data integrity in "peer0.org2.example.com" of "org2.example.com" is valid on the channel "mychannel2"
  And the data integrity in "peer1.org2.example.com" of "org2.example.com" is valid on the channel "mychannel1"
  And the data integrity in "peer1.org2.example.com" of "org2.example.com" is valid on the channel "mychannel2"

@basic
  Scenario: [FBAAS-205] Start archiving each channel independently under single organization env and multiple channel.

  # Select Peer0 of both org as leader and turn leader election off
  Given the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG1 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG1 environment variable is false
  # the size of blockfile is 32KB
  And the CORE_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  And the ORDERER_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  # BlockArchiver is working on both Orgs
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVER_EACH environment variable is 1
  And the CORE_PEER_ARCHIVER_KEEP environment variable is 5
  And I have a bootstrapped fabric network of type solo without tls

  When an admin sets up a channel named "mychannel1"
  Then there are no errors

  When an admin sets up a channel named "mychannel2"
  Then there are no errors

  When an admin deploys chaincode at path "github.com/hyperledger/fabric-test/chaincodes/chaincode_example02/go" with args ["init","a","100","b","200"] with name "mycc1" with language "GOLANG" to "peer0.org1.example.com" on channel "mychannel1"
  And an admin deploys chaincode at path "github.com/hyperledger/fabric-test/chaincodes/chaincode_example02/go" with args ["init","a","100","b","200"] with name "mycc2" with language "GOLANG" to "peer0.org1.example.com" on channel "mychannel2"
  And a user invokes 4 times on the channel "mychannel1" using chaincode named "mycc1" with args ["write","65536"] on "peer0.org1.example.com"
  And a user invokes 4 times on the channel "mychannel2" using chaincode named "mycc2" with args ["write","131072"] on "peer0.org1.example.com"
  And a user invokes 6 times on the channel "mychannel1" using chaincode named "mycc1" with args ["write","65536"] on "peer0.org1.example.com"
  And I wait "10" seconds

  Then the number of blockfiles on "peer0.org1.example.com" is 6 on the channel "mychannel1"
  And the number of blockfiles on "peer0.org1.example.com" is 5 on the channel "mychannel2"
  And the number of blockfiles on "peer1.org1.example.com" is 6 on the channel "mychannel1"
  And the number of blockfiles on "peer1.org1.example.com" is 5 on the channel "mychannel2"
  And the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 5 on the channel "mychannel1"
  And the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 0 on the channel "mychannel2"

  When a user invokes 6 times on the channel "mychannel2" using chaincode named "mycc2" with args ["write","131072"] on "peer0.org1.example.com"
  And I wait "10" seconds

  Then the number of blockfiles on "peer0.org1.example.com" is 6 on the channel "mychannel1"
  And the number of blockfiles on "peer0.org1.example.com" is 6 on the channel "mychannel2"
  And the number of blockfiles on "peer1.org1.example.com" is 6 on the channel "mychannel1"
  And the number of blockfiles on "peer1.org1.example.com" is 6 on the channel "mychannel2"
  And the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 5 on the channel "mychannel1"
  And the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 5 on the channel "mychannel2"

  When a user invokes 6 times on the channel "mychannel1" using chaincode named "mycc1" with args ["write","65536"] on "peer0.org1.example.com"
  And a user invokes 7 times on the channel "mychannel2" using chaincode named "mycc2" with args ["write","131072"] on "peer0.org1.example.com"
  And I wait "10" seconds

  Then the number of blockfiles on "peer0.org1.example.com" is 6 on the channel "mychannel1"
  And the number of blockfiles on "peer0.org1.example.com" is 6 on the channel "mychannel2"
  And the number of blockfiles on "peer1.org1.example.com" is 6 on the channel "mychannel1"
  And the number of blockfiles on "peer1.org1.example.com" is 6 on the channel "mychannel2"
  And the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 11 on the channel "mychannel1"
  And the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 12 on the channel "mychannel2"
  And the data integrity in "peer0.org1.example.com" of "org1.example.com" is valid on the channel "mychannel1"
  And the data integrity in "peer0.org1.example.com" of "org1.example.com" is valid on the channel "mychannel2"
  And the data integrity in "peer1.org1.example.com" of "org1.example.com" is valid on the channel "mychannel1"
  And the data integrity in "peer1.org1.example.com" of "org1.example.com" is valid on the channel "mychannel2"

# @doNotDecompose
@basic
  Scenario: Keep working properly even after restarting archiver

  # Select Peer0 of both org as leader and turn leader election off
  Given the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG1 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG2 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG2 environment variable is false
  # the size of blockfile is 32KB
  And the CORE_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  And the ORDERER_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  # BlockArchiver is working on only Org1
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVER_EACH environment variable is 2
  And the CORE_PEER_ARCHIVER_KEEP environment variable is 1
  And I have a bootstrapped fabric network of type solo without tls

  When an admin sets up a channel named "mychannel"
  Then there are no errors

  When an admin deploys chaincode at path "github.com/hyperledger/fabric-test/chaincodes/chaincode_example02/go" with args ["init","a","100","b","200"] with name "mycc" with language "GOLANG" to "peer0.org1.example.com" on channel "mychannel"
  And a user invokes 10 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  And I wait "10" seconds

  # Restart archiver
  When restart "peer0.org1.example.com"
  # Restart client
  And restart "peer1.org1.example.com"
  And a user invokes 5 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  And I wait "10" seconds

  # We expect each peer enabled BlockArchiver has
  #  ( CORE_PEER_ARCHIVER_KEEP
  #    + 1(blockfile_000000)
  #    + ( (the total number of blockfiles - ( CORE_PEER_ARCHIVER_KEEP + 1 ) ) % CORE_PEER_ARCHIVER_EACH ) blockfiles
  # And also we expect total 4 + 1(blockfile_000000) blockfile have been created

  Then the number of blockfiles on "peer0.org1.example.com" is 2 on the channel "mychannel"
  And the number of blockfiles on "peer1.org1.example.com" is 2 on the channel "mychannel"
  And the number of blockfiles on "peer0.org2.example.com" is 16 on the channel "mychannel"
  And the number of blockfiles on "peer1.org2.example.com" is 16 on the channel "mychannel"
  And the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 14 on the channel "mychannel"
  And the data integrity in "peer0.org1.example.com" of "org1.example.com" is valid on the channel "mychannel"
  And the data integrity in "peer1.org1.example.com" of "org1.example.com" is valid on the channel "mychannel"

# @doNotDecompose
@error
  Scenario: Keep running without any crashes when a (local/archived) blockfile is deleted

  # Select Peer0 of both org as leader and turn leader election off
  Given the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG1 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG2 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG2 environment variable is false
  # the size of blockfile is 32KB
  And the CORE_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  And the ORDERER_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  # BlockArchiver is working on only Org1
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVER_EACH environment variable is 2
  And the CORE_PEER_ARCHIVER_KEEP environment variable is 1
  And I have a bootstrapped fabric network of type solo without tls

  When an admin sets up a channel named "mychannel"
  Then there are no errors

  When an admin deploys chaincode at path "github.com/hyperledger/fabric-test/chaincodes/chaincode_example02/go" with args ["init","a","100","b","200"] with name "mycc" with language "GOLANG" to "peer0.org1.example.com" on channel "mychannel"
  And a user invokes 10 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  And I wait "10" seconds

  # Delete one of the archived blockfiles on block archive repository for Org1
  When delete blockfile "blockfile_000006" on "mychannel" from "blkarchiver-repo.org1.example.com"
  # Fetch a block included in the blockfile deleted in the previous step
  When fetch block "7" on "mychannel" from "peer0.org1.example.com"
  # It should be failed
  Then the logs on "peer0.org1.example.com" contains "blockfile_000006: file does not exist" within 3 seconds

  # Delete one of the local blockfiles on peer0.org1
  When delete blockfile "blockfile_000010" on "mychannel" from "peer0.org1.example.com"
  # Fetch a block included in the blockfile deleted in the previous step
  When fetch block "11" on "mychannel" from "peer0.org1.example.com"
  # It should be failed
  Then the logs on "peer0.org1.example.com" contains "blockfile_000010: file does not exist" within 3 seconds

  # At least the peer should keep running without crash even after these failures
  When a user invokes 1 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  When fetch block "12" on "mychannel" from "peer0.org1.example.com"
  Then the logs on "peer0.org1.example.com" contains "\[mychannel\] Committed block \[12\]" within 3 seconds
  Then "peer0.org1.example.com" is still alive

# @doNotDecompose
@error
  Scenario: Keep running without any crashes when the archiving repository is not reachable

  # Select Peer0 of both org as leader and turn leader election off
  Given the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG1 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG2 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG2 environment variable is false
  # the size of blockfile is 32KB
  And the CORE_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  And the ORDERER_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  # peer0.org1 : archiver, peer1.org1 : client
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG2 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG2 environment variable is true
  And the CORE_PEER_ARCHIVER_EACH environment variable is 2
  And the CORE_PEER_ARCHIVER_KEEP environment variable is 1
  And I have a bootstrapped fabric network of type solo without tls

  When an admin sets up a channel named "mychannel"
  Then there are no errors

  When an admin deploys chaincode at path "github.com/hyperledger/fabric-test/chaincodes/chaincode_example02/go" with args ["init","a","100","b","200"] with name "mycc" with language "GOLANG" to "peer0.org1.example.com" on channel "mychannel"
  And a user invokes 10 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  And I wait "10" seconds

  # Stop the repository for Org1
  When stop "blkarchiver-repo.org1.example.com"
  # Fetch a block included in the blockfile has already been archived on the repository
  When fetch block "7" on "mychannel" from "peer0.org1.example.com"
  # It should be failed
  Then the logs on "peer0.org1.example.com" contains "error opening block file /var/hyperledger/production/ledgersData/chains/chains/mychannel/blockfile_000006" within 3 seconds

  # Generate block(file) without access to the repository
  When a user invokes 4 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  When I wait "10" seconds

  # Make sure blockfile are still growing on local without any errors
  Then the number of blockfiles on "peer0.org1.example.com" is 7 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org1.example.com" is 7 on the channel "mychannel"
  # Make sure that there is no effects on Org2
  Then the number of blockfiles on "peer0.org2.example.com" is 3 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org2.example.com" is 3 on the channel "mychannel"
  Then "peer0.org1.example.com" is still alive
  Then "peer1.org1.example.com" is still alive
  Then "peer0.org2.example.com" is still alive
  Then "peer1.org2.example.com" is still alive

  # Resume the repository for Org1
  When start "blkarchiver-repo.org1.example.com"

  # Generate block(file) without access to the repository
  When a user invokes 5 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  When I wait "10" seconds

  Then the number of blockfiles on "peer0.org1.example.com" is 2 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org1.example.com" is 2 on the channel "mychannel"
  Then the number of blockfiles on "peer0.org2.example.com" is 2 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org2.example.com" is 2 on the channel "mychannel"
  Then the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 18 on the channel "mychannel"
  Then the number of archived blockfiles on "blkarchiver-repo.org2.example.com" is 18 on the channel "mychannel"
  Then the data integrity in "peer0.org1.example.com" of "org1.example.com" is valid on the channel "mychannel"
  Then the data integrity in "peer1.org1.example.com" of "org1.example.com" is valid on the channel "mychannel"
  Then the data integrity in "peer0.org2.example.com" of "org2.example.com" is valid on the channel "mychannel"
  Then the data integrity in "peer1.org2.example.com" of "org2.example.com" is valid on the channel "mychannel"

# @doNotDecompose
@error
  Scenario: Keep running without any crashes after stop of archiver

  # Select Peer0 of both org as leader and turn leader election off
  Given the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG1 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG2 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG2 environment variable is false
  # the size of blockfile is 32KB
  And the CORE_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  And the ORDERER_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  # peer0.org1 : client, peer1.org1 : archiver
  And the CORE_PEER_ARCHIVING_ENABLED_PEER0_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVER_ENABLED_PEER1_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG2 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG2 environment variable is true
  And the CORE_PEER_ARCHIVER_EACH environment variable is 2
  And the CORE_PEER_ARCHIVER_KEEP environment variable is 1
  And I have a bootstrapped fabric network of type solo without tls

  When an admin sets up a channel named "mychannel"
  Then there are no errors

  When an admin deploys chaincode at path "github.com/hyperledger/fabric-test/chaincodes/chaincode_example02/go" with args ["init","a","100","b","200"] with name "mycc" with language "GOLANG" to "peer0.org1.example.com" on channel "mychannel"
  And a user invokes 10 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  And I wait "10" seconds

  # Make sure blockfile are still growing on local without any errors
  Then the number of blockfiles on "peer0.org1.example.com" is 3 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org1.example.com" is 3 on the channel "mychannel"
  # Make sure that there is no effects on Org2
  Then the number of blockfiles on "peer0.org2.example.com" is 3 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org2.example.com" is 3 on the channel "mychannel"

  # Stop archiver (peer1.org1)
  When stop "peer1.org1.example.com"

  # Generate block(file) without access to the repository
  When a user invokes 5 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  When I wait "10" seconds

  # Make sure blockfile are still growing on local without any errors
  Then the number of blockfiles on "peer0.org1.example.com" is 8 on the channel "mychannel"
  # Then the number of blockfiles on "peer1.org1.example.com" is 8 on the channel "mychannel"
  # Make sure that there is no effects on Org2
  Then the number of blockfiles on "peer0.org2.example.com" is 2 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org2.example.com" is 2 on the channel "mychannel"

  Then "peer0.org1.example.com" is still alive
  # Then "peer1.org1.example.com" is still alive
  Then "peer0.org2.example.com" is still alive
  Then "peer1.org2.example.com" is still alive

  # Start archiver (peer1.org1)
  When start "peer1.org1.example.com"

  # Generate block(file) without access to the repository
  When a user invokes 10 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  When I wait "10" seconds

  # Make sure blockfile are still growing on local without any errors
  Then the number of blockfiles on "peer0.org1.example.com" is 2 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org1.example.com" is 2 on the channel "mychannel"
  # Make sure that there is no effects on Org2
  Then the number of blockfiles on "peer0.org2.example.com" is 2 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org2.example.com" is 2 on the channel "mychannel"
  Then the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 24 on the channel "mychannel"
  Then the number of archived blockfiles on "blkarchiver-repo.org2.example.com" is 24 on the channel "mychannel"
  Then "peer0.org1.example.com" is still alive
  Then "peer1.org1.example.com" is still alive
  Then "peer0.org2.example.com" is still alive
  Then "peer1.org2.example.com" is still alive
  Then the data integrity in "peer0.org1.example.com" of "org1.example.com" is valid on the channel "mychannel"
  Then the data integrity in "peer1.org1.example.com" of "org1.example.com" is valid on the channel "mychannel"
  Then the data integrity in "peer0.org2.example.com" of "org2.example.com" is valid on the channel "mychannel"
  Then the data integrity in "peer1.org2.example.com" of "org2.example.com" is valid on the channel "mychannel"

# @doNotDecompose
@error
  Scenario: Keep running without any crashes after stop of client

  # Select Peer0 of both org as leader and turn leader election off
  Given the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG1 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER0_ORG2 environment variable is true
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER0_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG1 environment variable is false
  And the CORE_PEER_GOSSIP_ORGLEADER_PEER1_ORG2 environment variable is false
  And the CORE_PEER_GOSSIP_USELEADERELECTION_PEER1_ORG2 environment variable is false
  # the size of blockfile is 32KB
  And the CORE_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  And the ORDERER_LEDGER_MAXBLOCKFILESIZE environment variable is 32768
  # peer0.org1 : archiver, peer1.org1 : client
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG1 environment variable is true
  And the CORE_PEER_ARCHIVER_ENABLED_PEER0_ORG2 environment variable is true
  And the CORE_PEER_ARCHIVING_ENABLED_PEER1_ORG2 environment variable is true
  And the CORE_PEER_ARCHIVER_EACH environment variable is 2
  And the CORE_PEER_ARCHIVER_KEEP environment variable is 1
  And I have a bootstrapped fabric network of type solo without tls

  When an admin sets up a channel named "mychannel"
  Then there are no errors

  When an admin deploys chaincode at path "github.com/hyperledger/fabric-test/chaincodes/chaincode_example02/go" with args ["init","a","100","b","200"] with name "mycc" with language "GOLANG" to "peer0.org1.example.com" on channel "mychannel"
  And a user invokes 10 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  And I wait "10" seconds

  # Make sure blockfile are still growing on local without any errors
  Then the number of blockfiles on "peer0.org1.example.com" is 3 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org1.example.com" is 3 on the channel "mychannel"
  # Make sure that there is no effects on Org2
  Then the number of blockfiles on "peer0.org2.example.com" is 3 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org2.example.com" is 3 on the channel "mychannel"

  # Stop archiver (peer1.org1)
  When stop "peer1.org1.example.com"

  # Generate block(file) without access to the repository
  When a user invokes 5 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  When I wait "10" seconds

  # Make sure blockfile are still growing on local without any errors
  Then the number of blockfiles on "peer0.org1.example.com" is 2 on the channel "mychannel"
  # Then the number of blockfiles on "peer1.org1.example.com" is 8 on the channel "mychannel"
  # Make sure that there is no effects on Org2
  Then the number of blockfiles on "peer0.org2.example.com" is 2 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org2.example.com" is 2 on the channel "mychannel"

  Then "peer0.org1.example.com" is still alive
  # Then "peer1.org1.example.com" is still alive
  Then "peer0.org2.example.com" is still alive
  Then "peer1.org2.example.com" is still alive

  # Start archiver (peer1.org1)
  When start "peer1.org1.example.com"

  # Generate block(file) without access to the repository
  When a user invokes 10 times on the channel "mychannel" using chaincode named "mycc" with args ["write","65536"] on "peer0.org1.example.com"
  When I wait "10" seconds

  # Make sure blockfile are still growing on local without any errors
  Then the number of blockfiles on "peer0.org1.example.com" is 2 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org1.example.com" is 2 on the channel "mychannel"
  # Make sure that there is no effects on Org2
  Then the number of blockfiles on "peer0.org2.example.com" is 2 on the channel "mychannel"
  Then the number of blockfiles on "peer1.org2.example.com" is 2 on the channel "mychannel"
  Then the number of archived blockfiles on "blkarchiver-repo.org1.example.com" is 24 on the channel "mychannel"
  Then the number of archived blockfiles on "blkarchiver-repo.org2.example.com" is 24 on the channel "mychannel"
  Then "peer0.org1.example.com" is still alive
  Then "peer1.org1.example.com" is still alive
  Then "peer0.org2.example.com" is still alive
  Then "peer1.org2.example.com" is still alive
  Then the data integrity in "peer0.org1.example.com" of "org1.example.com" is valid on the channel "mychannel"
  Then the data integrity in "peer1.org1.example.com" of "org1.example.com" is valid on the channel "mychannel"
  Then the data integrity in "peer0.org2.example.com" of "org2.example.com" is valid on the channel "mychannel"
  Then the data integrity in "peer1.org2.example.com" of "org2.example.com" is valid on the channel "mychannel"
