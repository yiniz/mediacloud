#!/bin/bash

set -u
set -e
set -o  errexit

# Some dedicated server companies set the hostnames of their
# virtual servers to numeric values (such as 288066). The test suite is
# then unable to access http://288066/

function hostname_help {
    echo "Please set the hostname to an alphanumeric value, e.g.:"
    echo "    export HOSTNAME=mediacloud"
    echo "    sudo hostname mediacloud"
    echo "    echo 127.0.0.1 \`hostname\` | sudo tee -a /etc/hosts"
    echo "and then try again."
}

system_hostname=`hostname`
shell_hostname="$HOSTNAME"      # internal bash variable
if [[ -z "$system_hostname" || "$system_hostname" == "(none)"
    || -z "$shell_hostname" || "$shell_hostname" == "(none)" ]]; then

    echo "Unable to determine hostname or hostname is empty."
    hostname_help
    exit 1
fi
if [[ "$system_hostname" =~ ^[0-9]+$ || "$shell_hostname" =~ ^[0-9]+$ ]] ; then
    echo "Your hostname ('$HOSTNAME') consists only of integers and thus some of the tests might fail."
    hostname_help
    exit 1
fi

# Run test suite
cd `dirname $0`/../

echo "Running Python unit tests..."
./script/run_in_env.sh nosetests --detailed-errors --where=mediacloud/

echo "Running Perl unit tests..."
TEST_FILES=`find lib script t -name '*.t'`
PERL5OPT=-MCarp::Always ./script/run_in_env.sh prove $* $TEST_FILES || {
    echo "One or more unit tests have failed with error code $?."
    exit 1
}
