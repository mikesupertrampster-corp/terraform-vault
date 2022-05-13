# Terraform Vault

Terraform deployment of Vault

[![Snyk Infrastructure as Code](https://github.com/mikesupertrampster-corp/terraform-vault/actions/workflows/snyk.yml/badge.svg)](https://github.com/mikesupertrampster-corp/terraform-vault/actions/workflows/snyk.yml) [![gitleaks](https://github.com/mikesupertrampster-corp/terraform-vault/actions/workflows/gitleaks.yml/badge.svg)](https://github.com/mikesupertrampster-corp/terraform-vault/actions/workflows/gitleaks.yml) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/85e70afe586946b285823cac036079a5)](https://www.codacy.com/gh/mikesupertrampster-corp/terraform-vault/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=mikesupertrampster-corp/terraform-vault&amp;utm_campaign=Badge_Grade) [![Infracost estimate](https://img.shields.io/badge/Infracost-estimate-5e3f62)](https://dashboard.infracost.io/share/bxd4p24q8wwmti3sjar8rx1ia4pw6zlr)

## Resources

   * ECS Task
   * Load Balancer Target Group
   * Dynamo DB
   * KMS Key

## Cost

Estimate cost generated using [Infracost](https://github.com/Infracost/infracost)

```
 Name                                                   Monthly Qty  Unit                    Monthly Cost 
                                                                                                          
 module.vault.aws_cloudwatch_log_group.vault                                                              
 ├─ Data ingested                                 Monthly cost depends on usage: $0.57 per GB             
 ├─ Archival Storage                              Monthly cost depends on usage: $0.03 per GB             
 └─ Insights queries data scanned                 Monthly cost depends on usage: $0.0057 per GB           
                                                                                                          
 module.vault.aws_dynamodb_table.vault                                                                    
 ├─ Write request unit (WRU)                      Monthly cost depends on usage: $0.0000014135 per WRUs   
 ├─ Read request unit (RRU)                       Monthly cost depends on usage: $0.000000283 per RRUs    
 ├─ Data storage                                  Monthly cost depends on usage: $0.28 per GB             
 ├─ Point-In-Time Recovery (PITR) backup storage  Monthly cost depends on usage: $0.22 per GB             
 ├─ On-demand backup storage                      Monthly cost depends on usage: $0.11 per GB             
 ├─ Table data restored                           Monthly cost depends on usage: $0.17 per GB             
 └─ Streams read request unit (sRRU)              Monthly cost depends on usage: $0.000000226 per sRRUs   
                                                                                                          
 module.vault.aws_ecs_service.vault                                                                       
 ├─ Per GB per hour                                             0.5  GB                             $1.62 
 └─ Per vCPU per hour                                          0.25  CPU                            $7.39 
                                                                                                          
 module.vault.aws_kms_key.vault                                                                           
 ├─ Customer master key                                           1  months                         $1.00 
 ├─ Requests                                      Monthly cost depends on usage: $0.03 per 10k requests   
 ├─ ECC GenerateDataKeyPair requests              Monthly cost depends on usage: $0.10 per 10k requests   
 └─ RSA GenerateDataKeyPair requests              Monthly cost depends on usage: $0.10 per 10k requests   
                                                                                                          
 module.vault.aws_route53_record.vault                                                                    
 ├─ Standard queries (first 1B)                   Monthly cost depends on usage: $0.40 per 1M queries     
 ├─ Latency based routing queries (first 1B)      Monthly cost depends on usage: $0.60 per 1M queries     
 └─ Geo DNS queries (first 1B)                    Monthly cost depends on usage: $0.70 per 1M queries     
                                                                                                          
 OVERALL TOTAL                                                                                     $10.01 
──────────────────────────────────
16 cloud resources were detected:
∙ 5 were estimated, 3 of which include usage-based costs, see https://infracost.io/usage-file
∙ 11 were free:
  ∙ 2 x aws_iam_role
  ∙ 2 x aws_security_group_rule
  ∙ 1 x aws_ecs_task_definition
  ∙ 1 x aws_iam_role_policy
  ∙ 1 x aws_iam_role_policy_attachment
  ∙ 1 x aws_kms_alias
  ∙ 1 x aws_lb_listener_rule
  ∙ 1 x aws_lb_target_group
  ∙ 1 x aws_security_group
```