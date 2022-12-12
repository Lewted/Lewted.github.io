scan_date = date("%m/%d/%y %H:%M:%S");
lewdb = {['scanDate'] = scan_date};
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

local function OnEvent(self, event, ...)
	print(event, ...)
   if(event == 'AUCTION_ITEM_LIST_UPDATE') then
      if(dothingy == false) then
         print('AUCTION_ITEM_LIST_UPDATE but no thingy :<');
      else
         message('yay!');
         for y = 1, 100000, 1 do
            local name, texture, count, quality, canUse, level, levelColHeader, minBid,
            minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner,
            ownerFullName, saleStatus, itemId, hasAllInfo = GetAuctionItemInfo("list", y);
            --print(name .. " " .. itemId .. " " .. buyoutPrice)
            print(y)
            if (name == nil) then
               message("LewAH hit a null value on item " .. y);
               return;
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
