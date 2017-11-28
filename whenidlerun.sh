#!/usr/bin/env bash
#
#    This file is part of WhenIdleRun.
#
#    WhenIdleRun is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    WhenIdleRun is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with WhenIdleRun.  If not, see <http://www.gnu.org/licenses/>.

# Use WhenIdleRun to execute an arbitrary snippet of script code / commands
# after an idle timeout has elapsed. If you fork a call to this command,
# any subsequent calls to the same command (with the same job id) will
# update the idle time stamp, thus resettinging the idle time period.

program_name=$0

function usage {
    echo "usage: $program_name -i|--id job_id [-t|--timeout seconds] -c|--command command" >&2
    echo "  -i, --id       Unique string ID for this job" >&2
    echo "  -t, --timeout  Idle timeout in seconds (default 10)" >&2
    echo "  -c, --command  Command to run after idle timeout" >&2
    echo "  " >&2
    echo "example: $program_name -i my-job -t 4 -c \"cd ~/some/path; git-sync\""
    exit 1
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-i|--id)
	    job_id="$2"
	    shift # past argument
	    shift # past value
	    ;;
	-t|--timeout)
	    timeout_seconds="$2"
	    shift # past argument
	    shift # past value
	    ;;
	-c|--command)
	    command="$2"
	    shift # past argument
	    shift # past value
	    ;;
	*)    # unknown option
	    POSITIONAL+=("$1") # save it in an array for later
	    shift # past argument
	    ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

timeout_seconds=${timeout_seconds:-10}

# Check input parameters
re='^[0-9]+$'
if ! [[ $timeout_seconds =~ $re ]]
then
    echo "error: Timeout provided [$timeout_seconds] is not a number" >&2
    parameter_error="yes"
fi

if [ -z ${job_id+x} ]
then
    echo "error: Job ID is a required parameter." >&2
    parameter_error="yes"
fi

if [ -z ${command+x} ]
then
    echo "error: Command is a required parameter." >&2
    parameter_error="yes"
fi

if [ "$parameter_error" == "yes" ]
then
    usage
fi


tmp_dir="$(dirname $(mktemp -u))"
ts_file="${tmp_dir}/${job_id}.ts"

if ps -ef | grep -v $$ | grep "$0" | grep -q "$job_id"
then
    # We are already running, so touch the timestamp and exit
    date +%s >"$ts_file"
    exit 0
fi

# We are the first ones - write our initial timestamp
date +%s >"$ts_file"

# main loop, where we do the timeout arithmetic
while : ; do
    last_time=$(cat "$ts_file") # we read every iteration because this file may be updated
    current_time=$(date +%s)
    let elapsed_time=current_time-last_time
    [[ $elapsed_time -ge $timeout_seconds ]] && break
    sleep 1
done

# timeout has now occurred

# cleanup
rm -f "$ts_file"

# run payload command
eval $command
