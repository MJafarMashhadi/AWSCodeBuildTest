resource "aws_codebuild_project" "code_build" {
  name          = "dumpster-project-build"
  badge_enabled = true
  build_timeout = 5
  service_role  = aws_iam_role.code_build_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }
  source {
    git_clone_depth     = 1
    insecure_ssl        = false
    location            = "https://github.com/MJafarMashhadi/AWSCodeBuildTest"
    report_build_status = false
    type                = "GITHUB"

    git_submodules_config {
      fetch_submodules = false
    }
  }
}
