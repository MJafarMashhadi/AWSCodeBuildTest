resource "aws_ecr_repository" "dumpster_repo" {
  name                 = "code-build-dumpster"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}