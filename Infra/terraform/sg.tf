
resource "aws_security_group" "test" {
  name        = "init-sg"
  description = "Security group for initializing."

  tags = {
    Name = "dev-sg"
  }
}

resource "aws_security_group" "stage" {
  name        = "Stage-sg"
  description = "Security group for Jenkins and staging applications."

  tags = {
    Name = "Stage-sg"
  }
}

resource "aws_security_group" "deploy" {
  name        = "deploy-sg"
  description = "Security group for Deployment machine"

  tags = {
    Name = "Deploy-sg"
  }
}


resource "aws_vpc_security_group_ingress_rule" "SSH-test" {
  security_group_id = aws_security_group.test.id
  cidr_ipv4         = "${chomp(data.http.my_ip.response_body)}/32"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "SSH-Stage" {
  security_group_id = aws_security_group.stage.id
  cidr_ipv4         = "${chomp(data.http.my_ip.response_body)}/32"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "jenkins-stage" {
  security_group_id = aws_security_group.stage.id
  cidr_ipv4         = "${chomp(data.http.my_ip.response_body)}/32"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "sq-stage" {
  security_group_id = aws_security_group.stage.id
  cidr_ipv4         = "${chomp(data.http.my_ip.response_body)}/32"
  ip_protocol       = "tcp"
  from_port         = 9000
  to_port           = 9000
}

resource "aws_vpc_security_group_ingress_rule" "test-to-stage" {
  security_group_id            = aws_security_group.stage.id
  referenced_security_group_id = aws_security_group.test.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "SSH-deploy" {
  security_group_id = aws_security_group.deploy.id
  cidr_ipv4         = "${chomp(data.http.my_ip.response_body)}/32"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "test-to-deploy" {
  security_group_id            = aws_security_group.deploy.id
  referenced_security_group_id = aws_security_group.test.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "stage-to-deploy" {
  security_group_id            = aws_security_group.deploy.id
  referenced_security_group_id = aws_security_group.stage.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
}


resource "aws_vpc_security_group_ingress_rule" "deploy_from_my_ip" {
  security_group_id = aws_security_group.deploy.id
  cidr_ipv4         = "${chomp(data.http.my_ip.response_body)}/32"
  ip_protocol       = "tcp"
  from_port         = 3000
  to_port           = 3000
}

resource "aws_vpc_security_group_egress_rule" "test-out" {
  security_group_id = aws_security_group.test.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_vpc_security_group_egress_rule" "stage-out" {
  security_group_id = aws_security_group.stage.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "deploy-out" {
  security_group_id = aws_security_group.deploy.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
