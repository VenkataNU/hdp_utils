#! /bin/bash
###############################################################################
# SCRIPT NAME:         kafka_create_ranger_policy.sh
# AUTHOR NAME:         Venkata Naidu Udamala
# CREATION DATE:       Sep-2019
# CURRENT REVISION NO: 1
#
# DESCRIPTION: This script will perform below 3 steps
#              1. Check if the required parameters are passed
#              2. Create the json load based on the input parameters
#              3. Create ranger policy using rest api and json load from above step
#
# USAGE: kafka_create_ranger_policy.sh <policy_name> <topic_name> <publisher groups> <consumer groups>
#
###############################################################################
source utilities.sh
source properties/kafka_ranger_properties.cnf

# Check for number of parameters passed #
if [[ $# < 4 || $# > 4 ]]; then
   echo "Less than 4 or greater than 4  params passed."
   echo "USAGE: kafka_create_ranger_policy.sh <policy_name> <topic_name> <publisher groups> <consumer groups>"
   echo 'EXAMPLE: kafka_create_ranger_policy.sh "test_topic_policy" "test_topic" "mdt_test_altair" "public" '
   exit 1;
fi

export kafka_policy_name="$1"
export kafka_topic_name="$2"
export publisher_access_groups="$3"
export consumer_access_groups="$4"

echo_date "Parameters passed are: policy_name - ${kafka_policy_name}, topic_name - ${kafka_topic_name}, publisher groups - ${publisher_access_groups}, consumer groups - ${consumer_access_groups}"

start_script `basename "$0"`

create_json_load() {
start_function

export publisher_accesses="{\"type\":\"publish\",\"isAllowed\":true},{\"type\":\"consume\",\"isAllowed\":true},{\"type\":\"configure\",\"isAllowed\":true},{\"type\":\"describe\",\"isAllowed\":true},{\"type\":\"create\",\"isAllowed\":true},{\"type\":\"delete\",\"isAllowed\":true},{\"type\":\"describe_configs\",\"isAllowed\":true},{\"type\":\"alter_configs\",\"isAllowed\":true}"

export consumer_accesses="{\"type\":\"consume\",\"isAllowed\":true},{\"type\":\"describe\",\"isAllowed\":true},{\"type\":\"describe_configs\",\"isAllowed\":true}"

cat ${kafka_template_file} > ${kafka_json_load_file}
echo_date "template file used is ${kafka_template_file}"

sed -i "s|kafka_service_name|$kafka_service_name|g" ${kafka_json_load_file}
sed -i "s|kafka_policy_name|$kafka_policy_name|g" ${kafka_json_load_file}
sed -i "s|kafka_topic_name|$kafka_topic_name|g" ${kafka_json_load_file}
sed -i "s|publisher_access_groups|$publisher_access_groups|g" ${kafka_json_load_file}
sed -i "s|consumer_access_groups|$consumer_access_groups|g" ${kafka_json_load_file}
sed -i "s|publisher_accesses|$publisher_accesses|g" ${kafka_json_load_file}
sed -i "s|consumer_accesses|$consumer_accesses|g" ${kafka_json_load_file}

echo_date "json load file ${kafka_json_load_file} is successfully created"

end_function
}

cleanUp ${kafka_json_load_file}

create_json_load

ranger_policy_create  ${kafka_json_load_file}

end_script `basename "$0"`

exit 0

