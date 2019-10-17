#! /bin/bash
###############################################################################
# SCRIPT NAME:         hdfs_create_ranger_policy.sh
# AUTHOR NAME:         Venkata Naidu Udamala
# CREATION DATE:       Sep-2019
# CURRENT REVISION NO: 1
#
# DESCRIPTION: This script will perform below 3 steps
#              1. Check if the required parameters are passed
#              2. Create the json load based on the input parameters
#              3. Create ranger policy using rest api and json load from above step
#
# USAGE: hdfs_create_ranger_policy.sh <policy_name> <directory_name> <write groups> <read groups>
#
###############################################################################
source utilities.sh
source properties/hdfs_ranger_properties.cnf

# Check for number of parameters passed #
if [[ $# < 4 || $# > 4 ]]; then
   echo "Less than 4 or greater than 4  params passed."
   echo "USAGE: hdfs_create_ranger_policy.sh <policy_name> <directory_name> <write groups> <read groups>"
   echo 'EXAMPLE: hdfs_create_ranger_policy.sh "test_policy" "svc_hdfdev4_hdfs" "mdt_test_altair" "public" '
   exit 1;
fi

export hdfs_policy_name="$1"
export hdfs_directory_name="$2"
export write_access_groups="$3"
export read_access_groups="$4"

echo_date "Parameters passed are: policy_name - ${hdfs_policy_name}, directory - ${hdfs_directory_name}, writer groups - ${write_access_groups}, reader groups - ${read_access_groups}"

start_script `basename "$0"`

create_json_load() {
start_function

export hdfs_write_accesses="{\"type\":\"read\",\"isAllowed\":true},{\"type\":\"write\",\"isAllowed\":true},{\"type\":\"execute\",\"isAllowed\":true}"

export hdfs_read_accesses="{\"type\":\"read\",\"isAllowed\":true}"

cat ${hdfs_template_file} > ${hdfs_json_load_file}
echo_date "template file used is ${hdfs_template_file}"

sed -i "s|hdfs_service_name|$hdfs_service_name|g" ${hdfs_json_load_file}
sed -i "s|hdfs_policy_name|$hdfs_policy_name|g" ${hdfs_json_load_file}
sed -i "s|hdfs_directory_name|$hdfs_directory_name|g" ${hdfs_json_load_file}
sed -i "s|hdfs_write_access_groups|$write_access_groups|g" ${hdfs_json_load_file}
sed -i "s|hdfs_read_access_groups|$read_access_groups|g" ${hdfs_json_load_file}
sed -i "s|hdfs_write_accesses|$hdfs_write_accesses|g" ${hdfs_json_load_file}
sed -i "s|hdfs_read_accesses|$hdfs_read_accesses|g" ${hdfs_json_load_file}

echo_date "json load file ${hdfs_json_load_file} is successfully created"

end_function
}

cleanUp ${hdfs_json_load_file}

create_json_load

ranger_policy_create  ${hdfs_json_load_file}

end_script `basename "$0"`

exit 0

