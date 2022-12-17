-- change filename to scan data (ex. "Dec_12")
filename = "Dec_16"

listings = {"texture", "count", "quality", "canUse", "level",
 	"levelColHeader", "minBid", "minIncrement", "buyoutPrice",
  	"bidAmount", "highBidder", "bidderFullName", "owner",
   	"ownerFullName", "saleStatus", "itemName", "itemLink", "itemRarity", "itemLevel", "itemMinLevel", "itemType", "itemSubType", "itemStackCount", 
         "itemEquipLoc", "itemTexture", "itemSellPrice", "classID", "subclassID", "bindType", "expacID", "setID", "isCraftingReagent"}

current_dir=(io.popen"cd":read'*l'):sub(1, -8):gsub("\\", "/") .. "Data/"

file = io.open(current_dir .. filename .. ".csv", "a")
file:write("name,")
file:write("id,")

cats = ""
for _, category in ipairs(listings) do
	cats = cats .. category .. ","
end
cats = cats:sub(1,-2)
file:write(cats, "\n")


local f = assert(loadfile(current_dir .. filename .. ".lua"))
f()
local fd = assert(loadfile(current_dir .. "item-database" .. ".lua"))
fd()

function flattenRecursive(e, result)
    if type(e) == "table" then
        for k,v in pairs(e) do
            flattenRecursive(v, result)
        end
    else
        table.insert(result, e)
    end
end

function flatten (e)
    local result = {}
    flattenRecursive(e, result)
    return result
end

function isInteger(str)
	return not (str == "" or str:find("%D"))
end

scandate = ""

function csv_gen(tb)
	if type(tb) == 'table' then
		for k,v in pairs(tb) do
			id = -1
			if k == 'scanDate' then
				scandate = v
			else
				for k1,v1 in pairs(v) do
					if k1 == 'id' then
						id = v1
					end
					if type(v1) == 'table' then
						for k2,v2 in pairs(v1) do
							res = ""
							print(k, "listing #", k2, "----------")
							if isInteger(k) then
								res = res .. itemdb[k][1] .. ","
							else 
								res = res .. k .. ","
							end
							res = res .. id .. ","
							for k3,v3 in pairs(flatten(v2)) do
								res = res .. tostring(v3) .. ","
							end
							for k3,v3 in pairs(itemdb[tostring(id)]) do
								res = res .. tostring(v3) .. ","
							end
							res = res:sub(1,-2)
							file:write(res, "\n")
						end
					end
				end
			end
		end
	end
end

csv_gen(lewdb)

file:write(scandate, "\n")

io.close(file)