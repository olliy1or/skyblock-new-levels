--[[

Skyblock for Minetest

Copyright (c) 2015 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-skyblock
License: GPLv3

]]--

--[[

level 4 feats and rewards:

* dig_papyrus x20			wool:white 50
* place_brick x50			stairs:stair_brick 4
* place_mossycobble x50		wool:blue 50
* place_bookshelf x4		wool:red 50
* place_steelblock x4		default:obsidian_shard
* place_sand x50			wool:green 50
* dig_stone_with_copper x4	wool:orange 50
* place_bar x8				default:mese_crystal
* dig_stone_with_mese x4	default:gold_lump
* place_water_infinite x8	default:diamond

]]--

local level = 4

--
-- PUBLIC FUNCTIONS
--

skyblock.levels[level] = {}

-- feats
skyblock.levels[level].feats = {
	{
		name = 'grow and collect 99 corn',
		hint = 'farming:corn',
		feat = 'dig_corn', 
		count = 99,
		reward = 'default:leaves 99',
		dignode = {'farming:corn'},
	},
	{
		name = 'grow trees',
		hint = 'default:sapling',
		feat = 'place_sapling', 
		count = 80,
		reward = 'default:tree 20',
		placenode = {'default:sapling'},
	},
	{
		name = 'place 50 chests',
		hint = 'default:chest',
		feat = 'place_mossycobble', 
		count = 50,
		reward = 'default:cobble',
		placenode = {'default:chest'},
	},
	{
		name = 'place 100 dirt',
		hint = 'default:dirt',
		feat = 'place_dirt', 
		count = 100,
		reward = 'wool:red 396',
		placenode = {'default:dirt'},
	},
	{
		name = 'place 200 cobblestone',
		hint = 'default:cobble',
		feat = 'place_cobble', 
		count = 200,
		reward = 'moreores:mineral_mithril 4',
		placenode = {'default:cobble'},
	},
	{
		name = 'dig 50 mithril',
		hint = 'moreores:mineral_mithril',
		feat = 'dig_50_mithril', 
		count = 50,
		reward = 'moreores:mineral_silver 4',
		dignode = {'moreores:mineral_mithril'},
	},
	{
		name = 'dig 50 silver',
		hint = 'moreores:mineral_silver',
		feat = 'dig_stone_with_silver', 
		count = 50,
		reward = 'wool:orange 50',
		dignode = {'moreores:mineral_silver'},
	},
	{
		name = 'place 10 travelnets',
		hint = 'travelnet:travelnet',
		feat = 'place_travelnet', 
		count = 10,
		reward = 'travelnet.elevator 10',
		placenode = {'travelnet:travelnet'},
	},
	{
		name = 'place enchantment table',
		hint = 'xdecor:enchantment_table',
		feat = 'place_enchanting_table', 
		count = 1, 
		reward = 'xdecor:enderchest 2',
		placenode = {'xdecor:enchantment_table'},
	},
	{
		name = 'place 2 hives',
		hint = 'xdecor:hive',
		feat = 'place_hive', 
		count = 2, 
		reward = 'xdecor:mailbox',
		placenode = {'xdecor:hive'}
	},
}

-- init level
skyblock.levels[level].init = function(player_name)
end

-- get level information
skyblock.levels[level].get_info = function(player_name)
	local info = { 
		level=level, 
		total=10, 
		count=0, 
		player_name=player_name, 
		infotext='', 
		formspec = '', 
		formspec_quest = '',
	}

	local text = 'label[0,2.7; --== Quests ==--]'
		..'label[0,0.5; Oh '..player_name..', Does This Keep Going?]'
		..'label[0,1.0; If you are enjoying this world, then stray not]'
		..'label[0,1.5; from your mission traveller...]'
		..'label[0,2.0; ... for the end is near.]'

	info.formspec = skyblock.levels.get_inventory_formspec(level,info.player_name,true)..text
	info.formspec_quest = skyblock.levels.get_inventory_formspec(level,info.player_name)..text

	for k,v in ipairs(skyblock.levels[level].feats) do
		info.formspec = info.formspec..skyblock.levels.get_feat_formspec(info,k,v.feat,v.count,v.name,v.hint)
		info.formspec_quest = info.formspec_quest..skyblock.levels.get_feat_formspec(info,k,v.feat,v.count,v.name)
	end
	if info.count>0 then
		info.count = info.count/2 -- only count once
	end

	info.infotext = 'LEVEL '..info.level..' for '..info.player_name..': '..info.count..' of '..info.total
	
	return info
end

-- reward_feat
skyblock.levels[level].reward_feat = function(player_name, feat)
	local rewarded = skyblock.levels.reward_feat(level, player_name, feat)
	
	-- add water after dig_stone_with_mese
	if rewarded and feat == 'dig_stone_with_mese' then
		local pos = skyblock.get_spawn(player_name)
		minetest.env:add_node({x=pos.x,y=pos.y+1,z=pos.z}, {name='default:water_source'})
		return true
	end

	return rewarded
end

-- track digging feats
skyblock.levels[level].on_dignode = function(pos, oldnode, digger)
	skyblock.levels.on_dignode(level, pos, oldnode, digger)
end

-- track placing feats
skyblock.levels[level].on_placenode = function(pos, newnode, placer, oldnode)
	skyblock.levels.on_placenode(level, pos, newnode, placer, oldnode)
end

-- track eating feats
skyblock.levels[level].on_item_eat = function(player_name, itemstack)
	skyblock.levels.on_item_eat(level, player_name, itemstack)
end

-- track crafting feats
skyblock.levels[level].on_craft = function(player_name, itemstack)
	skyblock.levels.on_craft(level, player_name, itemstack)
end

-- track bucket feats
skyblock.levels[level].bucket_on_use = function(player_name, pointed_thing)
	skyblock.levels.bucket_on_use(level, player_name, pointed_thing)
end

-- track bucket water feats
skyblock.levels[level].bucket_water_on_use = function(player_name, pointed_thing) 
	skyblock.levels.bucket_water_on_use(level, player_name, pointed_thing)
	
	-- place_water_infinite
	local pos = pointed_thing.under
	if minetest.env:get_node({x=pos.x-1,y=pos.y,z=pos.z-1}).name=='default:water_source' 
	or minetest.env:get_node({x=pos.x-1,y=pos.y,z=pos.z+1}).name=='default:water_source'
	or minetest.env:get_node({x=pos.x+1,y=pos.y,z=pos.z-1}).name=='default:water_source'
	or minetest.env:get_node({x=pos.x+1,y=pos.y,z=pos.z+1}).name=='default:water_source' then
		skyblock.feats.add(level,player_name,'place_water_infinite')
		return
	end
	
end

-- track bucket lava feats
skyblock.levels[level].bucket_lava_on_use = function(player_name, pointed_thing)
	skyblock.levels.bucket_lava_on_use(level, player_name, pointed_thing)
end
