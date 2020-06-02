resource "aws_iam_user" "developer-test" {
  name = "grade-test-super-user"
  path = "/system/"

  tags = {
    tag-key = "tag-value"
  }
}
