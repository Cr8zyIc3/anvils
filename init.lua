
anvils = {}

local MAX_WEAR = 65535
local SAME_TOOL_REPAIR_BOOST = math.ceil(MAX_WEAR * 0.12) -- 12%


-- Given a tool and material stack, returns how many items of the material stack
-- needs to be used up to repair the tool.
local function get_consumed_materials(tool, material)

	local wear = tool:get_wear()

	if wear == 0 then
		return 0
	end

	local tooldef = tool:get_definition()
	local slice = math.ceil(MAX_WEAR / tooldef._repair_material_total)
	local matsize = material:get_count()
	local materials_used = 0

	for m = 1, math.min(tooldef._repair_material_total, matsize) do

		materials_used = materials_used + 1

		if wear - (m * slice) <= 0 then

			break
		end
	end

	return materials_used
end


-- Given 2 input stacks, tells you which is the tool and which is the material.
-- Returns ("tool", input1, input2) if input1 is tool and input2 is material.
-- Returns ("material", input2, input1) if input1 is material and input2 is tool.
-- Returns nil otherwise.
local function distinguish_tool_and_material(input1, input2)

	local def1 = input1:get_definition()
	local def2 = input2:get_definition()

	if def1.type == "tool" and def1._repair_material then

		return "tool", input1, input2

	elseif def2.type == "tool" and def2._repair_material then

		return "material", input2, input1
	else
		return nil
	end
end


-- Repair calculation helper.
-- Adds the “inverse” values of wear1 and wear2.
-- Then adds a boost health value directly.
-- Returns the resulting (capped) wear.
local function calculate_repair(wear1, wear2, boost)

	local new_health = (MAX_WEAR - wear1) + (MAX_WEAR - wear2)

	if boost then
		new_health = new_health + boost
	end

	return math.max(0, math.min(MAX_WEAR, MAX_WEAR - new_health))
end


-- Update the inventory slots of an anvil node.
-- meta: Metadata of anvil node
local function update_anvil_slots(meta)

	local inv = meta:get_inventory()
	local input1, input2, output

	input1 = inv:get_stack("input", 1)
	input2 = inv:get_stack("input", 2)
	output = inv:get_stack("output", 1)

	local new_output, name_item

	-- Both input slots occupied
	if (not input1:is_empty() and not input2:is_empty()) then

		-- Repair, if tool
		local def1 = input1:get_definition()
		local def2 = input2:get_definition()

		-- Same tool twice
		if input1:get_name() == input2:get_name()
		and def1.type == "tool"
		and (input1:get_wear() > 0 or input2:get_wear() > 0) then

			-- Add tool health together plus a small bonus
			-- TODO: Combine tool enchantments
			local new_wear = calculate_repair(input1:get_wear(),
					input2:get_wear(), SAME_TOOL_REPAIR_BOOST)

			input1:set_wear(new_wear)

			name_item = input1
			new_output = name_item

		-- Tool + repair item
		else
			-- Any tool can have a repair item. This may be defined in the
			-- tool's item definition as an itemstring in the field
			-- `_repair_material`. Only if this field is set, the tool can be
			-- repaired with a material item.  Example: Steel Pickaxe + Steel
			-- Ingot. `_repair_material = default:steel_ingot`

			-- Big repair bonus
			-- TODO: Combine tool enchantments
			local distinguished, tool, material =
					distinguish_tool_and_material(input1, input2)

			if distinguished then

				local tooldef = tool:get_definition()
				local has_correct_material = false

				if string.sub(tooldef._repair_material, 1, 6) == "group:" then

					has_correct_material = minetest.get_item_group(
						material:get_name(),
						string.sub(tooldef._repair_material, 7)) ~= 0

				elseif material:get_name() == tooldef._repair_material then
					has_correct_material = true
				end

				if has_correct_material and tool:get_wear() > 0 then

					local materials_used = get_consumed_materials(tool, material)
					local slice = math.ceil(
							MAX_WEAR / tooldef._repair_material_total)
					local wear = tool:get_wear()
					local new_wear = wear - (materials_used * slice)

					tool:set_wear(math.max(0, new_wear))

					new_output = tool
				else
					new_output = ""
				end
			else
				new_output = ""
			end
		end

	-- if tool or item removed, clear output
	elseif not output:is_empty() then
		new_output = ""
	end

	-- Set the new output slot
	if new_output ~= nil then

		inv:set_stack("output", 1, new_output)
	end
end


-- Drop input items of anvil at pos with metadata meta
local function drop_anvil_items(pos, meta)

	local inv = meta:get_inventory()

	for i = 1, inv:get_size("input") do

		local stack = inv:get_stack("input", i)

		if not stack:is_empty() then

			local p = {
				x = pos.x + math.random(-10, 10) / 9,
				y = pos.y,
				z = pos.z + math.random(-10, 10) / 9}

			minetest.add_item(p, stack)
		end
	end
