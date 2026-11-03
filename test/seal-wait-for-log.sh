#!/bin/sh
# Seal fork-CI helper (Travis after_script): keep the job open until Travis has
# archived this job's own log up to the test results, so the log harvested the
# moment the build finishes is complete. Travis archives log parts
# asynchronously, often minutes behind the job. after_script cannot change the
# job result. Usage: sh test/seal-wait-for-log.sh grunt|qunit
# The patterns live here, not on the command line, so the echoed after_script
# command can never satisfy them itself.
case "$1" in
	grunt) pattern='Done, without errors\.' ;;
	qunit) pattern='Tests: [0-9]+ passed, [0-9]+ failed' ;;
	*) echo "usage: $0 grunt|qunit"; exit 0 ;;
esac

url="https://api.travis-ci.com/v3/job/${TRAVIS_JOB_ID}/log.txt"
echo "waiting for job ${TRAVIS_JOB_ID} log archive (mode $1)"
i=0
while [ "$i" -lt 120 ]; do
	if curl -sfL "$url" 2>/dev/null | grep -Eq "$pattern"; then
		echo "log archive holds the results after $((i * 20))s"
		exit 0
	fi
	i=$((i + 1))
	sleep 20
done
echo "log archive still incomplete after 40 minutes"
exit 0
