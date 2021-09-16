#!/bin/bash

USER=___
domain=0
api=0
ip=0
port=0
path=0

function changeWordPressApi {
  localApi="$1\',"
  sed -i "/wordpressApi/s/\/\/.*/\/\/$localApi/" next.config.js
  echo "changed file next.config.js"
}

function changeDockerfile {
  sed -i "/EXPOSE/s/[0-9].*/$1/" Dockerfile
  echo "changed Dockerfile"
}

function changePackageJsonFile {
  sed -i "/next\ start/s/[0-9]...[0-9]/$1/" package.json
  sed -i "/next\ dev/s/[0-9]...[0-9]/$1/" package.json
  echo "changed package.json"
}

function changeCity {
  cityLine="city: \'$1\'"
  sed -i "/city:/s/.*/$cityLine/" lib/tempConfig.js
  echo "changed city"
}

function reloadDockerContainer {
  prefixName=0
  case "$ip" in
    "_._._._" ) prefixName=dasw_;;
    "_._._._" ) prefixName=dt_ ;;
    "_._._._" ) prefixName=ppc_ ;;
    #"_._._._" ) prefixName= ;;
    * ) echo "PORT: $port is not a found"
  esac

  name_service=$prefixName$(echo ${domain} | tr "." "_" | tr "-" "_")
  echo "name_service - $name_service"
  ssh $USER@$IP "docker service update ${name_service} --force"
}

function connectSSH {
  IP=$1
  remotePath=/home/docker/www/$2
  echo $remotePath
  ssh $USER@$IP "ls -a $remotePath; rm -rf $remotePath/*; ls -a $remotePath; exit"
  rsync -avPHSX * $USER@$IP:$remotePath/

  ssh $USER@$IP "cd $remotePath ; ./registered_new_project.sh ${domain} ${port}"

}

function continueProcess {
  jobs -l
  read -p 'continue building process [ yes/no ]: ' result
  case "$result" in
    "yes" ) fuser -k $port/tcp ; connectSSH $ip $path;;
    "no" ) fuser -k $port/tcp ; exit;;
    * ) echo "Please, make your choice: " ; continueProcess;;
  esac
}

function buildProject {
  echo "start build project"
  rm -rf _next
  rm -rf node_modules
  npm install
  npm run build
  npm run start &
  google-chrome http://localhost:$port &
  continueProcess
}

function startBuildingStateSite {
  if [ "$domain" != 0 ] && [ "$api" != 0 ] && [ "$ip" != 0 ] && [ "$port" != 0 ] && [ "$path" != 0 ]; then
    echo "$domain, $api, $ip, $port, $path"
    changeWordPressApi "$api"
    changeDockerfile "$port"
    changePackageJsonFile "$port"
    buildProject
    domain=0 api=0 ip=0 port=0 path=0
  fi
}

function parseLine {
  array=($(echo "$1" | tr ' ' '\n'))
  key="${array[0]}"
  trimKey="${key//[[:space:]]/}"
  value=`sed "s/[',\"]//g" <<< "${array[1]}"`

  case "$trimKey" in
    "DOMAIN:" ) domain=$value;;
    "API:" ) api=$value;;
    "IP:" ) ip=$value;;
    "PORT:" ) port=$value;;
    "PATH:" ) path=$value;;
    "CITY:" ) changeCity $value;;
    'end') startBuildingStateSite;;
    * ) ;;
  esac
}

for project in $@
 do
  echo "Open $project"
  cd $project
  IFS=$'\n'
  for line in $(cat domains.js)
   do
    parseLine $line
   done
   cd ..
 done
