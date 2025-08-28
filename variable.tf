variable "bucketname" {
  default ="portfolio-bucket-3258765923"
}

variable "domainname" {
  default ="aravindakrishnan.click"
}

variable "subject_alternative_names" {
  default =["aravindakrishnan.click","www.aravindakrishnan.click"]
  
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-south-1"
}
