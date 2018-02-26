local REST = require("rest-processor")
local cst = require("smsservices_constants")
REST.init(cst)

local to_json = require("cjson").encode

local api_respond_table = {
	GET = REST.api_get,
	PUT = REST.api_put,
	POST = REST.api_post,
	DELETE = REST.api_delete,
	HEAD = REST.api_head
}

function set_log_variables(self)
	ngx.var.api_call = self.req.parsed_url.path
	ngx.var.api_params = to_json(self.params)
end

local app = {}
app.params = ngx.req.get_uri_args(cst.http.max_args)
app.params.splat = string.sub(ngx.var.uri, string.len(cst.rest_api.base_path) + 2)
app.method = ngx.req.get_method()
if api_respond_table[app.method] then
	app.result = api_respond_table[app.method](app)
end
