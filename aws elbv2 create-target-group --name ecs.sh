aws elbv2 create-target-group --name ecs-Store-$dtc_site_name --protocol HTTP --port 5000 --target-type ip --vpc-id vpc-09dea383b3c5cabf7

aws elbv2 create-listener --load-balancer-arn $dtc_upper --protocol TCP --port 5000 --default-actions Type=forward,TargetGroupArn=$TARGET_NAME