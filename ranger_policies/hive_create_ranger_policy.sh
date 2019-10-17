#! /bin/bash
###############################################################################
# SCRIPT NAME:         hive_create_ranger_policy.sh
# AUTHOR NAME:         Venkata Naidu Udamala
# CREATION DATE:       Sep-2019
# CURRENT REVISION NO: 1
#
# DESCRIPTION: This script will perform below 3 steps
#              1. Check if the required parameters are passed
#              2. Create the json load based on the input parameters
#              3. Create ranger policy using rest api and json load from above step
#
# USAGE: hive_create_ranger_policy.sh <policy_name> <database_name> <write groups> <read groups>
#
###############################################################################
source utilities.sh
source properties/hive_ranger_properties.cnf

# Check for number of parameters passed #
if [[ $# < 4 || $# > 4 ]]; then
   echo "Less than 4 or greater than 4  params passed."
   echo "USAGE: hive_create_ranger_policy.sh <policy_name> <database_name> <write groups> <read groups>"
   echo 'EXAMPLE: hive_create_ranger_policy.sh "test_database" "svc_hdfdev4_hive" "mdt_test_altair" "public" '
   exit 1;
fi

export hive_policy_name="$1"
export hive_database_name="$2"
export write_access_groups="$3"
export read_access_groups="$4"

echo_date "Parameters passed are: policy_name - ${hive_policy_name}, database name - ${hive_database_name}, writer groups - ${write_access_groups}, reader groups - ${read_access_groups}"

start_script `basename "$0"`

create_json_load() {
start_function

export hive_write_accesses="{\"type\":\"select\",\"isAllowed\":true},{\"type\":\"update\",\"isAllowed\":true},{\"type\":\"create\",\"isAllowed\":true},{\"type\":\"drop\",\"isAllowed\":true},{\"type\":\"alter\",\"isAllowed\":true},{\"type\":\"index\",\"isAllowed\":true},{\"type\":\"lock\",\"isAllowed\":true},{\"type\":\"all\",\"isAllowed\":true},{\"type\":\"read\",\"isAllowed\":true},{\"type\":\"write\",\"isAllowed\":true},{\"type\":\"repladmin\",\"isAllowed\":true},{\"type\":\"serviceadmin\",\"isAllowed\":true},{\"type\":\"tempudfadmin\",\"isAllowed\":true}"

export hive_read_accesses="{\"type\":\"select\",\"isAllowed\":true},{\"type\":\"read\",\"isAllowed\":true}"

cat ${hive_template_file} > ${hive_json_load_file}
echo_date "template file used is ${hive_template_file}"

sed -i "s|hive_service_name|$hive_service_name|g" ${hive_json_load_file}
sed -i "s|hive_policy_name|$hive_policy_name|g" ${hive_json_load_file}
sed -i "s|hive_database_name|$hive_database_name|g" ${hive_json_load_file}
sed -i "s|hive_write_access_groups|$write_access_groups|g" ${hive_json_load_file}
sed -i "s|hive_read_access_groups|$read_access_groups|g" ${hive_json_load_file}
sed -i "s|hive_write_accesses|$hive_write_accesses|g" ${hive_json_load_file}
sed -i "s|hive_read_accesses|$hive_read_accesses|g" ${hive_json_load_file}

echo_date "json load file ${hive_json_load_file} is successfully created"

end_function
}

cleanUp ${hive_json_load_file}

create_json_load

ranger_policy_create  ${hive_json_load_file}

end_script `basename "$0"`

exit 0

