#! /bin/bash
###############################################################################
# SCRIPT NAME:         hbase_create_ranger_policy.sh
# AUTHOR NAME:         Venkata Naidu Udamala
# CREATION DATE:       Sep-2019
# CURRENT REVISION NO: 1
#
# DESCRIPTION: This script will perform below 3 steps
#              1. Check if the required parameters are passed
#              2. Create the json load based on the input parameters
#              3. Create ranger policy using rest api and json load from above step
#
# USAGE: hbase_create_ranger_policy.sh <policy_name> <namespace_name> <write groups> <read groups>
#
###############################################################################
source utilities.sh
source properties/hbase_ranger_properties.cnf

# Check for number of parameters passed #
if [[ $# < 4 || $# > 4 ]]; then
   echo "Less than 4 or greater than 4  params passed."
   echo "USAGE: hbase_create_ranger_policy.sh <policy_name> <namespace_name> <write groups> <read groups>"
   echo 'EXAMPLE: hbase_create_ranger_policy.sh "commonNameSpace" "svc_hdfdev4_hbase" "mdt_test_altair" "public" '
   exit 1;
fi

export hbase_policy_name="$1"
export hbase_namespace_name="$2"
export write_access_groups="$3"
export read_access_groups="$4"

echo_date "Parameters passed are: policy_name - ${hbase_policy_name}, namespace name - ${hbase_namespace_name}, writer groups - ${write_access_groups}, reader groups - ${read_access_groups}"

start_script `basename "$0"`

create_json_load() {
start_function

export hbase_write_accesses="{\"type\":\"read\",\"isAllowed\":true},{\"type\":\"write\",\"isAllowed\":true},{\"type\":\"create\",\"isAllowed\":true}"

export hbase_read_accesses="{\"type\":\"read\",\"isAllowed\":true}"

export hbase_namespace_value=$hbase_namespace_name':*'

cat ${hbase_template_file} > ${hbase_json_load_file}
echo_date "template file used is ${hbase_template_file}"

sed -i "s|hbase_service_name|$hbase_service_name|g" ${hbase_json_load_file}
sed -i "s|hbase_policy_name|$hbase_policy_name|g" ${hbase_json_load_file}
sed -i "s|hbase_namespace_value|$hbase_namespace_value|g" ${hbase_json_load_file}
sed -i "s|hbase_write_access_groups|$write_access_groups|g" ${hbase_json_load_file}
sed -i "s|hbase_read_access_groups|$read_access_groups|g" ${hbase_json_load_file}
sed -i "s|hbase_write_accesses|$hbase_write_accesses|g" ${hbase_json_load_file}
sed -i "s|hbase_read_accesses|$hbase_read_accesses|g" ${hbase_json_load_file}

echo_date "json load file ${hbase_json_load_file} is successfully created"

end_function
}

cleanUp ${hbase_json_load_file}

create_json_load

ranger_policy_create  ${hbase_json_load_file}

end_script `basename "$0"`

exit 0

