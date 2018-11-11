#!/bin/bash
# Copyright (C) 2015-2017 Bayerische Motoren Werke Aktiengesellschaft (BMW AG)
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Purpose: This script is needed to start the services with
# one command. This is necessary as ctest - which is used to run the
# tests - isn't able to start multiple binaries for one testcase. Therefore
# the testcase simply executes this script. This script then runs the services
# and checks that all exit successfully.

if [ $# -lt 2 ]
then
    echo "Please pass a subscription method to this script."
    echo "For example: $0 UDP initial_event_test_diff_client_ids_diff_ports_master.json"
    echo "Valid subscription types include:"
    echo "            [TCP_AND_UDP, PREFER_UDP, PREFER_TCP, UDP, TCP]"
    echo "Please pass a json file to this script."
    echo "For example: $0 UDP initial_event_test_diff_client_ids_diff_ports_master.json"
    echo "To use the same service id but different instances on the node pass SAME_SERVICE_ID as third parameter"
    exit 1
fi

PASSED_SUBSCRIPTION_TYPE=$1
PASSED_JSON_FILE=$2
# Remove processed options from $@
shift 2
REMAINING_OPTIONS="$@"

# Make sure only valid subscription types are passed to the script
SUBSCRIPTION_TYPES="TCP_AND_UDP PREFER_UDP PREFER_TCP UDP TCP"
VALID=0
for valid_subscription_type in $SUBSCRIPTION_TYPES
do
    if [ $valid_subscription_type == $PASSED_SUBSCRIPTION_TYPE ]
    then
        VALID=1
    fi
done

if [ $VALID -eq 0 ]
then
    echo "Invalid subscription type passed, valid types are:"
    echo "            [TCP_AND_UDP, PREFER_UDP, PREFER_TCP, UDP, TCP]"
    echo "Exiting"
    exit 1
fi

print_starter_message () {

if [ ! -z "$USE_LXC_TEST" ]; then
    echo "starting initial event test on slave LXC with params $PASSED_SUBSCRIPTION_TYPE $CLIENT_JSON_FILE $REMAINING_OPTIONS"
    ssh -tt -i $SANDBOX_ROOT_DIR/commonapi_main/lxc-config/.ssh/mgc_lxc/rsa_key_file.pub -o StrictHostKeyChecking=no root@$LXC_TEST_SLAVE_IP "bash -ci \"set -m; cd \\\$SANDBOX_TARGET_DIR/vsomeip/test; ./initial_event_test_slave_starter.sh $PASSED_SUBSCRIPTION_TYPE $CLIENT_JSON_FILE $REMAINING_OPTIONS\"" &
elif [ ! -z "$USE_DOCKER" ]; then
    docker run --name ietms --cap-add NET_ADMIN $DOCKER_IMAGE sh -c "route add -net 224.0.0.0/4 dev eth0 && cd $DOCKER_TESTS && ./initial_event_test_slave_starter.sh $PASSED_SUBSCRIPTION_TYPE $CLIENT_JSON_FILE $REMAINING_OPTIONS" &
else
cat <<End-of-message
*******************************************************************************
*******************************************************************************
** Please now run:
** initial_event_test_slave_starter.sh $PASSED_SUBSCRIPTION_TYPE $CLIENT_JSON_FILE $REMAINING_OPTIONS
** from an external host to successfully complete this test.
**
** You probably will need to adapt the 'unicast' settings in
** initial_event_test_diff_client_ids_diff_ports_master.json and
** initial_event_test_diff_client_ids_diff_ports_slave.json to your personal setup.
*******************************************************************************
*******************************************************************************
End-of-message
fi
}

# replace master with slave to be able display the correct json file to be used
# with the slave script
MASTER_JSON_FILE=$PASSED_JSON_FILE
CLIENT_JSON_FILE=${MASTER_JSON_FILE/master/slave}

FAIL=0

# Start the services
export VSOMEIP_CONFIGURATION=$PASSED_JSON_FILE

export VSOMEIP_APPLICATION_NAME=initial_event_test_service_one
./initial_event_test_service 1 $REMAINING_OPTIONS &
PID_SERVICE_ONE=$!

export VSOMEIP_APPLICATION_NAME=initial_event_test_service_two
./initial_event_test_service 2 $REMAINING_OPTIONS &
PID_SERVICE_TWO=$!

export VSOMEIP_APPLICATION_NAME=initial_event_test_service_three
./initial_event_test_service 3 $REMAINING_OPTIONS &
PID_SERVICE_THREE=$!

unset VSOMEIP_APPLICATION_NAME

# Array for client pids
CLIENT_PIDS=()

# Start first client which subscribes remotely
./initial_event_test_client 9000 $PASSED_SUBSCRIPTION_TYPE DONT_EXIT $REMAINING_OPTIONS &
FIRST_PID=$!

# Start availability checker in order to wait until the services on the remote
# were started as well
./initial_event_test_availability_checker 1234 $REMAINING_OPTIONS &
PID_AVAILABILITY_CHECKER=$!

sleep 1

print_starter_message


# wait until the services on the remote node were started as well
wait $PID_AVAILABILITY_CHECKER

sleep 2

for client_number in $(seq 9001 9011)
do
   ./initial_event_test_client $client_number $PASSED_SUBSCRIPTION_TYPE STRICT_CHECKING $REMAINING_OPTIONS &
   CLIENT_PIDS+=($!)
done

# Wait until all clients are finished
for job in ${CLIENT_PIDS[*]}
do
    # Fail gets incremented if a client exits with a non-zero exit code
    wait $job || FAIL=$(($FAIL+1))
done

# wait until all clients exited on slave side
./initial_event_test_stop_service MASTER &
PID_STOP_SERVICE=$!
wait $PID_STOP_SERVICE

# shutdown the first client
kill $FIRST_PID
wait $FIRST_PID || FAIL=$(($FAIL+1))

# shutdown the services
kill $PID_SERVICE_THREE
kill $PID_SERVICE_TWO
kill $PID_SERVICE_ONE

sleep 1
echo ""

if [ ! -z "$USE_DOCKER" ]; then
    docker stop ietms
    docker rm ietms
fi

# Check if both exited successfully 
if [ $FAIL -eq 0 ]
then
    exit 0
else
    exit 1
fi
