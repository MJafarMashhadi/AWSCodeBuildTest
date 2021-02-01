resource "aws_elastic_beanstalk_application" "beanstalk_app" {
  name = "dumpster-app"

  appversion_lifecycle {
    service_role          = aws_iam_role.beanstalk_app_service_role.arn
    max_count             = 10
    delete_source_from_s3 = true
  }
}

resource "aws_elastic_beanstalk_environment" "beanstalk_app_environment" {
  application         = aws_elastic_beanstalk_application.beanstalk_app.name
  name                = "dumpster-app-${var.stage}"
  solution_stack_name = "64bit Amazon Linux 2 v3.2.4 running Docker"
  tier                = "WebServer"

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.beanstalk_app_service_role.id
    resource  = ""
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = "t3.micro"
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
    resource  = ""
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ec2.name
    resource  = ""
  }

}
