local LazyHeader = class("LazyHeader",function()
    return require("Header").create()
end)

local struct = require("struct")

function LazyHeader.create(__type)
    local lazyHeader = LazyHeader.new()
    return lazyHeader
end

function LazyHeader:ctor()
    self.bfmt = ""
    self.params_name = {}    
    return
end

function LazyHeader:append_param(__self, __pname, __pvalue, __ptype)
end


function LazyHeader:imarshal()
end

   
function LazyHeader:iunmarshal(record)
end

return LazyHeader