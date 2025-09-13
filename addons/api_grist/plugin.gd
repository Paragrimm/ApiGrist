@tool
class_name GristPlugin
extends EditorPlugin
## API Grist
##
## Plugin script and entrypoint for the Grist API integration

const SETTING_PATH_BASE: String = "apis/grist"
const SETTING_PATH_URL: String = "/url"
const SETTING_PATH_API_KEY: String = "/api_key"
	
static func get_setting_string(path: String) -> String:
	return "%s%s" % [SETTING_PATH_BASE, path]

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	ProjectSettings.set_setting(get_setting_string(SETTING_PATH_URL), "")
	ProjectSettings.set_setting(get_setting_string(SETTING_PATH_API_KEY), "")


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	ProjectSettings.set_setting(get_setting_string(SETTING_PATH_URL), null)
	ProjectSettings.set_setting(get_setting_string(SETTING_PATH_API_KEY), null)
