#!/bin/bash 

echo "Creating metric filter and cloudwatch metric alarm 'MFAUnauthenticatedAccess'"
aws logs put-metric-filter --filter-name "MFAUnauthenticatedAccess" \
 --log-group-name "myLogGroup" \
 --filter-pattern '{ $.userIdentity.sessionContext.attributes.mfaAuthenticated != "true" }' \
 --metric-transformation metricName="ApiActivityWithoutMFACount",metricNamespace="CloudTrailMetrics",metricValue="1"

aws cloudwatch put-metric-alarm --alarm-name "MFAUnauthenticatedAccess" \
 --alarm-description "A CloudWatch Alarm that triggers if there is API activity in the account without MFA (Multi-Factor Authentication)." \
 --alarm-actions "sns_topic_exemplo" \
 --metric-name "ApiActivityWithoutMFACount" \
 --namespace "CloudTrailMetrics" --statistic "Sum" --period 300 --evaluation-periods 1 --threshold 1 \
 --comparison-operator "GreaterThanOrEqualToThreshold" --treat-missing-data "notBreaching"


#  https://asecure.cloud/a/cwalarm_no_mfa_api_activity/
#  https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax-examples.html
#  { $.userIdentity.sessionContext.attributes.mfaAuthenticated != "true" }
