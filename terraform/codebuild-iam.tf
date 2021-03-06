###############
# Code build IAM configurations
###############
# Permissions
resource "aws_iam_policy" "code_build_role_policy" {
  name   = "code-build-role-policy-${var.stage}"
  policy = data.aws_iam_policy_document.code_build_role_policy.json
}
## Who can assume this role? Only the code build service account
data "aws_iam_policy_document" "code_build_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["codebuild.amazonaws.com"]
      type        = "Service"
    }
  }
}
## What will they get from assuming it?
data "aws_iam_policy_document" "code_build_role_policy" {
  statement {
    sid     = "AllowInteractionWithECR"
    actions = ["ecr:*"]
    effect  = "Allow"
    resources = [
      aws_ecr_repository.dumpster_repo.arn,
    ]
  }
  statement {
    sid = "AllowAuthenticationToECR"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "AllowAuthenticationToPublicECRGallery"
    actions = [
      "ecr-public:GetAuthorizationToken",
      "sts:GetServiceBearerToken"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "AllowLogging"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

# Service role
resource "aws_iam_role" "code_build_role" {
  name               = "codebuild-code-build-test-${var.stage}-service-role"
  assume_role_policy = data.aws_iam_policy_document.code_build_assume_role_policy.json
  path               = "/service-role/"
}

# Attaching permissions to the service role
resource "aws_iam_role_policy_attachment" "code_build_role_policy_attachment" {
  policy_arn = aws_iam_policy.code_build_role_policy.arn
  role       = aws_iam_role.code_build_role.id
}
resource "aws_iam_role_policy_attachment" "codebuild_s3_policy_attachment" {
  policy_arn = aws_iam_policy.codepipeline_s3_policy.arn
  role       = aws_iam_role.code_build_role.id
}