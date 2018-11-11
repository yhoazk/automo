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
    echo "For example: $0 UDP initial_event_test_diff_client_ids_diff_ports_slave.json"
    echo "Valid subscription types include:"
    echo "            [TCP_AND_UDP, PREFER_UDP, PREFER_TCP, UDP, TCP]"
    echo "Please pass a json file to this script."
    echo "For example: $0 UDP initial_event_test_diff_client_ids_diff_ports_slave.json"
    echo "To use the same service id but different instances on the node pass SAME_SERVICE_ID as third parameter"
    exit 1
fi

PASSED_SUBSCRIPTION_TYPE=$1
PASSED_JSON_FILE=$2
# Remove processed options from $@
shift 2
REMAINING_OPTIONS=$@

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


FAIL=0

export VSOMEIP_CONFIGURATION=$PASSED_JSON_FILE

# Start the services
export VSOMEIP_APPLICATION_NAME=initial_event_test_service_four
./initial_event_test_service 4 $REMAINING_OPTIONS &
PID_SERVICE_FOUR=$!

export VSOMEIP_APPLICATION_NAME=initial_event_test_service_five
./initial_event_test_service 5 $REMAINING_OPTIONS &
PID_SERVICE_FIVE=$!

export VSOMEIP_APPLICATION_NAME=initial_event_test_service_six
./initial_event_test_service 6 $REMAINING_OPTIONS &
PID_SERVICE_SIX=$!

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

# wait until the services on the remote node were started as well
wait $PID_AVAILABILITY_CHECKER
sleep 2;
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

# wait until all clients exited on master side
./initial_event_test_stop_service SLAVE &
PID_STOP_SERVICE=$!
wait $PID_STOP_SERVICE

# shutdown the first client
kill $FIRST_PID
wait $FIRST_PID || FAIL=$(($FAIL+1))

# shutdown the services
kill $PID_SERVICE_SIX
kill $PID_SERVICE_FIVE
kill $PID_SERVICE_FOUR

sleep 1
echo ""

# Check if both exited successfully 
if [ $FAIL -eq 0 ]
then
    exit 0
else
    exit 1
fi
