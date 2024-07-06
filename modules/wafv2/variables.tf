variable "waf_prefix" {
  type    = string
  default = "example-cloudfront" # WAF prefix 이름 설정
}

variable "waf_ip_sets" {
  type    = list(string)
  default = ["0.0.0.0/1", "128.0.0.0/1"] # 모든 IP 주소 허용
}

variable "ip_sets_rule" {
  type = list(object({
    name           = string
    priority       = number
    ip_set_arn     = string
    action         = string
  }))
  description = "특정 IP 주소 또는 주소 범위에서 오는 웹 요청을 탐지하기 위한 규칙."
  default     = []
}

variable "managed_rules" {
  description = "AWS 관리형 WAF 규칙 목록."
  type        = list(object({
    name            = string
    priority        = number
    override_action = string
    excluded_rules  = list(string)
  }))
  default = [
    {
      name            = "AWSManagedRulesAdminProtectionRuleSet"
      priority        = 10
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesAmazonIpReputationList"
      priority        = 20
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesSQLiRuleSet"
      priority        = 30
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesKnownBadInputsRuleSet"
      priority        = 40
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesCommonRuleSet"
      priority        = 50
      override_action = "none"
      excluded_rules  = []
    }
  ]
}
