local plugin = {}

plugin.name = "Sonic Ring Shuffler"
plugin.author = "adrian_squared"
plugin.settings = {}

plugin.description =
[[
    This plugin is designed to switch between games once the player obtains a ring.
]]

oldring = 0
-- modified swap_game fonction to avoid sound turning off after switching within 1 frame
function swap_game(next_game)
	log_debug('swap_game(%s): running=%s', next_game, running)
	-- if a swap has already happened, don't call again
	if not running then return false end

	-- if no game provided, call get_next_game()
	next_game = next_game or get_next_game()

	-- if the game isn't changing, stop here and just update the timer
	-- (you might think we should just disable the timer at this point, but this
	-- allows new games to be added mid-run without the timer being disabled)
	if next_game == config.current_game then
		update_next_swap_time()
		return false
	end

	-- swap_game() is used for the first load, so check if a game is loaded
	if config.current_game ~= nil then
		for _,plugin in ipairs(plugins) do
			if plugin.on_game_save ~= nil then
				local pdata = config.plugins[plugin._module]
				plugin.on_game_save(pdata.state, pdata.settings)
			end
		end
	end

	-- at this point, save the game and update the new "current" game after
	save_current_game()
	config.current_game = next_game
	running = false

	-- unique game count, for debug purposes
	config.game_count = 0
	for _, _ in pairs(config.game_swaps) do
		config.game_count = config.game_count + 1
	end

	-- save an updated randomizer seed
	config.nseed = math.random(MAX_INTEGER) + config.frame_count
	save_config(config, 'shuffler-src/config.lua')

	return load_game(config.current_game)
end

function plugin.on_game_load(data)
	name = gameinfo.getromname()
	-- console.writeline(gameinfo.getromname())
end
-- redundant fonction in case I need to add smth later
function ring_swap()
	oldring = 1000000
	swap_game()
end

