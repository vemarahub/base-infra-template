### REQUIRED INPUT ############################################################

variable "tags" {
  description = "A map of tags to assign to the object."
  type        = map(string)
}

variable "alias" {
  description = "The display name of the alias. The word \"alias\" is prepended followed by a forward slash and the value (alias/)"
  type        = string
}

### KMS #######################################################################

variable "description" {
  description = "(Optional) The description of the key as viewed in AWS console."
  type        = string
  default     = null
}

variable "key_usage" {
  description = "(Optional) Specifies the intended use of the key. Valid values: ENCRYPT_DECRYPT or SIGN_VERIFY. Defaults to ENCRYPT_DECRYPT."
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "customer_master_key_spec" {
  description = " (Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT."
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "policy" {
  description = "A valid policy JSON document. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide https://learn.hashicorp.com/terraform/aws/iam-policy."
  type        = string
  default     = null
}

variable "deletion_window_in_days" {
  description = "(Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 10 days."
  type        = number
  default     = 10
}

variable "enable_key_rotation" {
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
  type        = bool
  default     = true
}

variable "is_enabled" {
  description = "Specifies whether the key is enabled"
  type        = bool
  default     = true
}

variable "administrators" {
  description = "List of arns considered key administrators or key roles that have full permissions to manage the CMK. Key admins and roles do not have permissions to use the CMK in cryptographic operations."
  type        = list(any)
  default     = []
}

variable "users" {
  description = "List of users or roles that can use the key to encrypt/decrypt."
  type        = list(any)
  default     = []
}

variable "principals" {
  description = "List of arns that can use the key to encrypt/decrypt."
  type        = list(any)
  default     = []
}
