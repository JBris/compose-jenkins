ARG JENKINS_TAG

FROM jenkins/jenkins:${JENKINS_TAG}

ARG JENKINS_NUM_OF_EXECUTORS
ARG DOCKER_COMPOSE_TAG

USER root

RUN apt-get update && apt-get install -y gettext doxygen graphviz bash coreutils perl wget ca-certificates gnupg lsb-release dos2unix

RUN  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
# Install Docker
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
 
#Set Executors  
COPY ./services/templates /var/jenkins/templates
RUN envsubst < /var/jenkins/templates/executors.groovy.template > /usr/share/jenkins/ref/init.groovy.d/executors.groovy
# Set Browser permissions
RUN cp /var/jenkins/templates/browser_support.groovy usr/share/jenkins/ref/init.groovy.d/browser_support.groovy

#Add shell scripts
COPY ./services/scripts/sync-plugins.sh /usr/local/bin/sync-plugins.sh
RUN chmod +x /usr/local/bin/sync-plugins.sh && chown jenkins:jenkins /usr/local/bin/sync-plugins.sh \ 
  && dos2unix /usr/local/bin/sync-plugins.sh

COPY ./services/scripts/get-plugins.sh /usr/local/bin/get-plugins.sh
RUN chmod +x /usr/local/bin/get-plugins.sh && chown jenkins:jenkins /usr/local/bin/get-plugins.sh \ 
  && dos2unix /usr/local/bin/get-plugins.sh

#Install Jenkins plugins
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
COPY ./services/resources/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