-- called each frame
function plugin.on_frame(data, settings)
	next_swap_time = next_swap_time+1000
	-- Mega Drive Games
	if name == "Sonic The Hedgehog (W) (REV00) [!]" or name == "Sonic The Hedgehog (W) (REV01) [!]" or name == "Sonic The Hedgehog 2 (W) (REV00) [!]" or name == "Sonic The Hedgehog 2 (W) (REV01) [!]" or name == "Sonic The Hedgehog 3 (U) [!]" or name == "Sonic The Hedgehog 3 (J) [!]" or name == "Sonic The Hedgehog 3 (E) [!]" or name == "Sonic and Knuckles (W) [!]" or name == "Sonic and Knuckles & Sonic 2 (W) [!]" or name == "Sonic & Knuckles + Sonic The Hedgehog 3 (E)" or name == "Sonic & Knuckles + Sonic The Hedgehog 3 (J)" or name == "Sonic and Knuckles & Sonic 3 (W) [!]" then
		if memory.read_u16_be(0xFE20,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xFE20,"68K RAM")
	elseif name == "Sonic Eraser (SN) (J) [!]" then
		if memory.read_u16_be(0xC710,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xC710,"68K RAM")
	elseif name == "Dr. Robotnik's Mean Bean Machine (U) [!]" or name == "Dr. Robotnik's Mean Bean Machine (E) [!]" then
		if memory.read_u16_be(0xE00C,"68K RAM") > oldring+39 then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xE00C,"68K RAM")
	elseif name == "Sonic Spinball (U) [!]" or name == "Sonic Spinball (J) [!]" or name == "Sonic Spinball (E) [!]" then
		if memory.read_u8(0x57A0,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x57A0,"68K RAM")
	elseif name == "Sonic 3D Blast (UE) [!]" then
		if memory.read_u16_be(0x0A5A,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x0A5A,"68K RAM")
	elseif name == "Sonic and Knuckles & Sonic 1 (W) [!]" or name == "Sonic & Knuckles + Sonic The Hedgehog (JK)" then
		if memory.read_u16_be(0xE442,"68K RAM") < oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xE442,"68K RAM")
	-- Mega-CD Games
	elseif name == "Sonic CD (USA)" or name == "Sonic CD (USA) (RE125)" or name == "Sonic CD (Europe)" or name == "Sonic the Hedgehog CD (Japan)" then
		if memory.read_u16_be(0x1512,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x1512,"68K RAM")
	-- 32X Games
	elseif name == "Knuckles' Chaotix (32X) (JU) [!]" or name == "Knuckles' Chaotix (32X) (E) [!]" then
		if memory.read_u16_be(0xE008,"68K RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0xE008,"68K RAM")
	-- Master System & Game Gear Games
	elseif name == "Sonic The Hedgehog (UE)" then -- SMS Version
		if memory.read_u8(0x12AA,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x12AA,"Main RAM")
	elseif name == "Sonic The Hedgehog (W) (Rev 1)" or name == "Sonic The Hedgehog (J)" then -- Game Gear Version
		if memory.read_u8(0x12A9,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x12A9,"Main RAM")
	elseif name == "Sonic The Hedgehog 2 (E)" or name == "Sonic The Hedgehog 2 (E) (Rev 1)" or name == "Sonic The Hedgehog 2 (W)" then -- SMS & Game Gear Versions
		if memory.read_u8(0x1299,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x1299,"Main RAM")
	elseif name == "Sonic Chaos (E)" then -- SMS Version
		if memory.read_u8(0x129A,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x129A,"Main RAM")
	elseif name == "Sonic Chaos (UE)" or name == "Sonic & Tails (J) (En)" then -- Game Gear Versions
		if memory.read_u8(0x129C,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x129C,"Main RAM")
	elseif name == "Dr. Robotnik's Mean Bean Machine (E)" or name == "Dr. Robotnik's Mean Bean Machine (UE)" then -- SMS & Game Gear Versions
		if memory.read_u8(0x0CC0,"Main RAM") > oldring+39 then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x0CC0,"Main RAM")
	elseif name == "Sonic Drift (J)" then
		if memory.read_u8(0x1A00,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x1A00,"Main RAM")
	elseif name == "Sonic Spinball (E)" then -- SMS Version
		if memory.read_u8(0x1E84,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x1E84,"Main RAM")
	elseif name == "Sonic Spinball (UE)" then -- Game Gear Version
		if memory.read_u8(0x1E6A,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x1E6A,"Main RAM")
	elseif name == "Sonic The Hedgehog - Triple Trouble (UE)" or name == "Sonic & Tails 2 (J)" then
		if memory.read_u8(0x1159,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x1159,"Main RAM")
	elseif name == "Sonic Drift 2 (JU)" then
		if memory.read_u8(0x1CC3,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x1CC3,"Main RAM")
	elseif name == "Sonic Blast (B)" or name == "Sonic Blast (W)" then -- SMS and Game Gear Versions
		if memory.read_u8(0x125E,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u8(0x125E,"Main RAM")
	-- Saturn Games
	elseif name == "Sonic R (USA, Brazil)" then -- Need to add JP & EU versions
		if memory.read_u16_be(0x00B3F0,"Work Ram High") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x00B3F0,"Work Ram High")
	elseif name == "Sonic 3D Blast (USA)" then -- Need to add JP & EU versions
		if memory.read_u16_be(0x09800C,"Work Ram High") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x09800C,"Work Ram High")
	elseif name == "Sonic Jam (USA)" then -- Need to add JP & EU versions
		if memory.read_u16_be(0x0FFD26,"Work Ram High") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x0FFD26,"Work Ram High")
	-- Game Boy Advance Games
	elseif name == "Sonic Advance (USA) (En,Ja)" or name == "Sonic Advance (Japan) (En,Ja)" or name == "Sonic Advance (Europe) (En,Ja,Fr,De,Es)" then
		if memory.read_u16_be(0x4FEC,"IWRAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x4FEC,"IWRAM")
	elseif name == "Sonic Advance 2 (USA) (En,Ja,Fr,De,Es,It)" or name == "Sonic Advance 2 (Japan) (En,Ja,Fr,De,Es,It)" or name == "Sonic Advance 2 (Europe) (En,Ja,Fr,De,Es,It)" then
		if memory.read_u16_be(0x53F0,"IWRAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x53F0,"IWRAM")
	elseif name == "Sonic Advance 3 (USA) (En,Ja,Fr,De,Es,It)" or name == "Sonic Advance 3 (Japan) (En,Ja,Fr,De,Es,It)" or name == "Sonic Advance 3 (Europe) (En,Ja,Fr,De,Es,It)" then
		if memory.read_u16_be(0x094C,"IWRAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x094C,"IWRAM")
	-- DS Games
	elseif name == "Sonic Rush (USA) (En,Ja,Fr,De,Es,It)" or name == "Sonic Rush (Japan) (En,Ja,Fr,De,Es,It)" or name == "Sonic Rush (Europe) (En,Ja,Fr,De,Es,It)" then
		if memory.read_u16_be(0x090B6E,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x090B6E,"Main RAM")
	elseif name == "Sonic Rush Adventure (USA) (En,Ja,Fr,De,Es,It)" or name == "Sonic Rush Adventure (Japan) (En,Ja,Fr,De,Es,It)" or name == "Sonic Rush Adventure (Europe) (En,Ja,Fr,De,Es,It)" or name == "Sonic Rush Adventure (Europe) (En,Ja,Fr,De,Es,It) (Rev 1)" or name == "Sonic Rush Adventure (K)" then
		if memory.read_u16_be(0x18F6BE,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x18F6BE,"Main RAM")
	elseif name == "Sonic Colors (USA) (En,Ja,Fr,De,Es,It)" or name == "Sonic Colors (Japan) (En,Ja,Fr,De,Es,It)" or name == "Sonic Colours (Europe) (En,Ja,Fr,De,Es,It)" then
		if memory.read_u16_be(0x19B936,"Main RAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x19B936,"Main RAM")
	-- 3DS Games
	elseif name == "Sonic Generations (USA) (En,Fr,Es)" then -- Need to add JP & EU Versions
		if memory.read_u16_be(0x077E5934,"FCRAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x077E5934,"FCRAM")
	elseif name == "Sonic - Lost World (USA) (En,Fr,Es)" then -- Need to add JP & EU Versions
		if memory.read_u16_be(0x06D13900,"FCRAM") > oldring then
			ring_swap()
			return
		end
		oldring = memory.read_u16_be(0x06D13900,"FCRAM")
	end
end

return plugin
