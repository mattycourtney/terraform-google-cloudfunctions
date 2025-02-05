

variable "function_name" {
  type        = string
  description = "Function name"
}

variable "cf_src_bucket" {
  type        = string
  description = "Source archive bucket for Cloud Functions"
}

variable "source_dir" {
  type        = string
  description = "Location of source code to deploy, without a leading slash"
  default     = ""
}

variable "entry_point" {
  type        = string
  description = "Name of the function that will be executed when the Google Cloud Function is triggered"
}

variable "trigger_type" {
  type        = string
  description = "Function trigger type that must be provided"

  validation {
    condition     = can(regex("^(http|topic|scheduler|bucket)$", var.trigger_type))
    error_message = "Possible values are: http, topic, scheduler or bucket."
  }
}

variable "trigger_event_type" {
  type        = string
  description = "The type of event to observe. Only for topic and bucket triggered functions"
  default     = ""
}

variable "trigger_event_resource" {
  type        = string
  description = "The name or partial URI of the resource from which to observe events. Only for topic and bucket triggered functions"
  default     = ""
}

variable "project" {
  type        = string
  description = "Google Cloud Platform project id"
}

variable "region" {
  type        = string
  default     = "europe-west6"
  description = "Region for Cloud Functions and accompanying resources"
}

variable "region_app_engine" {
  type        = string
  description = "Region for App Engine (Scheduler). If not provided, defaults to region set above"
  default     = ""
}

variable "runtime" {
  type        = string
  description = "The runtime in which the function is going to run. Eg. 'nodejs10', `nodejs12`, 'python37', 'python38', 'go113'"
}

variable "available_memory_mb" {
  type        = number
  description = "Memory (in MB), available to the function. Default value is 256. Allowed values are: 128, 256, 512, 1024, and 2048"
  default     = "256"
}

variable "timeout" {
  type        = number
  description = "Timeout (in seconds) for the function. Default value is 60 seconds. Cannot be more than 540 seconds"
  default     = 60
}

variable "max_instances" {
  type        = number
  description = "The limit on the maximum number of function instances that may coexist at a given time"
  default     = 0
}

variable "service_account_email" {
  type        = string
  description = "Self-provided service account to run the function with"
}

variable "environment_variables" {
  type        = map(string)
  description = "A set of key/value environment variable pairs to assign to the function"
  default     = {}
}

variable "labels" {
  type        = map(string)
  description = "A set of key/value label pairs to assign to the function"
  default     = {}
}

variable "schedule" {
  type        = string
  description = "Describes the schedule on which the job will be executed"
  default     = "*/30 * * * *"
}

variable "schedule_time_zone" {
  type        = string
  description = "Specifies the time zone to be used in interpreting schedule. The value of this field must be a time zone name from the tz database"
  default     = "UTC"
}

variable "schedule_retry_config" {
  type = object({
    retry_count          = number,
    max_retry_duration   = string,
    min_backoff_duration = string,
    max_backoff_duration = string,
    max_doublings        = number,
  })
  description = "By default, if a job does not complete successfully, meaning that an acknowledgement is not received from the handler, then it will be retried with exponential backoff"
  default = {
    retry_count          = 0,
    max_retry_duration   = "0s",
    min_backoff_duration = "5s",
    max_backoff_duration = "3600s",
    max_doublings        = 5
  }
}

variable "schedule_payload" {
  type        = string
  description = "Payload for Cloud Scheduler"
  default     = "{}"
}

variable "invokers" {
  type        = list(string)
  description = "List of function invokers (i.e. allUsers if you want to Allow unauthenticated)"
  default     = []
}

variable "vpc_access_connector" {
  type        = string
  description = "Enable access to shared VPC 'projects/<host-project>/locations/<region>/connectors/<connector>'"
  default     = null
}

variable "ingress_settings" {
  type        = string
  description = "Restrict whether a function can be invoked by resources outside your Google Cloud project or VPC Service Controls service perimeter"
  default     = "ALLOW_INTERNAL_AND_GCLB"

  validation {
    condition     = can(regex("^(ALLOW_ALL|ALLOW_INTERNAL_AND_GCLB|ALLOW_INTERNAL_ONLY)$", var.ingress_settings))
    error_message = "Possible values are: ALLOW_ALL, ALLOW_INTERNAL_AND_GCLB, ALLOW_INTERNAL_ONLY."
  }
}

locals {
  // Constants
  TRIGGER_TYPE_HTTP      = "http"
  TRIGGER_TYPE_TOPIC     = "topic"
  TRIGGER_TYPE_SCHEDULER = "scheduler"
  TRIGGER_TYPE_BUCKET    = "bucket"

  source_dir        = var.source_dir != "" ? "${path.root}/${var.source_dir}" : path.root
  region_app_engine = var.region_app_engine != "" ? var.region_app_engine : var.region
}
