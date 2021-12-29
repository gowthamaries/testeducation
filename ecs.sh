#/bin/sh

#Domain_Name=www.deliverselect.com

Firstdomname=`echo "$Domain_Name" | cut -d"." -f1`
Seconddomname=`echo "$Domain_Name" | cut -d"." -f2`
Thirddomname=`echo "$Domain_Name" | cut -d"." -f3`
LowerFirstdomname=`echo $Firstdomname | tr '[:upper:]' '[:lower:]'`
LowerSeconddomname=`echo $Seconddomname | tr '[:upper:]' '[:lower:]'`
dtc_upper=$(echo "$Firstdomname-$Seconddomname-UI" | tr '[:lower:]' '[:upper:]')
eval dtc_site_name=$LowerSeconddomname

aws ecr create-repository --repository-name dtc-store/$dtc_site_name || true
eval NEW_IMAGE=$(aws ecr describe-repositories --repository-names "dtc-store/${dtc_site_name}" --query "repositories[0].repositoryUri")
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "grassdoor" --region "us-west-2")
NEW_TASK_DEFINTIION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$NEW_IMAGE" --arg dtc_name "$dtc_site_name" --arg logname "$dtc_site_name" '.taskDefinition | .containerDefinitions[0].image = $IMAGE |.containerDefinitions[0].name = $dtc_name  | .family = $dtc_name | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities)')
aws ecs register-task-definition --region "us-west-2" --cli-input-json "$NEW_TASK_DEFINTIION"
NEW_TARGET_GROUP_NAME=$(aws elbv2 create-target-group --name ecs-Store-$dtc_site_name --protocol HTTP --port 5000 --target-type ip --vpc-id vpc-09dea383b3c5cabf7)
eval TARGET_NAME=$(echo $NEW_TARGET_GROUP_NAME | jq .TargetGroups[].TargetGroupArn)
echo $TARGET_NAME
ELB_FLTR=`aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerArn]' --output text | grep "$dtc_upper"`
ELB_NAME=`eval echo $ELB_FLTR`
aws elbv2 create-listener --load-balancer-arn $ELB_NAME --protocol HTTP --port 5000 --default-actions Type=forward,TargetGroupArn=$TARGET_NAME
aws ecs create-service --cluster Store-VPC --service-name $dtc_site_name --task-definition $dtc_site_name --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[subnet-045b7f3a2b90fe04b, subnet-01cb8224ab579584a],securityGroups=[sg-0481ab085e5b9d2c6],assignPublicIp=ENABLED}" --load-balancers='[{"targetGroupArn": "'$TARGET_NAME'", "containerName": "'$dtc_site_name'", "containerPort": 5000 }]'