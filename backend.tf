# The block below configures Terraform to use the 'remote' backend with Terraform Cloud.
# For more information, see https://www.terraform.io/docs/backends/types/remote.html
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Ranyart"

    workspaces {
      name = "tfc-guide-example"
    }
  }

  required_version = ">= 0.13.0"
}
