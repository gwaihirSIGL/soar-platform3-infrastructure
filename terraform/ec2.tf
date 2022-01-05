// Find the latest default amazon AMI

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

// Create a small instance to be able to tunnel
// to the database, run migrations, etc

resource "aws_key_pair" "bastion_key" {
  key_name   = "soar_bastion-w"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhYFlPYii6DKOeipHhufP+64HH33GbLsnP00JS1KIqCCxg3dfxUiHfoK6nRv4zbq6uUtiabbBaMOqJI1XCBZf03PaXz2vm9P1qaBrByt5IFMLKEEmQr7cLfnbVcqGixE/CREhIDVRuPiQc/loGU2mK5eSgJSyz4Hk3KVwE5bibA6j3ckpCvX1ikzkU9P05Ptr1mKqznu5UDgDnLQ7Dgkl5WjjmJFZOkPGaYBX5jIXYBPP2CJTs3EqGCbqy7e8C35LjdkeGxuLQoxgbYvOjrgqIrKJhS0e4uB5ChFoVUy9nwPabjYwfNLnxx9iAhtc+FJj74l5nj87O76jXZvqMRcL4Ng7Fh6cL6FPSSAKdaD4EjTnf4jh9R0hUCVZD76i21z8xJi8ok1fUGSJFRA3EUjU5ki3p+lyk/hL8RLiBWO+Kq6htCX2CKkk9uzP8zjns43WT2T8+GBZBS4JAiUxJZiOnnZ12K7Xgt4opNh22LczyUJCcTYPSqrRTEu+d11JeZBWH6E1POxap6GPDmgYODbBSCnIfp4dvHcRMiU5XWyy4MkDwYFZ+4KKJbTrEuXceyLw7oljCJFiHoUqk/uSi+yEdnZXwsJLAAB4o9lq7vrG/wXZd3xaO1U14e2YqRyN4Og4ASRFT+A+MiS6zkTZN4Fc5LQpsE5w+VCsvxG4OAGddHw== naorid@naorid-G3-3590"
}

resource "aws_instance" "bastion_host" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  // For the key pair, we could use terraform
  // to generate it, but I've chosen to just
  // create it via the AWS console.
  //
  // Make sure it's a key pair name from the same
  // region in vars.tf, i.e. us-east-2
  key_name = aws_key_pair.bastion_key.key_name
  root_block_device {
    volume_type = "gp2"
    volume_size = 100
    encrypted   = true
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install postgresql -y"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("./soar-key")
    }
  }

  tags = {
    Name = "${local.tag_name}-bastion-host"
  }
}
// Output the ssh command for quick access
output "ssh_cmd" {
  value = "ssh -i soar-key ec2-user@${aws_instance.bastion_host.public_ip}"
}
