# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "rhel" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = ["RHEL-8.4.0_HVM-20210504-x86_64-2-Hourly2-GP2"]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}