######
# Codepipeline service role
######
data "aws_iam_policy_document" "codepipeline_service_role_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["codepipeline.amazonaws.com"]
      type        = "Service"
    }
  }
}
data "aws_iam_policy_document" "codepipeline_service_role_policy" {
  policy_id = "CodePipeline Service Role Policies"
  statement {
    sid = "PassRole"
    actions = [
      "iam:PassRole"
    ]
    effect = "Allow"
    condition {
      test = "StringEqualsIfExists"
      values = [
        "cloudformation.amazonaws.com",
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
      variable = "iam:PassedToService"
    }
    resources = ["*"]
  }
  statement {
    sid    = "CodeBuildAccess"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AccessGitHubConnection"
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = [
      # TODO: connection ARN
      "arn:aws:codestar-connections:us-east-1:469736494277:connection/9810c44b-0fe4-42c3-b882-bad9ee97c0fb"
    ]
  }
  statement {
    sid    = "UpdateBeanstalk"
    effect = "Allow"
    actions = [
      "elasticbeanstalk:*",
    ]
    resources = [
//      aws_elastic_beanstalk_application.beanstalk_app.arn,
//      aws_elastic_beanstalk_environment.beanstalk_app_environment.arn,
//      "arn:aws:elasticbeanstalk:${var.region}::applicationversion/${aws_elastic_beanstalk_application.beanstalk_app.name}*",
//      "arn:aws:elasticbeanstalk:${var.region}::platform/*",
      "*",
    ]
    condition {
      test = "StringEqualsIfExists"
      values = [aws_elastic_beanstalk_application.beanstalk_app.arn]
      variable = "elasticbeanstalk:InApplication"
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:ResumeProcesses",
      "autoscaling:SuspendProcesses",
      "cloudformation:GetTemplate",
      "cloudformation:DescribeStackResource",
      "cloudformation:DescribeStackResources",
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStacks",
      "cloudformation:UpdateStack",
      "ec2:DescribeInstances",
      "ec2:DescribeImages",
      "ec2:DescribeAddresses",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeKeyPairs",
      "elasticloadbalancing:DescribeLoadBalancers",
      "rds:DescribeDBInstances",
      "rds:DescribeOrderableDBInstanceOptions",
      "sns:ListSubscriptionsByTopic"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
//      "s3:*",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketPolicy",
      "s3:GetObjectAcl",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::elasticbeanstalk*",
    ]
  }
}
resource "aws_iam_policy" "codepipeline_service_role_policy" {
  policy = data.aws_iam_policy_document.codepipeline_service_role_policy.json
}

data "aws_iam_policy_document" "codepipeline_s3_policy" {
  policy_id = "CodePipeline Manage S3"
  statement {
    sid    = "ManageS3Bucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
  }
}
resource "aws_iam_policy" "codepipeline_s3_policy" {
  policy = data.aws_iam_policy_document.codepipeline_s3_policy.json
}

resource "aws_iam_role" "codepipeline_service_role" {
  assume_role_policy = data.aws_iam_policy_document.codepipeline_service_role_assume_role_policy.json
  name               = "codepipeline-service-role-${var.stage}"
  path               = "/service-role/"
}
# Exclusive policy-role mapping
resource "aws_iam_policy_attachment" "codepipeline_service_role_policy_attachment" {
  name       = "codepipeline-policy-attachment-${var.stage}"
  policy_arn = aws_iam_policy.codepipeline_service_role_policy.arn
  roles      = [aws_iam_role.codepipeline_service_role.id]
}
# Non exclusive policy-role mapping
resource "aws_iam_role_policy_attachment" "codepipeline_s3_policy_attachment" {
  policy_arn = aws_iam_policy.codepipeline_s3_policy.arn
  role       = aws_iam_role.codepipeline_service_role.id
}
resource "aws_iam_role_policy_attachment" "codepipeline_service_role_policy_ecr_attachment" {
  policy_arn = aws_iam_policy.ecr_readonly_policy.arn
  role       = aws_iam_role.codepipeline_service_role.id
}