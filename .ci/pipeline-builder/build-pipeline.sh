#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo 'Must be called with output filename e.g  ./build-pipeline.sh test.yml'
    exit 1
fi

IFS=,
read infraservicename reponame deploykeyname projectname slackchannel < infrastructure.csv
    cat templates/groups-master-jobs-head.yml |\
      sed 's#<service-name>#'${infraservicename}'#g' > groups-master-jobs.tmp
    cat templates/groups-pr-jobs-head.yml |\
      sed 's#<service-name>#'${infraservicename}'#g' > groups-pr-jobs.tmp
    cat templates/jobs-jobs-head.yml |\
      sed 's#<service-name>#'${infraservicename}'#g' > jobs-jobs.tmp
    cat templates/jobs-deploy-dev-triggers-head.yml |\
      sed 's#<service-name>#'${infraservicename}'#g' > jobs-deploy-dev-triggers.tmp
    cat templates/jobs-integration-triggers-head.yml |\
      sed 's#<service-name>#'${infraservicename}'#g' > jobs-integration-triggers.tmp
    cat templates/jobs-deploy-stage-triggers-head.yml |\
      sed 's#<service-name>#'${infraservicename}'#g' > jobs-deploy-stage-triggers.tmp
    cat templates/jobs-deploy-prod-triggers-head.yml |\
      sed 's#<service-name>#'${infraservicename}'#g' > jobs-deploy-prod-triggers.tmp
    cat templates/resources-head.yml |\
      sed 's#<service-name>#'${infraservicename}'#g' |\
      sed 's#<deploy-key-name>#'${deploykeyname}'#g' |\
      sed 's#<repo-name>#'${reponame}'#g' > resources.tmp

while IFS=, read servicename reponame deploykeyname dockerimagerepo projecttype;
  do
     cat templates/groups-master-jobs-body.yml |\
       sed 's#<service-name>#'${servicename}'#g' >> groups-master-jobs.tmp
     cat templates/groups-pr-jobs-body.yml |\
       sed 's#<service-name>#'${servicename}'#g' >> groups-pr-jobs.tmp
     cat templates/jobs-jobs-body.yml |\
       sed 's#<service-name>#'${servicename}'#g' |\
       sed 's#<infrastructure-service-name>#'${infraservicename}'#g' >> jobs-jobs.tmp
     cat templates/jobs-deploy-dev-triggers-body.yml |\
       sed 's#<service-name>#'${servicename}'#g' >> jobs-deploy-dev-triggers.tmp
     cat templates/jobs-integration-triggers-body.yml |\
       sed 's#<service-name>#'${servicename}'#g' >> jobs-integration-triggers.tmp
     cat templates/jobs-deploy-stage-triggers-body.yml |\
       sed 's#<service-name>#'${servicename}'#g' >> jobs-deploy-stage-triggers.tmp
     cat templates/jobs-deploy-prod-triggers-body.yml |\
       sed 's#<service-name>#'${servicename}'#g' >> jobs-deploy-prod-triggers.tmp
     cat templates/resources-body.yml |\
       sed 's#<service-name>#'${servicename}'#g' |\
       sed 's#<deploy-key-name>#'${deploykeyname}'#g' |\
       sed 's#<repo-name>#'${reponame}'#g' |\
       sed 's#<docker-image-repository>#'${dockerimagerepo}'#g' >> resources.tmp
  done < microservices.csv

cat templates/bumping.yml |\
  sed 's#<infrastruture-service-name>#'${infraservicename}'#g' |\
  sed 's#<environment>#'developement'#g' > bumping-dev.tmp
cat templates/bumping.yml |\
  sed 's#<infrastruture-service-name>#'${infraservicename}'#g' |\
  sed 's#<environment>#'staging'#g' > bumping-stage.tmp
cat templates/bumping.yml |\
  sed 's#<infrastruture-service-name>#'${infraservicename}'#g' |\
  sed 's#<environment>#'production'#g' > bumping-prod.tmp

cat templates/pipeline-template.yml |\
  sed 's#<infrastruture-service-name>#'${infraservicename}'#g' |\
  sed 's#<project-name>#'${projectname}'#g' |\
  sed 's/<slack-channel>/'${slackchannel}'/g' |\
  sed -e '/<groups-master-jobs>/{' -e 'r groups-master-jobs.tmp' -e 'd' -e'}' |\
  sed -e '/<groups-pr-jobs>/{' -e 'r groups-pr-jobs.tmp' -e 'd' -e'}' |\
  sed -e '/<jobs-jobs>/{' -e 'r jobs-jobs.tmp' -e 'd' -e'}' |\
  sed -e '/<jobs-deploy-dev-triggers>/{' -e 'r jobs-deploy-dev-triggers.tmp' -e 'd' -e'}' |\
  sed -e '/<jobs-integration-triggers>/{' -e 'r jobs-integration-triggers.tmp' -e 'd' -e'}' |\
  sed -e '/<jobs-deploy-stage-triggers>/{' -e 'r jobs-deploy-stage-triggers.tmp' -e 'd' -e'}'|\
  sed -e '/<jobs-deploy-prod-triggers>/{' -e 'r jobs-deploy-prod-triggers.tmp' -e 'd' -e'}' |\
  sed -e '/<bumping-development>/{' -e 'r bumping-dev.tmp' -e 'd' -e'}' |\
  sed -e '/<bumping-staging>/{' -e 'r bumping-stage.tmp' -e 'd' -e'}' |\
  sed -e '/<bumping-production>/{' -e 'r bumping-prod.tmp' -e 'd' -e'}' |\
  sed -e '/<resources>/{' -e 'r resources.tmp' -e 'd' -e'}' > ${1}

rm groups-master-jobs.tmp
rm groups-pr-jobs.tmp
rm jobs-jobs.tmp
rm jobs-deploy-dev-triggers.tmp
rm jobs-integration-triggers.tmp
rm jobs-deploy-stage-triggers.tmp
rm jobs-deploy-prod-triggers.tmp
rm resources.tmp
rm bumping-dev.tmp
rm bumping-stage.tmp
rm bumping-prod.tmp
