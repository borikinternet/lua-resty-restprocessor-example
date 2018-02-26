local cst = {
	http = {
		max_args = 50
	},
	redis = {},
	mysql = {
		host = "127.0.0.1",
		port = 3306,
		database = "smsservices",
		charset = "utf8",
		max_packet_size = 1024 * 1024,
		user = "smsservices",
		password  = "***"
	},
	defaults = {
		--results_per_page = 10
	}
}

cst.rest_api = {
	base_path = "/api",
	entities = {
		subscribers = {
			table = "subscribers",
			key = "username",
			sort_field = "surname",
			driver = "mysql",
			GET = true,
			HEAD = true,
			fields = {
				id_subscriber = "id",
				surname = "surname",
				name = "name",
				us_did = "did",
				us_msisdn = "msisdn",
				email = "email",
				username = "username",
				auth_key = "key",
				access_token = "token",
				["password"] = "sub-password",
				fwd_in_sms = "forward"
			},
			subroutes = {
				["sms-list"] = {
					method = {
						GET = true
					},
					parent_field = "id_subscriber",
					key_table = "sms_list",
					primary_key = "id_sms",
					parent_key = "id_subscriber",
					sort_field = "in_datetime",
					native_fields = {}
				},
				tokens = {
					method = {
						GET = true,
						POST = true
					},
					parent_field = "id_subscriber",
					key_table = "tokens",
					primary_key = "token_id",
					parent_key = "id_subscriber",
					sort_field = "token_id",
					native_fields = {}
				}
			}
		},
		["sms-fetch"] = {
			driver = "list",
			GET = true,
			POST = true,
			fields = {
				["username"] = "username",
				["last-timestamp"] = "last-timestamp"
			},
			list = {
				{
					uri = "/api/subscribers/:username/sms-list?isnull_fetch-datetime",
					method = "GET",
					fields = {},
					append_results = true
				},
				{
					uri = "/api/subscribers/:username/sms-list",
					method = "GET",
					fields = {
						["g_fetch-datetime"] = "last-timestamp"
					},
					append_results = true
				},
				{
					uri = "/api/sms-fetch-processing",
					method = "POST",
					fields = {},
				}
			}
		},
		["sms-fetch-processing"] = {
			driver = "lua",
			POST = true,
			script = "/var/www/smsservices-api/sms-fetch-processing",
			fields = {
				username = "username",
				["last-timestamp"] = "last-timestamp",
				sms_text = "sms_text",
				sending_date = "sending_date",
				sms_id = "sms_id",
				sender = "sender"
			}
		},
		['sms-notify'] = {
			driver = "lua",
			POST = true,
			GET = true,
			script = "/var/www/smsservices-api/sms-notify",
			fields = {
				username = "username"
			}
		},
		["sms-list"] = {
			table = "sms_list",
			key = "id_sms",
			sort_field = "in_datetime",
			driver = "mysql",
			GET = true,
			HEAD = true,
			PUT = true,
			fields = {
				id_sms = "id",
				id_subscriber = "subscriber-id",
				sms_type = "type",
				in_datetime = "in-datetime",
				in_from_number = "in-from",
				in_to_number = "in-to",
				in_text = "in-text",
				in_vendor = "in-vendor",
				out_datetime = "out-datetime",
				out_from_number = "out-from",
				out_to_number = "out-to",
				out_text = "out-text",
				out_vendor = "out-vendor",
				out_status_code = "delivery-status",
				fetch_datetime = "fetch-datetime"
			}
		},
		tokens = {
			table = "tokens",
			key = "token_id",
			sort_field = "id_subscriber",
			driver = "mysql",
			GET = true,
			HEAD = true,
			POST = true,
			fields = {
				token_id = "id",
				selector = "push-selector",
				token = "push-token",
				id_subscriber = "subscriber-id",
				app_id = "appid"
			},
			update_on_dup = true
		},
		countries = {
			table = "countries",
			key = "id_country",
			sort_field = "country_name",
			driver = "mysql",
			fields = {
				id_country = "id",
				country_ISO = "iso",
				country_code = "code",
				country_name = "name"
			},
			GET = true,
			HEAD = true
		},
		dids = {
			table = "did_list",
			key = "id_did",
			sort_field = "did",
			driver = "mysql",
			fields = {
				id_did = "id",
				id_subscriber = "subscriber-id",
				did = "did",
				id_country = "country-id",
				country_iso = "country",
				did_vendor = "vendor",
				status = "status",
				datetime_status_change = "status-change-time"
			},
			GET = true,
			HEAD = true
		},
		phonebook = {
			table = "phone_book",
			key = "id_phonebook",
			sort_field = "surname",
			driver = "mysql",
			GET = true,
			HEAD = true,
			fields = {
				id_phonebook = "id",
				id_subscriber = "subscriber-id",
				surname = "surname",
				name = "name",
				number = "number"
			}
		},
	}
}

return cst
