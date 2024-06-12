# ./jenkins.tf

resource "aws_iam_role" "jenkins_ssm_role" {
  name = "jenkins-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ssm_role_attachment" {
  role       = aws_iam_role.jenkins_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jenkins_ssm_instance_profile" {
  name = "jenkins-ssm-instance-profile"
  role = aws_iam_role.jenkins_ssm_role.name
}

module "jenkins_master" {
  source = "./modules/jenkins"
  name_prefix = "jenkins"
  ami         = "ami-01ed8ade75d4eee2f" # ubuntu 22.04 LTS
  instance_type = "t2.small"
  subnet_id   = element(module.vpc.public_subnet_ids, 0)
  associate_public_ip_address = true
  vpc_id      = module.vpc.vpc_id
  availability_zone  = "ap-northeast-2b"

  ingress_rules = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # 모든 IP에서 접근 허용
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # 모든 IP에서 접근 허용
    },
    {
      from_port = 1717
      to_port = 1717
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
	
  key_name        = var.key_name
  public_key_path = var.public_key_path
  user_data     = file("script/jenkins_container.sh")
  tags = {
    Name = "Jenkins-Master-instance"
  }
}