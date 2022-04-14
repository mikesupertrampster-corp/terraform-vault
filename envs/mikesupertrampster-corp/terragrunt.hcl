generate "backend" {
  path      = "config.tf"
  if_exists = "overwrite_terragrunt"
  contents  = templatefile("../../_files/template/config.tf", {
    organization = basename(get_parent_terragrunt_dir())
    workspace_name = "terraform-vault-${replace(path_relative_to_include(), "/(\\.|/)/", "-")}"
  })
}

inputs = {
  apex_domain    = "mikesupertrampster.com."
  keypair        = "cardno:9"
  bootstrap_role = "TerraformAdminRole"
  region         = "eu-west-1"
  tags           = { Managed_By = "Terraform" }
}