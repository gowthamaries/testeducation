#dtc_site_name=grassdooraws elbv2 create-target-group \
    --name my-targets \
    --protocol HTTP \
    --port 80 \
    --target-type instance \
    --vpc-id 
#BUILD_NUMBER=22
echo ${BUILD_NUMBER}
echo ${dtc_site_name}

TASK_FAMILY=${dtc_site_name}
NEW_IMAGE=953496156775.dkr.ecr.us-west-2.amazonaws.com/dtc-store/${dtc_site_name}:DTC_${BUILD_NUMBER}
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$TASK_FAMILY" --region "us-west-2")
NEW_TASK_DEFINTIION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$NEW_IMAGE" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities)')
aws ecs register-task-definition --region "us-west-2" --cli-input-json "$NEW_TASK_DEFINTIION"

banner Updating Service

ecsClusterName=Store-VPC
nameTaskDefinition=${dtc_site_name}
nameService=Grassdoor
version=${BUILD_NUMBER}
OLD_TASK_ID=$(aws ecs list-tasks --cluster ${ecsClusterName} --desired-status RUNNING --family ${nameTaskDefinition} | egrep "task/" | sed -E "s/.*task\/(.*)\"/\1/")
echo $OLDS_TASK_ID
aws ecs update-service --cluster ${ecsClusterName} --service ${nameService} --task-definition ${nameTaskDefinition} --desired-count 2 --force-new-deployment

aws ecs describe-services --cluster ${ecsClusterName} --services ${nameService}


sleep 30

