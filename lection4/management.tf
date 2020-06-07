terraform {
  backend "s3" {
    bucket = "mrzebo.devopsterraform.boris"
    key    = "terraform.tfstate"
    shared_credentials_file = "../../.aws/credentials"
    dynamodb_table = "mrzebo.devopsterraform.boris"
    region = "us-east-1"
    profile = "default"
    
  }
}
