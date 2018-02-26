local a = {}
local to_json = require("cjson").encode
local template = require("resty.template")

function a.run(params)
	local res_ds = {}
	local cdate = ngx.utctime()
	local req_headers = ngx.req.get_headers()
	res_ds.date = cdate:gsub(" ","T")..".000Z"
	res_ds.unread_smss = {}
	if type(params.res) == "table" then
		ngx.req.set_header("Content-Type", "application/json")
		for key,val in pairs(params.res) do
			if (val.id) then
				table.insert(res_ds.unread_smss, {
					sms_id = val.id,
					sending_date = type(val["fetch-datetime"]) == "string" and tostring(val["fetch-datetime"]):gsub(" ","T")..".000Z" or cdate:gsub(" ","T")..".000Z",
					sender = val["in-from"],
					sms_text = val["in-text"]
				})
				if not (type(val["fetch-datetime"]) == "string") then
					local opts = {
						method = ngx.HTTP_PUT,
						body = to_json({
							["fetch-datetime"] = cdate
						})
					}
					ngx.req.read_body()
					local res = ngx.location.capture("/api/sms-list/"..val.id, opts)
				end
			end
		end
	end
	if not req_headers["accept"]
	   or not req_headers["accept"]:match("application/json") then
		res_ds = template.compile("fetch-template.xml")(res_ds)
		ngx.header["Content-Type"] = "text/xml"
	else
		ngx.header["Content-Type"] = "application/json"
	end
	return res_ds
end

return a
