resource "aws_codebuild_project" "code_build" {
  name           = "dumpster-project-build"
  badge_enabled  = true
  build_timeout  = 5
  service_role   = aws_iam_role.code_build_role.arn
  source_version = "master"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }
  source {
    type                = "GITHUB"
    location            = "https://github.com/MJafarMashhadi/AWSCodeBuildTest.git"
    git_clone_depth     = 1
    insecure_ssl        = false
    report_build_status = false

    git_submodules_config {
      fetch_submodules = false
    }
  }
}
