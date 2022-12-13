scan_date = date("%m/%d/%y %H:%M:%S");
lewdb = {};
message("I'm on goober watch, and my radars are going off!");

dothingy = false;

SLASH_LEWAH1 = "/lah";
function SlashCmdList.LEWAH(msg)
   canQuery,canQueryAll = CanSendAuctionQuery();
   if (canQueryAll == true) then
      dothingy = true;
      QueryAuctionItems("", nil, nil, 0, false, 0, true, false, nil);
   else
      message('Can not query all yet, goober.');
   end      
end

SLASH_LEWAHITEM1 = "/lahdb";
function SlashCmdList.LEWAHITEM(msg)
   print(msg);
   --lewdb = {};
   for i = msg, (msg+10000), 1 do
      itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
      itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
      GetItemInfo(i);
      if itemLink ~= nil then 
         lewdb[tostring(i)] = {itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice};
      end
      if(i == (msg+10000)) then
         print("done");
      end
   end
end

local function OnEvent(self, event, ...)
   if(event == 'AUCTION_ITEM_LIST_UPDATE') then
      if(dothingy == false) then
--         print('AUCTION_ITEM_LIST_UPDATE but no thingy :<');
      else
         lewdb = {};
         lewdb['scanDate'] = scan_date;
         for y = 1, 1000000, 1 do
            local name, texture, count, quality, canUse, level, levelColHeader, minBid,
            minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner,
            ownerFullName, saleStatus, itemId, hasAllInfo = GetAuctionItemInfo("list", y);
            --print(name .. " " .. itemId .. " " .. buyoutPrice)
            --print(y)

            if (name == nil) then
               print("LewAH hit a null value on item " .. y);
               return;
            end

            if (name == "") then
               name = tostring(itemId)
            end

            if (lewdb[name] == nil) then
               lewdb[name] = {['id'] = itemId, 
                  ['listings'] = {}
               }
            end
            
            table.insert(lewdb[name]['listings'], {texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus});
            dothingy = false;
         end
      end
   end
end

local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");
EventFrame:SetScript("OnEvent", OnEvent);
