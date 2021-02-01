######
# Beanstalk EC2 role
######
data "aws_iam_policy_document" "beanstalk_ec2_role_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}
resource "aws_iam_role" "beanstalk_ec2_role" {
  assume_role_policy = data.aws_iam_policy_document.beanstalk_ec2_role_assume_role_policy.json
  name               = "beanstalk-sa-ec2-role-${var.stage}"
  path               = "/service-role/"
}

resource "aws_iam_policy_attachment" "ecr_readonly_policy_attachment" {
  name       = "ecr-readonly-policy-attachment-${var.stage}"
  policy_arn = aws_iam_policy.ecr_readonly_policy.arn
  roles      = [aws_iam_role.beanstalk_ec2_role.id]
}
resource "aws_iam_policy_attachment" "beanstalk_web_tier_policy_attachment" {
  name       = "beanstalk-web-tier-policy-attachment-${var.stage}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
  roles      = [aws_iam_role.beanstalk_ec2_role.id]
}
resource "aws_iam_policy_attachment" "beanstalk_mcdocker_policy_attachment" {
  name       = "beanstalk-mcdocker-policy-attachment-${var.stage}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
  roles      = [aws_iam_role.beanstalk_ec2_role.id]
}
resource "aws_iam_policy_attachment" "beanstalk_worker_tier_policy_attachment" {
  name       = "beanstalk-worker-tier-policy-attachment-${var.stage}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
  roles      = [aws_iam_role.beanstalk_ec2_role.id]
}
resource "aws_iam_instance_profile" "ec2" {
  name = "eb-ec2-${var.stage}"
  role = aws_iam_role.beanstalk_ec2_role.name
}

######
# Beanstalk service role
######
data "aws_iam_policy_document" "beanstalk_service_role_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["elasticbeanstalk.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = ["elasticbeanstalk"]
      variable = "sts:ExternalId"
    }
  }
}
resource "aws_iam_role" "beanstalk_app_service_role" {
  assume_role_policy = data.aws_iam_policy_document.beanstalk_service_role_assume_role_policy.json
  name               = "beanstalk-app-sa-service-role"
  path               = "/service-role/"
}
resource "aws_iam_role" "beanstalk_env_service_role" {
  assume_role_policy = data.aws_iam_policy_document.beanstalk_service_role_assume_role_policy.json
  name               = "beanstalk-env-${var.stage}-sa-service-role"
  path               = "/service-role/"
}
resource "aws_iam_policy_attachment" "beanstalk_enhanced_health_policy_attachment" {
  name       = "beanstalk-enhanced-health-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
  roles      = [
    aws_iam_role.beanstalk_app_service_role.id,
    aws_iam_role.beanstalk_env_service_role.id,
  ]
}
resource "aws_iam_policy_attachment" "beanstalk_beanstalk_service_policy_attachment" {
  name       = "beanstalk-beanstalk-service-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
  roles      = [
    aws_iam_role.beanstalk_app_service_role.id,
    aws_iam_role.beanstalk_env_service_role.id,
  ]
}