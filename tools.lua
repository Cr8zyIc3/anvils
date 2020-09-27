
-- Helper function

local add_tool = function(name, material, num_required, add_group)

	if minetest.registered_items[name] then

		local grps = minetest.registered_items[name].groups

		if add_group == true then
			grps.tool = 1
		end

		minetest.override_item(name, {
			groups = grps,
			_repair_material = material,
			_repair_material_total = num_required or 3
		})
	end
end

-- Default tools

add_tool("default:pick_diamond", "default:diamond", 3, true)
add_tool("default:axe_diamond", "default:diamond", 3, true)
add_tool("default:shovel_diamond", "default:diamond", 1, true)
add_tool("default:sword_diamond", "default:diamond", 2, true)

add_tool("default:pick_wood", "default:wood", 3, true)
add_tool("default:axe_wood", "default:wood", 3, true)
add_tool("default:shovel_wood", "default:wood", 1, true)
add_tool("default:sword_wood", "default:wood", 2, true)

add_tool("default:pick_steel", "default:steel_ingot", 3, true)
add_tool("default:axe_steel", "default:steel_ingot", 3, true)
add_tool("default:shovel_steel", "default:steel_ingot", 1, true)
add_tool("default:sword_steel", "default:steel_ingot", 2, true)

add_tool("default:pick_stone", "default:cobble", 3, true)
add_tool("default:axe_stone", "default:cobble", 3, true)
add_tool("default:shovel_stone", "default:cobble", 1, true)
add_tool("default:sword_stone", "default:cobble", 2, true)

add_tool("default:pick_bronze", "default:bronze_ingot", 3, true)
add_tool("default:axe_bronze", "default:bronze_ingot", 3, true)
add_tool("default:shovel_bronze", "default:bronze_ingot", 1, true)
add_tool("default:sword_bronze", "default:bronze_ingot", 2, true)

add_tool("default:pick_mese", "default:mese_crystal", 3, true)
add_tool("default:axe_mese", "default:mese_crystal", 3, true)
add_tool("default:shovel_mese", "default:mese_crystal", 1, true)
add_tool("default:sword_mese", "default:mese_crystal", 2, true)

-- Farming tools

if minetest.get_modpath("farming") then

	add_tool("default:hoe_diamond", "default:diamond", 2, true)
	add_tool("default:hoe_wood", "default:wood", 2, true)
	add_tool("default:hoe_steel", "default:steel_ingot", 2, true)
	add_tool("default:hoe_stone", "default:cobble", 2, true)
	add_tool("default:hoe_bronze", "default:bronze_ingot", 2, true)
	add_tool("default:hoe_mese", "default:mese_crystal", 2, true)

	if minetest.get_modpath("moreores") then

		add_tool("moreores:hoe_mithril", "moreores:mithril_ingot", 2, true)
		add_tool("moreores:hoe_silver", "moreores:silver_ingot", 2, true)
	end
end

-- MoreOres tools

if minetest.get_modpath("moreores") then

	add_tool("moreores:pick_mithril", "moreores:mithril_ingot", 3, true)
	add_tool("moreores:axe_mithril", "moreores:mithril_ingot", 3, true)
	add_tool("moreores:shovel_mithril", "moreores:mithril_ingot", 1, true)
	add_tool("moreores:sword_mithril", "moreores:mithril_ingot", 2, true)

	add_tool("moreores:pick_silver", "moreores:silver_ingot", 3, true)
	add_tool("moreores:axe_silver", "moreores:silver_ingot", 3, true)
	add_tool("moreores:shovel_silver", "moreores:silver_ingot", 1, true)
	add_tool("moreores:sword_silver", "moreores:silver_ingot", 2, true)
end

-- Ethereal tools

if minetest.get_modpath("ethereal") then

	add_tool("ethereal:pick_crystal", "ethereal:crystal_ingot", 3, true)
	add_tool("ethereal:axe_crystal", "ethereal:crystal_ingot", 3, true)
	add_tool("ethereal:shovel_crystal", "ethereal:crystal_ingot", 1, true)
	add_tool("ethereal:sword_crystal", "ethereal:crystal_ingot", 2, true)
end

-- 3D armor

if minetest.get_modpath("3d_armor") then

	if armor.materials.steel then
	add_tool("3d_armor:helmet_steel", "default:steel_ingot", 5)
	add_tool("3d_armor:chestplate_steel", "default:steel_ingot", 8)
	add_tool("3d_armor:leggings_steel", "default:steel_ingot", 7)
	add_tool("3d_armor:boots_steel", "default:steel_ingot", 4)
	end

	if armor.materials.bronze then
	add_tool("3d_armor:helmet_bronze", "default:bronze_ingot", 5)
	add_tool("3d_armor:chestplate_bronze", "default:bronze_ingot", 8)
	add_tool("3d_armor:leggings_bronze", "default:bronze_ingot", 7)
	add_tool("3d_armor:boots_bronze", "default:bronze_ingot", 4)
	end

	if armor.materials.gold then
	add_tool("3d_armor:helmet_gold", "default:gold_ingot", 5)
	add_tool("3d_armor:chestplate_gold", "default:gold_ingot", 8)
	add_tool("3d_armor:leggings_gold", "default:gold_ingot", 7)
	add_tool("3d_armor:boots_gold", "default:gold_ingot", 4)
	end

	if armor.materials.diamond then
	add_tool("3d_armor:helmet_diamond", "default:diamond", 5)
	add_tool("3d_armor:chestplate_diamond", "default:diamond", 8)
	add_tool("3d_armor:leggings_diamond", "default:diamond", 7)
	add_tool("3d_armor:boots_diamond", "default:diamond", 4)
	end

	if armor.materials.mithril then
	add_tool("3d_armor:helmet_mithril", "moreores:mithril_ingot", 5)
	add_tool("3d_armor:chestplate_mithril", "moreores:mithril_ingot", 8)
	add_tool("3d_armor:leggings_mithril", "moreores:mithril_ingot", 7)
	add_tool("3d_armor:boots_mithril", "moreores:mithril_ingot", 4)
	end

	if armor.materials.crystal then
	add_tool("3d_armor:helmet_crystal", "ethereal:crystal_ingot", 5)
	add_tool("3d_armor:chestplate_crystal", "ethereal:crystal_ingot", 8)
	add_tool("3d_armor:leggings_crystal", "ethereal:crystal_ingot", 7)
	add_tool("3d_armor:boots_crystal", "ethereal:crystal_ingot", 4)
	end
end

-- Xanadu mod
if minetest.get_modpath("xanadu") then
	add_tool("xanadu:axe_super", "default:diamond", 18, true)
end
