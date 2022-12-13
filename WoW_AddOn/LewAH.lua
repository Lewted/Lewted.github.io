message("Greetings! LewAH is up and running.");

lewdb = {};
LewAH_scan_date = date("%m/%d/%y %H:%M:%S");

LewAH_scan_ah = false;
LewAH_store_items = false;

--stores all auction house data in lewdb
SLASH_LAH1 = "/lewah";
function SlashCmdList.LAH(msg)
   local canQuery,canQueryAll = CanSendAuctionQuery();
   if (canQueryAll == true) then
      LewAH_scan_ah = true;
      QueryAuctionItems("", nil, nil, 0, false, 0, true, false, nil);
   else
      message('Can not query all yet, goober.');
   end      
end

--stores all item data from the game files. This only needs to be run once every expansion.
--disable addons for this to work fully, but will still need to be run multiple times because caching bugs.
--runs in whatever increment doesn't blow up your computer, which for me is 10,000
--run this up to item 60000 to scrape 99% of items. /reload often to save data state
--then run lahdbfull for the stragglers which have oddly large and random id's
SLASH_LEWDB1 = "/lewdb";
function SlashCmdList.LEWDB(start)
   local inc = 10000;
   print('LewDB collecting item information from '..tostring(start).. " to "..tostring(start+inc));
   LewAH_store_items = true;
   local all_clear_flag = true;

   for i = start, (start+inc), 1 do
      if(lewdb[tostring(i)] == nil) then
         local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, 
         itemEquipLoc, itemTexture, itemSellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(i);

         if itemName ~= nil then 
            all_clear_flag = false;
            lewdb[tostring(i)] = {itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, 
               itemEquipLoc, itemTexture, itemSellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent};
         end
      end
   end
   if (all_clear_flag == true) then
      print("\124cffFFFF00LewAH => Items "..start.." to "..(start+inc).." are most likely all in the database but run again to be sure.\124r");
   else
      print("\124cffFF0000LewAH => Items "..start.." to "..(start+inc).." were not all included. Run again.\124r");
   end
end

--only run this after running lahdb maybe about 6 times (1-10001, 10000-20000, etc)
SLASH_LEWDBFULL1 = "/lewdbfull";
function SlashCmdList.LEWDBFULL(msg)
   LewAH_store_items = true;
   local max = 225000;
   print('LewDB collecting item information from 1 to '..tostring(max));
   for i = 1, max, 1 do
      if(lewdb[tostring(i)] == nil) then
         local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, 
         itemEquipLoc, itemTexture, itemSellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(i);

         if itemName ~= nil then 
            lewdb[tostring(i)] = {itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, 
               itemEquipLoc, itemTexture, itemSellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent};
               print(tostring(i).." successfully added");
         end
      end
   end
end

local function OnEvent(self, event, ...)
   if(event == 'AUCTION_ITEM_LIST_UPDATE') then
      if (LewAH_scan_ah == true) then
         lewdb = {};
         LewAH_scan_date = date("%m/%d/%y %H:%M:%S")
         lewdb['scanDate'] = LewAH_scan_date;
         for y = 1, 1000000, 1 do
            local name, texture, count, quality, canUse, level, levelColHeader, minBid,
            minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner,
            ownerFullName, saleStatus, itemId, hasAllInfo = GetAuctionItemInfo("list", y);

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
            LewAH_scan_ah = false;
         end
      end
      --disable other addons to gaurantee this works.
   elseif (event == 'GET_ITEM_INFO_RECEIVED' and LewAH_store_items == true) then
      if (arg1 == nil) then
         return;
      end
      local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, 
      itemEquipLoc, itemTexture, itemSellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(arg1);
      if itemName ~= nil then 
         print(tostring(arg1).." from event");
         lewdb[tostring(arg1)] = {itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, 
            itemEquipLoc, itemTexture, itemSellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent};
      end
      LewAH_store_items = false;
   end
end

local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");
EventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
EventFrame:SetScript("OnEvent", OnEvent);