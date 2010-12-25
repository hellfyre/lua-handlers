-- Copyright (c) 2010 by Robert G. Jakabosky <bobby@neoawareness.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

local httpclient = require'handler.http.client'
local ev = require'ev'
local loop = ev.Loop.default
local tremove = table.remove

local client = httpclient.new(loop,{
	user_agent = "HTTPClient tester",
})

local urls = arg
local req
local next_url

local function on_response(req, resp)
	print('---- start response headers: status code =' .. resp.status_code)
	for k,v in pairs(resp.headers) do
		print(k .. ": " .. v)
	end
	print('---- end response headers')
end

local function on_data(req, resp, data)
	print('---- start response body')
	io.write(data)
	print('---- end response body')
end

local function on_finished(req, resp)
	next_url()
end

next_url = function()
	local url = tremove(urls, 1)
	if not url then
		-- finished processing urls
		loop:unloop()
		return
	end
	req = client:request{
		url = url,
		on_response = on_response,
		on_data = on_data,
		on_finished = on_finished,
	}
end

-- start serial request of urls from command line.
next_url()

loop:loop()

