locals {
   env = {
      default = {
         instance_type  = "t2.micro"
      }
     dev = {
         instance_type  = "t2.micro"
      }
      stage = {
         instance_type  = "t2.small"
      }
      prod = {
         instance_type  = "t2.medium"
      }
   }
environmentvars ="${contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"}"
workspace = "${merge(local.env["default"], local.env[local.environmentvars])}"
}
