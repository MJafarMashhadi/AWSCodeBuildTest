resource "aws_ecr_repository" "dumpster_repo" {
  name                 = "code-build-dumpster"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

#####
# IAM policies
#####
data "aws_iam_policy_document" "ecr_readonly_policy" {
  statement {
    sid = "AllowPull"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchGetImage",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeImages",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
    ]
    effect    = "Allow"
    resources = [aws_ecr_repository.dumpster_repo.arn, ]
  }
  statement {
    sid       = "AllowEbAuth"
    actions   = ["ecr:GetAuthorizationToken"]
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
}
resource "aws_iam_policy" "ecr_readonly_policy" {
  name   = "ecr-readonly-policy"
  policy = data.aws_iam_policy_document.ecr_readonly_policy.json
}
