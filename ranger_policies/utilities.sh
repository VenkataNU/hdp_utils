#! /bin/bash
###############################################################################
# SCRIPT NAME:         utilities.sh
# AUTHOR NAME:         Venkata Naidu Udamala
# CREATION DATE:       Sep-2019
#
# DESCRIPTION: This script will contain all the utility functions
#
#
# DEPENDENCIES: <<TODO>>
#
###############################################################################
source properties/core_properties.cnf

set -e

echo_date(){
    echo "["`date +'%Y-%m-%d %H:%M:%S %Z'`"] $1"
}

start_script(){
 echo_date "###########################################################################"
 echo_date "##########Script $1 execution started############"
}

end_script(){
 echo_date "##########Script $1 execution completed successfully!!!!!!############"
 echo_date "###########################################################################"
}

start_function(){
 echo_date "#############Function ${FUNCNAME[1]} execution started#####################"
}

end_function(){
 echo_date "#############Function ${FUNCNAME[1]} execution completed###################"
 }

 ranger_policy_create(){
 start_function
 #This function will make a rest call to create a ranger policy
 json_load_file=$1
 echo_date "json_load_file is $json_load_file"

 result=$(curl -ik --write-out %{http_code}  \
       -u $ranger_user:$ranger_pass \
       -H "Content-Type: application/json" \
       -d @$json_load_file \
       -X POST https://${ranger_host_name}:${ranger_port}/service/public/v2/api/policy)
  echo_date "result is $result"

          if [[ $result == *"200"* ]];then
             echo_date "Ranger policy with payload created successfully";
          else
             echo_date "Ranger policy could not be created";
             exit 1
          fi

 end_function
 }

 cleanUp(){
 start_function
 #This function will delete the files, it will fail if the file does not exist
     file_name=$1
     if [ -f "$file_name" ]; then
      echo_date "File "$file_name" exists and removing it"
      rm -f $file_name
       rc=$?
           if [[ rc -eq 0 ]];then
              echo_date "File "$file_name" removed successfully";
           else
              echo_date "File "$file_name" could not be removed ";
           fi
     else
           echo_date "File "$file_name" does not exist";
     fi
 end_function
 }

