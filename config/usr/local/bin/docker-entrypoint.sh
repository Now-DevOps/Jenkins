#!/bin/bash
# 
# NAME
#        jenkins.sh - This shell script takes care of starting Jenkins
#
# SYNOPSIS
#        Jenkins.sh [OPTIONS]...	
#
# DESCRIPTION
#        This script is provided as a utility to start a Jenkins Docker container
#
# OPTIONS
#        start
#               Starts Jenkins Processes
# BUGS
#        https://github.com/advlab/triton
#
# COPYRIGHT
#        Copyright © 2019 ServiceNow. License GPLv3+: GNU GPL
#        version 3 or later <http://gnu.org/licenses/gpl.html>.
#        This is free software: you are free to change and redistribute it.
#        There is NO WARRANTY, to the extent permitted by law.
#
################################################################################

# Set Lock
LOCKFILE=$JENKINS_HOME/configured.lock

# Local Variables
CLI_DELAY=0

log() {
  echo "[$(date --rfc-3339=seconds)]: $*"
}

configure() {

  if [ ! -e $LOCKFILE ]; then

    log "Configuring Jenkins Projects"

    [[ -z "$GITHUB_ID" ]] && { echo "Error: GITHUB_ID not found"; exit 1; }
    
    # Run sed to repace GitHub Username
    sed -i -e "s#GITHUBUSERNAME#$GITHUB_ID#g" $JENKINS_JOBS/*.xml

    # Run sed to repace Tomcat URL
    sed -i -e "s#CUSTOMERID#$CUSTOMER_ID#g" $JENKINS_JOBS/*.xml

     # Job 1
    JOB_NAME=CorpSite-CI
    JOB_FILE=CorpSiteCI.xml
    mkdir $JENKINS_JOBS/$JOB_NAME; cp $JENKINS_JOBS/$JOB_FILE $JENKINS_JOBS/$JOB_NAME/config.xml

    # Job 2
    JOB_NAME=CorpSite-UAT-deploy
    JOB_FILE=CorpSiteUATdeploy.xml
    mkdir $JENKINS_JOBS/$JOB_NAME; cp $JENKINS_JOBS/$JOB_FILE $JENKINS_JOBS/$JOB_NAME/config.xml

    # Job 3
    JOB_NAME=CorpSite-UAT-test
    JOB_FILE=CorpSiteUATtest.xml
    mkdir $JENKINS_JOBS/$JOB_NAME; cp $JENKINS_JOBS/$JOB_FILE $JENKINS_JOBS/$JOB_NAME/config.xml

    # Job 4
    JOB_NAME=CorpSite-PROD-deploy
    JOB_FILE=CorpSitePRODdeploy.xml
    mkdir $JENKINS_JOBS/$JOB_NAME; cp $JENKINS_JOBS/$JOB_FILE $JENKINS_JOBS/$JOB_NAME/config.xml

    # Set the lock
    touch $LOCKFILE

    log "Jenkins Projects configured"
  else
		log "Jenkins Projects already configured"
	fi
	return 0

}  

startall() {
	log "Starting Jenkins with a $CLI_DELAY sec delay"
	delay $CLI_DELAY
	cd $JENKINS_HOME
  nohup /usr/local/bin/jenkins.sh 2>&1
}

pincontainer() {
	log "Pinning container"
	exec tail -f /dev/null
}

delay() {
  secs=$1
  shift
  msg=$@
  while [ $secs -gt 0 ]
  do
    printf "\r\033[KWaiting %.d seconds $msg" $((secs--))
    sleep 1
  done
  echo
}

usage() {
    while IFS= read -r line || [ -n "$line" ]
    do
        case "$line" in
            '#!'*) # Shebang line
                ;;
            ''|'##'*|[!#]*) # End of comments
                exit "${1:-0}"
                ;;
            *) # Comment line
                printf '%s\n' "$line" >&2 # Remove comment prefix
                ;;
        esac
    done < "$0"
}

case $1 in
start)
  configure
  startall
;; 
*)
  usage
  exit 1
esac    
exit 0