end


local anvildef = {

	description = "Anvil",

	groups = {
		cracky = 1, level = 2, falling_node = 1, falling_node_damage = 4
	},

	tiles = {
		"anvils_anvil_top.png",
		"anvils_anvil_base.png",
		"anvils_anvil_side.png"
	},

	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, 2/16, -5/16, 8/16, 8/16, 5/16}, --  top
			{-5/16, -4/16, -2/16, 5/16, 5/16, 2/16}, -- middle
			{-8/16, -8/16, -5/16, 8/16, -4/16, 5/16}, -- base
		}
	},

	sounds = default.node_sound_metal_defaults(),

	after_dig_node = function(pos, oldnode, oldmetadata, digger)

		local meta = minetest.get_meta(pos)
		local meta2 = meta

		meta:from_table(oldmetadata)

		drop_anvil_items(pos, meta)

		meta:from_table(meta2:to_table())
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)

		if listname == "output" then
			return 0
		else
			return stack:get_count()
		end
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index,
			to_list, to_index, count, player)

		if to_list == "output" then
			return 0

		elseif from_list == "output" and to_list == "input" then

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()

			if inv:get_stack(to_list, to_index):is_empty() then
				return count
			else
				return 0
			end
		else
			return count
		end
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)

		local meta = minetest.get_meta(pos)

		update_anvil_slots(meta)
	end,

	on_metadata_inventory_move = function(pos, from_list, from_index,
			to_list, to_index, count, player)

		local meta = minetest.get_meta(pos)

		if from_list == "output" and to_list == "input" then

			local inv = meta:get_inventory()

			for i = 1, inv:get_size("input") do

				if i ~= to_index then

					local istack = inv:get_stack("input", i)

					istack:set_count(math.max(0, istack:get_count() - count))

					inv:set_stack("input", i, istack)
				end
			end
		end

		update_anvil_slots(meta)
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)

		if listname == "output" then

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local input1 = inv:get_stack("input", 1)
			local input2 = inv:get_stack("input", 2)

			if input1:is_empty() or input2:is_empty() then
				return 0
			end
		end

		return stack:get_count()
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)

		local meta = minetest.get_meta(pos)

		if listname == "output" then

			local inv = meta:get_inventory()
			local input1 = inv:get_stack("input", 1)
			local input2 = inv:get_stack("input", 2)

			-- Both slots occupied?
			if not input1:is_empty() and not input2:is_empty() then

				-- Take as many items as needed
				local distinguished, tool,
					material = distinguish_tool_and_material(input1, input2)

				if distinguished then

					-- Tool + material: Take tool and as many materials as needed
					local materials_used = get_consumed_materials(tool, material)

					material:set_count(material:get_count() - materials_used)

					tool:take_item()

					local player_name = player:get_player_name()

					minetest.sound_play("anvil_use", {
						to_player = player_name, gain = 1.0})

					if distinguished == "tool" then
						input1, input2 = tool, material
					else
						input1, input2 = material, tool
					end

					inv:set_stack("input", 1, input1)
					inv:set_stack("input", 2, input2)
				else
					-- Else take 1 item from each stack
					input1:take_item()
					input2:take_item()

					inv:set_stack("input", 1, input1)
					inv:set_stack("input", 2, input2)
				end
			end

		elseif listname == "input" then

			update_anvil_slots(meta)
		end
	end,

	on_construct = function(pos)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		inv:set_size("input", 2)
		inv:set_size("output", 1)

		meta:set_string("formspec",
			"size[8,6.5]"
			.. "list[context;input;1,1;1,1;]"
			.. "list[context;input;3.5,1;1,1;1]"
			.. "list[context;output;6,1;1,1;]"

			.. "list[current_player;main;0,2.5;8,4]"

			.. "label[1.0,0.2;Tool]"
			.. "label[3.5,0.2;Material]"
			.. "label[6,0.2;Output]"

			.. "field_close_on_enter[name;false]"
			.. "listring[context;input]"
			.. "listring[context;output]"
			.. "listring[current_player;main]"
			.. "listring[current_player;main]")
	end,
}


if minetest.get_modpath("screwdriver") then
	anvildef.on_rotate = screwdriver.rotate_simple
end

minetest.register_node("anvils:anvil", anvildef)

minetest.register_alias("anvils:anvil_damage_1", "anvils:anvil")
minetest.register_alias("anvils:anvil_damage_2", "anvils:anvil")


minetest.register_craft({
	output = "anvils:anvil",
	recipe = {
		{"default:steelblock", "default:steelblock", "default:steelblock"},
		{"", "default:steel_ingot", ""},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	}
})


dofile(minetest.get_modpath("anvils") .. "/tools.lua")
