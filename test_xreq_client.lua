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

require("zmq")
local ev = require'ev'
local zworker = require'zworker'
local loop = ev.Loop.default

local ctx = zmq.init(1)

-- define response handler
function handle_msg(sock, data)
  print("server response: ")
	for i,part in ipairs(data) do
		print(i, part)
	end
end

-- create PAIR worker
local zxreq = zworker.new_xreq(ctx, loop, handle_msg)

zxreq:identity("<xreq>")
zxreq:connect("tcp://localhost:5555")

local function io_in_cb()
	local line = io.read("*l")
	-- send request message.
	zxreq:send({"\0", line})
end
local io_in = ev.IO.new(io_in_cb, 0, ev.READ)
io_in:start(loop)

loop:loop()

