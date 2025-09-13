@tool
class_name GristClient
extends RefCounted
## Grist Client
##
## Client that talks to the Grist API
## https://getgrist.com
## API Console: {base_url}/apiconsole (for example: https://docs.getgrist.com/apiconsole)

var base_url: String
var api_key: String:
	set(value):
		api_key = value
		headers = [
			"Authorization: Bearer %s" % api_key,
			"Content-Type: application/json"
		]
var headers: Array[String] = []
var http_request: HTTPRequest

func _init(node: Node, base_url: String = "", api_key: String = "") -> void:
	base_url = base_url if not base_url.is_empty() else ProjectSettings.get_setting(GristPlugin.get_setting_string(GristPlugin.SETTING_PATH_URL))
	api_key = api_key if not api_key.is_empty() else ProjectSettings.get_setting(GristPlugin.get_setting_string(GristPlugin.SETTING_PATH_API_KEY))
	self.base_url = base_url.trim_suffix("/")
	if self.base_url.is_empty():
		print("Please set the base url to the Grist instance in the project settings: %s" % GristPlugin.get_setting_string(GristPlugin.SETTING_PATH_URL))
		return
	self.api_key = api_key
	if self.api_key.is_empty():
		print("Please set the API key for Grist in the project settings: %s" % GristPlugin.get_setting_string(GristPlugin.SETTING_PATH_API_KEY))
		return
	self.http_request = HTTPRequest.new()
	node.add_child(http_request)

func request(
	endpoint: String,
	method: HTTPClient.Method = HTTPClient.METHOD_GET,
	body: Dictionary = {},
	query: Dictionary = {}
) -> ResponseDto:
	var response_dto := ResponseDto.new()
	if not self.http_request: return response_dto
	var query_string := _get_query_string(query)
	var url := _get_full_url(base_url, endpoint, query_string)
	var json_body := JSON.stringify(body) if body.size() > 0 else ""

	response_dto.error = http_request.request(url, headers, method, json_body)
	if response_dto.error != OK:
		return response_dto

	var result = await http_request.request_completed
	response_dto.response_code = result[1]
	
	var response_body: PackedByteArray = result[3]
	var text := response_body.get_string_from_utf8()

	if not text.is_empty():
		response_dto.data = JSON.parse_string(text)
	response_dto.ok = response_dto.response_code >= 200 and response_dto.response_code < 300
	return response_dto

## ==========
## LIBRARY
## ==========

## Orgs
func get_orgs() -> ResponseDto:
	return await request("/api/orgs", HTTPClient.METHOD_GET)

func get_org(org_id: String) -> ResponseDto:
	return await request("/api/orgs/%s" % org_id, HTTPClient.METHOD_GET)

