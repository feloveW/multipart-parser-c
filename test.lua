local parser = require "multipart.parser"
local pdump = require "util".pdump

local function parse_form()
    local f = assert(io.open("body", "rb"))
    local body = f:read("a")
    --pdump(body, "body")
    local boundary = "G9nTaTHJiTdCLkMZyf2lNWhvfybTfISXkGECxbAU"
    local form = parser.parse(boundary, body)
    for _, partdata in ipairs(form) do
        partdata.data = nil
    end
    pdump(form, "form headers")
end

parse_form()
