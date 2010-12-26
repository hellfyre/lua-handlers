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

local print = print
local setmetatable = setmetatable
local assert = assert
local io = io
local tconcat = table.concat
local ltn12 = require'ltn12'

local file_mt = { is_content_object = true, object_type = 'file' }
file_mt.__index = file_mt

function file_mt:get_content_type()
	return "application/octet-stream"
end

function file_mt:get_content_length()
	local file = self.file
	local cur = file:seek()
	local size = file:seek('end')
	file:seek('set', cur)
	return size
end

function file_mt:get_source()
	return self.src
end

function file_mt:get_content()
	local data = {}
	local src = self:get_source()
	local sink = ltn12.sink.table(data)
	ltn12.pump.all(src, sink)
	return tconcat(data)
end

module'handler.http.file'

function new(filename)
	local file = io.open(filename)
	local size = file:seek('end')
	file:seek('set', 0)
	local self = {
		filename = filename,
		file = file,
		size = size,
		src = ltn12.source.file(file)
	}
	return setmetatable(self, file_mt)
end
