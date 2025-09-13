@tool
class_name ResponseDto
extends RefCounted

var ok: bool
var response_code: HTTPClient.ResponseCode
var data: Variant
var error: Error

func _init(ok: bool = false, response_code: HTTPClient.ResponseCode = -1, data: Variant = null, error: Error = OK):
	self.ok = ok
	self.response_code = response_code
	self.data = data
	self.error = error
