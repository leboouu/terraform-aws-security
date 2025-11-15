resource "prismacloud_policy" "example" {
  name        = "Example Policy"
  policy_type = "config"
  description = "An example policy for demonstration"
  severity    = "high"
  cloud_type  = "aws"
  labels      = ["example"]
  enabled     = true

  rule {
    name      = "Example Rule"
    rule_type = "Config"
    criteria  = "config from cloud.resource where api.name = 'aws-ec2-describe-instances'"
    parameters = {
      "savedSearch" = "false"
    }
  }

  compliance_metadata {
    compliance_id = "CIS-1.4.0-1.1"
  }
}