func patch_org(org_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/orgs/%s" % org_id, HTTPClient.METHOD_PATCH)

func delete_org(org_id: String) -> ResponseDto:
	return await request("/api/orgs/%s" % org_id, HTTPClient.METHOD_DELETE)

func get_org_access(org_id: String) -> ResponseDto:
	return await request("/api/orgs/%s/access" % org_id, HTTPClient.METHOD_GET)

func patch_org_access(org_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/orgs/%s/access" % org_id, HTTPClient.METHOD_PATCH)

## Workspaces
func get_org_workspaces(org_id: String) -> ResponseDto:
	return await request("/api/orgs/%s/workspaces" % org_id, HTTPClient.METHOD_GET)

func post_org_workspace(org_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/orgs/%s/workspaces" % org_id, HTTPClient.METHOD_POST, body)

func get_workspace(workspace_id: String) -> ResponseDto:
	return await request("/api/workspaces/%s" % workspace_id, HTTPClient.METHOD_GET)

func patch_workspace(workspace_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/workspaces/%s" % workspace_id, HTTPClient.METHOD_PATCH)

func delete_workspace(workspace_id: String) -> ResponseDto:
	return await request("/api/workspaces/%s" % workspace_id, HTTPClient.METHOD_DELETE)

func get_workspace_access(workspace_id: String) -> ResponseDto:
	return await request("/api/workspaces/%s/access" % workspace_id, HTTPClient.METHOD_GET)

func patch_workspace_access(workspace_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/workspaces/%s/access" % workspace_id, HTTPClient.METHOD_PATCH)

## Docs
func post_workspace_doc(workspace_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/workspaces/%s/docs" % workspace_id, HTTPClient.METHOD_POST)

func post_workspace_import(workspace_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/workspaces/%s/import" % workspace_id, HTTPClient.METHOD_POST)

func get_doc(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s" % doc_id, HTTPClient.METHOD_GET)

func patch_doc(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s" % doc_id, HTTPClient.METHOD_PATCH)

func delete_doc(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s" % doc_id, HTTPClient.METHOD_DELETE)

func patch_doc_move(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/move" % doc_id, HTTPClient.METHOD_PATCH)

func post_doc_copy(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/copy" % doc_id, HTTPClient.METHOD_POST)

func get_doc_access(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/access" % doc_id, HTTPClient.METHOD_GET)

func patch_doc_access(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/access" % doc_id, HTTPClient.METHOD_PATCH)

func get_doc_download(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/download" % doc_id, HTTPClient.METHOD_GET)

func get_doc_download_xlsx(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/download/xlsx" % doc_id, HTTPClient.METHOD_GET)

func get_doc_download_csv(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/download/csv" % doc_id, HTTPClient.METHOD_GET)

func get_doc_download_table_schema(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/download/table-schema" % doc_id, HTTPClient.METHOD_GET)

func post_doc_states_remove(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/states/remove" % doc_id, HTTPClient.METHOD_POST)

func post_doc_force_reload(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/force-reload" % doc_id, HTTPClient.METHOD_POST)

func post_doc_recover(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/recover" % doc_id, HTTPClient.METHOD_POST)

## Records
func get_records(doc_id: String, table_id: String) -> ResponseDto:
	return await request("/api/docs/%s/tables/%s/records" % [doc_id, table_id], HTTPClient.METHOD_GET)

func post_record(doc_id: String, table_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/tables/%s/records" % [doc_id, table_id], HTTPClient.METHOD_POST, body)

func patch_record(doc_id: String, table_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/tables/%s/records" % [doc_id, table_id], HTTPClient.METHOD_PATCH, body)

func put_record(doc_id: String, table_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/tables/%s/records" % [doc_id, table_id], HTTPClient.METHOD_PUT, body)

## Tables
func get_tables(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/tables" % doc_id, HTTPClient.METHOD_GET)

func post_tables(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/tables" % doc_id, HTTPClient.METHOD_POST, body)

func patch_tables(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/tables" % doc_id, HTTPClient.METHOD_PATCH, body)

## Columns
func get_columns(doc_id: String, table_id: String) -> ResponseDto:
	return await request("/api/docs/%s/tables/%s/columns" % [doc_id, table_id], HTTPClient.METHOD_GET)

func post_columns(doc_id: String, table_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/tables/%s/columns" % [doc_id, table_id], HTTPClient.METHOD_POST, body)

func patch_columns(doc_id: String, table_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/tables/%s/columns" % [doc_id, table_id], HTTPClient.METHOD_PATCH, body)

func put_columns(doc_id: String, table_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/tables/%s/columns" % [doc_id, table_id], HTTPClient.METHOD_PUT, body)

func delete_column(doc_id: String, table_id: String, col_id: String) -> ResponseDto:
	return await request("/api/docs/%s/tables/%s/columns/%s" % [doc_id, table_id, col_id], HTTPClient.METHOD_DELETE)

## Attachments
func get_attachments(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/attachments" % doc_id, HTTPClient.METHOD_GET)

func post_attachments(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/attachments" % doc_id, HTTPClient.METHOD_POST, body)

func get_attachment(doc_id: String, attachment_id: String) -> ResponseDto:
	return await request("/api/docs/%s/attachments/%s" % [doc_id, attachment_id], HTTPClient.METHOD_GET)

func get_attachment_download(doc_id: String, attachment_id: String) -> ResponseDto:
	return await request("/api/docs/%s/attachments/%s/download" % [doc_id, attachment_id], HTTPClient.METHOD_GET)

func get_attachments_archive(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/attachments/archive" % doc_id, HTTPClient.METHOD_GET)

func post_attachments_archive(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/attachments/archive" % doc_id, HTTPClient.METHOD_POST, body)

func get_attachments_store(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/attachments/store" % doc_id, HTTPClient.METHOD_GET)

func post_attachments_store(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/attachments/store" % doc_id, HTTPClient.METHOD_POST, body)

func get_attachments_stores(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/attachments/stores" % doc_id, HTTPClient.METHOD_GET)

func post_attachments_transfer_all(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/attachments/transferAll" % doc_id, HTTPClient.METHOD_POST, body)

func get_attachments_transfer_status(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/attachments/transferStatus" % doc_id, HTTPClient.METHOD_GET)

func post_attachments_remove_unused(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/attachments/removeUnused" % doc_id, HTTPClient.METHOD_POST, body)

## Webhooks
func get_webhooks(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/webhooks" % doc_id, HTTPClient.METHOD_GET)

func post_webhooks(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/webhooks" % doc_id, HTTPClient.METHOD_POST, body)

func patch_webhooks(doc_id: String, webhook_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/webhooks/%s" % [doc_id, webhook_id], HTTPClient.METHOD_PATCH, body)

func delete_webhook(doc_id: String, webhook_id: String) -> ResponseDto:
	return await request("/api/docs/%s/webhooks/%s" % [doc_id, webhook_id], HTTPClient.METHOD_DELETE)

func delete_webhooks_queue(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/webhooks/queue" % doc_id, HTTPClient.METHOD_DELETE)

## SQL
func get_sql(doc_id: String) -> ResponseDto:
	return await request("/api/docs/%s/sql" % doc_id, HTTPClient.METHOD_GET)

func post_sql(doc_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/docs/%s/sql" % doc_id, HTTPClient.METHOD_POST, body)

## Users
func delete_user(user_id: String) -> ResponseDto:
	return await request("/api/users/%s" % user_id, HTTPClient.METHOD_DELETE)

## SCIM
func get_scim_users() -> ResponseDto:
	return await request("/api/scim/v2/Users", HTTPClient.METHOD_GET)

func post_scim_user(body: Dictionary) -> ResponseDto:
	return await request("/api/scim/v2/Users", HTTPClient.METHOD_POST, body)

func get_scim_user(user_id: String) -> ResponseDto:
	return await request("/api/scim/v2/Users/%s" % user_id, HTTPClient.METHOD_GET)

func put_scim_user(user_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/scim/v2/Users/%s" % user_id, HTTPClient.METHOD_PUT, body)

func patch_scim_user(user_id: String, body: Dictionary) -> ResponseDto:
	return await request("/api/scim/v2/Users/%s" % user_id, HTTPClient.METHOD_PATCH, body)

func delete_scim_user(user_id: String) -> ResponseDto:
	return await request("/api/scim/v2/Users/%s" % user_id, HTTPClient.METHOD_DELETE)

func post_scim_search(body: Dictionary) -> ResponseDto:
	return await request("/api/scim/v2/Users/.search", HTTPClient.METHOD_POST, body)

func get_scim_me() -> ResponseDto:
	return await request("/api/scim/v2/Me", HTTPClient.METHOD_GET)

func post_scim_bulk(body: Dictionary) -> ResponseDto:
	return await request("/api/scim/v2/Bulk", HTTPClient.METHOD_POST, body)

func get_scim_schemas() -> ResponseDto:
	return await request("/api/scim/v2/Schemas", HTTPClient.METHOD_GET)

func get_scim_service_provider_config() -> ResponseDto:
	return await request("/api/scim/v2/ServiceProviderConfig", HTTPClient.METHOD_GET)

func get_scim_resource_types() -> ResponseDto:
	return await request("/api/scim/v2/ResourceTypes", HTTPClient.METHOD_GET)

# Private Functions
func _get_query_string(query: Dictionary) -> String:
	var query_string := ""
	if query.size() > 0:
		for key in query.keys():
			var char: String = "?"
			if query_string.is_empty():
				query_string += char.join([str(key) + "=" + str(query[key])])
				char = "&"
			else:
				query_string += char.join([str(key) + "=" + str(query[key])])
	return query_string

func _get_full_url(base_url: String, endpoint: String, query_string: String) -> String:
	return base_url + endpoint + query_string
