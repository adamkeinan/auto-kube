# Create EC2 Instance - Amazon Linux
data "aws_instance" "rhel_instance" {
  ami                       = var.aws_ami
  instance_type             = var.instance_type
  key_name                  = "labadmin_key_pair"
  public_ip                 = "34.248.209.195"
  public_dns                = "ec2-34-248-209-195.eu-west-1.compute.amazonaws.com"
  user_data                 = file("apache-install.sh")  
  vpc_security_group_ids    = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id, aws_security_group.control_plane.id]
  #count = terraform.workspace == "default" ? 1 : 1 
  user_data = file("apache-install.sh")
  # user_data = <<-EOF
  #   #!/bin/bash
  #   sudo yum update -y
  #   sudo yum install httpd -y
  #   sudo systemctl enable httpd
  #   sudo systemctl start httpd
  #   echo "<h1>Welcome to Eks Stack ! AWS Infra created using Terraform in us-east-1 Region</h1>" > /var/www/html/index.html
  #   EOF
  tags = {
    "Name" = "RHEL"
  }

  connection {
    type = "ssh"
    host = self.public_ip # Understand what is "self"
    user = "ec2-user"
    password = ""
    private_key = file(".ssh/labadmin.pem")
  }  

  # Copies the file-copy.html file to /tmp/file-copy.html
  provisioner "file" {
    source      = "apps/file-copy.html"
    destination = "/tmp/file-copy.html"
  }

# Copies the file to Apache Webserver /var/www/html directory
  provisioner "remote-exec" {
    inline = [
      "sleep 120",  # Will sleep for 120 seconds to ensure Apache webserver is provisioned using user_data
      "sudo cp /tmp/file-copy.html /var/www/html"
    ]
  }
}