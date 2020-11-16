################################################################################
#                                Jenkins Container                             #
################################################################################

FROM jenkins/jenkins:lts-centos
LABEL maintainer="TRITON <ITX-NOW@servicenow.onmicrosoft.com>"

# Run as root
USER root

# Copy Jenkins files to contaner
COPY jenkins/config/ /

# Set enviroment
ENV JENKINS_SHARE /usr/share/jenkins
ENV JENKINS_JOBS $JENKINS_SHARE/ref/jobs

# Install Yum Tools
RUN \
  yum install -y --nogpgcheck wget zip htop

# Declare Jenkins Build Args
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION}

# Configure Jenkins Plugins
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Don't run the Jenkins Wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Set Jenkins Permissions
RUN \
  chown -R 1000:0 $JENKINS_HOME $JENKINS_SHARE && \
  chmod -R 775 $JENKINS_HOME  $JENKINS_SHARE

# Expose Supercontainer Ports
EXPOSE 8080 50000

# Create Volumes
VOLUME ["$JENKINS_HOME"]

# Configure Docker entry point script
CMD ["docker-entrypoint.sh","start"]
