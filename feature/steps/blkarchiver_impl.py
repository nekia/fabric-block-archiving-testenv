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
    assert hasattr(context, "projectName"), "Any projects haven't been assigned yet"
    projectName = context.projectName

    assert hasattr(context, "composition"), "There are no containers running for this test"
    context.composition.stop([peer])

    curpath = os.path.realpath('.')
    composeFiles = ["%s/docker-compose/docker-compose-%s.yml" % (curpath, "solo-verify")]
    verify_peer = "verify.{}".format(peer)
    context.composition_verify = compose_util.Composition(context, composeFiles,
                                        projectName=projectName,
                                        components=[verify_peer],
                                        startContainers=True)

    result = context.composition_verify.docker_exec(['ledgerfsck --channelName {0} --mspID {1} --mspPath /var/hyperledger/msp'.format(channel, org)], [verify_peer])
    assert "PASS" in result[verify_peer], "The data integrity in '{0}' on the channel '{1}' is validated".format(peer, channel)
    context.composition_verify.stop([verify_peer])

    context.composition.start([peer])


@when(u'stop "{peer}"')
def step_impl(context, peer):
    assert hasattr(context, "composition"), "There are no containers running for this test"
    context.composition.stop([peer])

@when(u'start "{peer}"')
def step_impl(context, peer):
    assert hasattr(context, "composition"), "There are no containers running for this test"
    context.composition.start([peer])

@when(u'restart "{peer}"')
def step_impl(context, peer):
    assert hasattr(context, "composition"), "There are no containers running for this test"
    context.composition.stop([peer])
    context.composition.start([peer])

@when(u'delete blockfile "{rmfilepath}" on "{channel}" from "{peer}"')
def step_impl(context, rmfilepath, channel, peer):
    assert hasattr(context, "composition"), "There are no containers running for this test"
    result = context.composition.docker_exec(['sh', '-c', '"find / -type f | grep {} | grep {} | xargs -I[] mv [] /tmp"'.format(rmfilepath, channel)], [peer])

@when(u'fetch block "{blocknum}" on "{channel}" from "{peer}"')
def step_impl(context, blocknum, channel, peer):
    assert hasattr(context, "composition"), "There are no containers running for this test"
    result = context.composition.docker_exec(['peer', 'channel', 'fetch', blocknum, 'fetch{}.block'.format(blocknum), '-c', channel], [peer])

@then(u'"{peer}" is still alive')
def step_impl(context, peer):
    assert hasattr(context, "composition"), "There are no containers running for this test"
    command = ["ps", "--filter", "status=running", "--services"]
    print(command)
    result = context.composition.issueCommand(command)
    print("result : {}".format(result))
    assert peer in result,  "{} is not alive".format(peer)