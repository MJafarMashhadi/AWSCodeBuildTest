data "aws_iam_policy_document" "codepipeline_bucket_policy" {
  policy_id = "SSEAndSSLPolicy"
  statement {
    sid       = "DenyUnEncryptedObjectUploads"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.codepipeline_bucket.arn}/*"]
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    condition {
      test     = "StringNotEquals"
      values   = ["aws:kms"]
      variable = "s3:x-amz-server-side-encryption"
    }
  }
  statement {
    sid       = "DenyInsecureConnections"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.codepipeline_bucket.arn}/*"]
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}

resource "aws_s3_bucket_policy" "codepipeline_bucket_policy" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  policy = data.aws_iam_policy_document.codepipeline_bucket_policy.json
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "dumpster-codepipeline-artifacts-${var.stage}"
  acl    = "private"
  versioning {
    enabled    = false
    mfa_delete = false
  }
}

resource "aws_codepipeline" "codepipeline" {
  name     = "dumpster-codepipeline-${var.stage}"
  role_arn = aws_iam_role.codepipeline_service_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      category         = "Source"
      name             = "Source"
      namespace        = "SourceVariables"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        # TODO: connection arn
        ConnectionArn        = "arn:aws:codestar-connections:us-east-1:469736494277:connection/9810c44b-0fe4-42c3-b882-bad9ee97c0fb"
        BranchName           = "master"
        FullRepositoryId     = "MJafarMashhadi/AWSCodeBuildTest"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }
  stage {
    name = "Build"
    action {
      category         = "Build"
      name             = "Build"
      namespace        = "BuildVariables"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      configuration = {
        BatchEnabled = false
        ProjectName  = aws_codebuild_project.code_build.name
      }
    }
  }
  stage {
    name = "Deploy"
    action {
      category        = "Deploy"
      name            = "Deploy"
      namespace       = "DeployVariables"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      version         = "1"
      input_artifacts = ["BuildArtifact"]
      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.beanstalk_app.name
        EnvironmentName = aws_elastic_beanstalk_environment.beanstalk_app_environment.name
      }
    }
  }
}
