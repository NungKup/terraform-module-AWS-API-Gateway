resource "aws_api_gateway_resource" "default" {
  for_each = var.resource_config

  rest_api_id = lookup(each.value, "rest_api_id", var.api_id)
  parent_id   = lookup(each.value, "parent_id", var.api_parend_id)
  path_part   = lookup(each.value, "path_part", "")
}

resource "aws_api_gateway_resource" "parent_id" {
  for_each = var.enable_parent ? var.resource_parent_config : {}

  rest_api_id = lookup(each.value, "rest_api_id", var.api_id)
  parent_id   = aws_api_gateway_resource.default[lookup(each.value, "parent_id", "")].id
  path_part   = lookup(each.value, "path_part", "")

  depends_on = [aws_api_gateway_resource.default]
}

resource "aws_api_gateway_model" "default" {
  for_each = var.enable_model_count ? var.resource_config : {}

  rest_api_id  = lookup(each.value, "rest_api_id", var.api_id)
  name         = lookup(each.value, "name_model", "")
  description  = lookup(each.value, "description_model", "")
  content_type = lookup(each.value, "content_type_model", "")

  schema = lookup(each.value, "model_schemas", jsonencode({ type = "object" }))
}

module "medthod" {
  source = "../medthod"

  for_each = var.resource_config

  api_id      = var.api_id
  resource_id = aws_api_gateway_resource.default[each.key].id

  http_method          = lookup(each.value, "http_method", "")
  authorization        = lookup(each.value, "authorization", "NONE")
  api_authorizer_id    = lookup(each.value, "authorizer_id", null)
  authorization_scopes = lookup(each.value, "authorization_scopes", null)
  api_key_required     = lookup(each.value, "api_key_required", null)
  request_models       = lookup(each.value, "request_models", { "application/json" = "Empty" })
  request_validator_id = lookup(each.value, "request_validator_id", null)
  request_parameters   = lookup(each.value, "request_parameters", {})

  integration_http_method          = lookup(each.value, "integration_http_method", null)
  integration_type                 = lookup(each.value, "integration_type", "AWS_PROXY")
  integration_connection_type      = lookup(each.value, "integration_connection_type", "INTERNET")
  integration_uri                  = lookup(each.value, "integration_uri", "")
  integration_credentials          = lookup(each.value, "integration_credentials", "")
  integration_request_parameters   = lookup(each.value, "integration_request_parameters", {})
  integration_request_templates    = lookup(each.value, "integration_request_templates", {})
  integration_passthrough_behavior = lookup(each.value, "integration_passthrough_behavior", null)
  integration_cache_key_parameters = lookup(each.value, "integration_cache_key_parameters", [])
  integration_cache_namespace      = lookup(each.value, "integration_cache_namespace", aws_api_gateway_resource.default[each.key].id)
  integration_content_handling     = lookup(each.value, "integration_content_handling", null)
  integration_timeout_milliseconds = lookup(each.value, "integration_timeout_milliseconds", 9000)

  status_code                = lookup(each.value, "status_code", null)
  method_response_models     = lookup(each.value, "method_response_models", {})
  method_response_parameters = lookup(each.value, "method_response_parameters", {})

  selection_pattern               = lookup(each.value, "selection_pattern", null)
  integration_response_parameters = lookup(each.value, "integration_response_parameters", {})
  integration_response_templates  = lookup(each.value, "integration_response_templates", { "application/json" = "" })

  vpc_link = var.vpc_link

  depends_on = [aws_api_gateway_resource.default]
}

# module "medthod_parent" {
#   source = "../medthod"

#   for_each = var.enable_parent ? var.resource_parent_config : {}

#   api_id      = var.api_id
#   resource_id = aws_api_gateway_resource.parent_id[each.key].id

# request_config  = lookup(each.value, "request_config", {})  #var.request_config
#   response_config = lookup(each.value, "response_config", {}) #var.response_config

#   depends_on = [aws_api_gateway_resource.default]
# }
