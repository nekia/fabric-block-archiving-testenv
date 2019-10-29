from behave import *
import sys
import os
import json
import time
import os
import random
import string
import struct
import marshal
import subprocess
import config_util
from endorser_util import CLIInterface, ToolInterface, SDKInterface

import orderer_util
import basic_impl
import compose_util
import common_util

@when(u'a user invokes {numInvokes:d} times on the channel "{channel}" using chaincode named "{name}" with args {args} on "{peer}" in {sleep:d} second interval')
def step_impl(context, numInvokes, channel, name, args, peer, sleep):
    invokes_impl(context, numInvokes, channel, name, args, peer, sleep=sleep)

@then(u'the number of blockfiles on {peer} is {num:d} on the channel "{channel}"')
def step_impl(context, peer, num, channel):
    assert hasattr(context, "composition"), "There are no containers running for this test"
    ledgerPath = "/var/hyperledger/production/ledgersData/chains/chains/{0}".format(channel)
    numBlockfiles = context.composition.docker_exec(['find {0} -type f -regex ".*\/blockfile_[0-9]*$" | wc -l'.format(ledgerPath)], [peer])
    retNum = int(numBlockfiles[peer].strip())
    assert retNum == num, "The number of blockfiles was '{0}' (expected value: '{1}')".format(retNum, num)

@then(u'the number of archived blockfiles on {peer} is {num:d} on the channel "{channel}"')
def step_impl(context, peer, num, channel):
    assert hasattr(context, "composition"), "There are no containers running for this test"
    archivedLedgerPath = "/tmp/var/hyperledger/production/ledgersData/chains/chains/{0}".format(channel)
    numBlockfiles = context.composition.docker_exec(['find {0} -type f -regex ".*\/blockfile_[0-9]*$" | wc -l'.format(archivedLedgerPath)], [peer])
    retNum = int(numBlockfiles[peer].strip())
    assert retNum == num, "The number of archived blockfiles was '{0}' (expected value: '{1}')".format(retNum, num)

@then(u'the data integrity in "{peer}" of "{org}" is valid on the channel "{channel}"')
def step_impl(context, peer, org, channel):
    assert hasattr(context, "composition"), "There are no containers running for this test"
    result = context.composition.docker_exec(['sh -c "export FABRIC_LOGGING_SPEC=fatal; peer blockfile verify -c {0} --mspID {1} --mspPath /var/hyperledger/msp"'.format(channel, org)], [peer])
    print(result[peer])
    jsonobj = json.loads(result[peer], cls=json.JSONDecoder)
    assert jsonobj["pass"] == True, "The data integrity in '{0}' on the channel '{1}' is validated".format(peer, channel)
