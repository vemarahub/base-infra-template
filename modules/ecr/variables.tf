variable "name" {
  description = "A unique name to be used (where possible) on the created resources"
  type        = string
}

variable "image_tag_mutability" {
  description = " (Optional) The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to MUTABLE."
  type        = string
  default     = "IMMUTABLE"
}

variable "account_ids" {
  description = "The account ids to whitelist for cross account access."
  type        = list(string)
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository or not scanned. Defaults to true"
  type        = bool
  default     = true
}

variable "encryption_configuration" {
  description = "Encryption used for ecr. Refer https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository#encryption_configuration"
  type = list(object({
    encryption_type = string
    kms_key         = string
  }))
  default = []
}

variable "lifecycle_max_image_count" {
  description = "The number of docker images the ECR lifecycle policy will keep. Default to 25"
  type        = number
  default     = 25
}

variable "lifecycle_tag_status" {
  description = "The tag status of docker images the ECR lifecycle policy will remove, allowed value: Untagged, Any. Defaults to any"
  type        = string
  default     = "any"
}

variable "ecr_tag_prefixes" {
  description = "(Optional) list of image tags to take action on with  lifecycle policy"
  type        = list(string)
  default     = []
}

variable "lifecycle_tagged_image_max_count" {
  description = "The number of tagged docker images the ECR lifecycle policy will keep. Default to 10"
  type        = number
  default     = 10
}


variable "enable_crossaccount_write_access" {
  description = "Indicates whether the account_ids should recieve write acccess to the ECR repository. Default to false"
  type        = bool
  default     = false
}

variable "force_delete" {
  description = "If true, will delete the repository even if it contains images. Defaults to false."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A Key-value mapping of resource tags"
  type        = map(string)
  default     = {}
}
