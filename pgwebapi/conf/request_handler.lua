--
-- request_handler.lua
--

local pgmoon = require("pgmoon")
local encode_json = require("pgmoon.json").encode_json
local url = require("/mnt/pgwebapi/neturl")
local redirected = false

local dbconn_params = {
  host = ngx.var.pgwebapi_conn_host,
  port = ngx.var.pgwebapi_conn_port,
  database = ngx.var.pgwebapi_conn_db,
  user = ngx.var.pgwebapi_conn_user,
  password = ngx.var.pgwebapi_conn_password
}

local args = nil;

if ngx.var.args ~= nil then
  args = url.parseQuery(ngx.var.args)
end

local request = {
  area = ngx.var.pgwebapi_area,
  host = ngx.var.host,
  path = ngx.var.path,
  method = ngx.req.get_method(),
  args = args,
  remote_addr = ngx.var.remote_addr,
  remote_host = ngx.var.rdns_hostname,
  server_host = ngx.var.pgwebapi_server_host,
  server_addr = ngx.var.server_addr,
  headers = ngx.req.get_headers(),
  is_internal = ngx.req.is_internal(),
  resp_headers = ngx.resp.get_headers(),
  status = ngx.var.status,
  body_bytes_sent = ngx.var.body_bytes_sent,
  request_completion = ngx.var.request_completion,
  request_body_file = ngx.var.request_body_file
}

local pg = pgmoon.new(dbconn_params)

assert(pg:connect())

if request.headers["content_type"] ~= nil and string.match(request.headers["content_type"], '^multipart/form%-data;') then
  --this is multipart form data
  if ngx.var.pgwebapi_read_multipart_body ~= nil and ngx.var.pgwebapi_read_multipart_body == 'true' then
    ngx.req.read_body()
  end
else
  ngx.req.read_body()
end

if ngx.var.pgwebapi_conn_host == nil or ngx.var.pgwebapi_conn_host == "false" then
  ngx.req.read_body()
end

local body
if ngx.var.request_body ~= nil then
  body = pg:escape_literal(ngx.var.request_body)
else
  body = "NULL"
end

local json_request = encode_json(request)
local res = assert(pg:query("select * from pgwebapi.api_request("..json_request..","..body..")"))
local row = res[1]
local commands = { }

pg:keepalive(10000, 10)

if row and
   row["status"] ~= pg.null and
   row["body"] ~= pg.null
then
  ngx.status = row["status"]

  if row["headers"] ~= pg.null
  then
    headers = row["headers"]
    if headers ~= nil then
      for key,value in pairs(headers) do
       ngx.header[key] = value
      end
    end
  end

  ngx.print(row["body"])
  ngx.exit(ngx.status)
else
  ngx.exit(500)
end
