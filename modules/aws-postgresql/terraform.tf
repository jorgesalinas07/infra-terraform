
terraform {
  required_version = ">= 1.5"
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">=1.21"
    }
  }
}

########################################################################
# Constants
########################################################################

locals {
  administrative_database = "admindb"
}

########################################################################
# Calculated values
########################################################################

locals {
  service_identifier = "${var.service_name}-${var.environment}-${var.aws_region}"
}
