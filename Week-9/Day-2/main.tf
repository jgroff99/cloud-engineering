resource "aws_s3_bucket" "main" {
  bucket = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bucket"
  })
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = lookup(var.instance_type_map, var.environment, "t3.micro")

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web"
  })
}
