# Generating a Pipeline from Templates


## Overview
Running the [build-pipeline.py](.ci/pipeline-builder/build-pipeline.py) \<config-file\> [\<output filename\>] script generates 
a pipeline with blocks of code for the core pipeline and all the microservices using the parameters supplied in the yaml 
configuration file.

The overall pipeline template can be found here: [template-file.yml.j2](.ci/pipeline-builder/templates/template-file.yml.j2)  

## Contents
### Configuration files
TODO - rewrite below now changed to YAML

[infrastructure.csv](./infrastructure.csv)

This file lists the parameters that are infrastructure or project wide.

infraservicename,reponame,deploykeyname,projectname,slackchannel

Where:

| infraservicename | reponame | deploykeyname | projectname | slackchannel |
|--- |--- |--- |--- |--- |
|The name of the infrastructure service e.g. aqb-aws. This is the name used in the pipeline | The name of the infrastructure repo e.g TeliaSoneraNorge/aqb-aws|The name of the deploykey as stored in AWS SSM Parameter Store | The name of the project / name of the AWS account prefixes e.g telia-divx-aqb| The slack channel to report build errors to|



[microservices.csv](./microservices.csv)

This file lists the parameters that are specific to each of the microservice (one microservice per line).

|servicename |reponame |deploykeyname |dockerimagerepo|projecttype|
|--- |--- |--- |---|---|
|The name of the microservice as will be used in the pipeline|The name of the microservice repo e.g TeliaSoneraNorge/aqb-thing-service | The name of the deploykey for the repo as stored in AWS SSM Parameter Store | The uri of the repository where the docker image of the microservice is pushed to|The type of project - java-maven, jave-gradle, phython|

## Prerequisites
 - A slack channel to post build messages to
 - A slack hook created for that channel and the secret slackhook key stored in SSM
 - Team set up on concourse
 - SNYK Token - saved in SSM  (create your own on limited use token on snyk.com)
 - Sonarqube Token - (ask cloud-ops)

## Notes

This repo is being updated to include more different types of projecttype - java-maven and python are ready maven-gradle and Go are in the pipeline

The pipeline produced