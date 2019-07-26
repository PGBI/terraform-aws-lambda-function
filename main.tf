terraform {
  required_version = ">= 0.12"
}

provider "archive" {
  version = "~> 1.2"
}

/**
 * Log group the lambda function will ship its logs to.
 */
module "log_group" {
  source  = "PGBI/cloudwatch-log-group/aws"
  version = "~>0.1.0"

  name              = "/aws/lambda/${var.project.name_prefix}-${var.name}"
  no_name_prefix    = true
  retention_in_days = var.logs_retention_in_days
  project           = var.project
}

/**
 * Role assumed by the lambda function.
 */
module "role" {
  source  = "PGBI/iam-role/aws"
  version = "~>0.1.0"

  description = "Role assumed by the lambda function \"${var.project.name_prefix}-${var.name}\"."
  name        = "${var.name}-lambda"
  project     = var.project

  trusted_services = ["lambda.amazonaws.com"]
}

module "role_policy" {
  source  = "PGBI/iam-role-policy/aws"
  version = "~>0.1.0"

  name      = "manage_logs"
  role_name = module.role.name
  statements = [{
    actions   = ["logs:DescribeLogGroups"]
    resources = ["arn:aws:logs:*:${var.project.account_id}:*"]
    effect    = "Allow"
    }, {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [module.log_group.arn]
    effect    = "Allow"
    }
  ]
}

/**
 * Zipping the lambda source code.
 */
data "archive_file" "lambda_source" {
  type        = "zip"
  source_dir  = var.src_path
  output_path = "/tmp/${md5(var.src_path)}.zip"
}

/**
 * The lambda function
 */
resource "aws_lambda_function" "main" {
  function_name    = "${var.project.name_prefix}-${var.name}"
  description      = var.description
  handler          = "main.handler"
  role             = module.role.arn
  runtime          = var.runtime
  memory_size      = var.memory_size
  timeout          = var.timeout
  filename         = data.archive_file.lambda_source.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_source.output_path)

  environment {
    variables = var.env_vars
  }

  tags = var.project.tags
}
