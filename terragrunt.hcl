include {
  path = find_in_parent_folders()
}

locals {

} 

dependency {
    
}

terraform {

}

# Configure input values for the specific environment being deployed:
inputs = {
  {CHANGEME - application_name}_tags = {} # additional tags for all application folder specific resources, if needed.
  region = "eu-west-1"
  environment = "dev"s3_endpoint = "com.amazonaws.${local.aws_region}.s3"

}

dependencies {
  paths = ["/lab/", "/lab/terraform/", "/lab/terraform/"]
}

### Formatting hcl files

## root
##     ## ADMIN
## ├── terragrunt.hcl
## ├── prod-blue= ~/terraform
## │   └── terragrunt.hcl
## ├── prod-green= ~/terraform
## │   └── terragrunt.hcl
## ├── prod-users= ~/terraform
## │   └── terragrunt.hcl

## │   ## CI
## ├── dev-testing= ~/lab
## │── dev-staging= ~/lab
## │   └── terragrunt.hcl
## │   ## CD
## └── qa ~/.
## │    ├── terragrunt.hcl
## │    └── services
## │        ├── services.hcl
## │        └── service
## │            └── terragrunt.hcl
## │
## │   