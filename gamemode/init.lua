// GAMEMODE INIT

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "helpmenu.lua" )
AddCSLuaFile( "cl_numslider.lua" )

include( 'shared.lua' )

--resource.AddFile([[sound/gofish/music.mp3]])
-- resource.AddFile([[sound/gofish/Sound made by Pk191 aka Kemp.tmp]]) <-- This made the server crash.

util.AddNetworkString("ScoreChanged")
util.AddNetworkString("startthebloodynoise")

local function addmeta()
	local meta = FindMetaTable( "Player" ) 
	if (!meta) then return end 
	
	function meta:AddScore(x) -- bogus function to control AddFrags
		net.Start("ScoreChanged")
		net.Send(self)
		net.WriteInt( x )
		return self:AddFrags(x)
	end 
end
addmeta()

function cleanupafter( ply )
	for k,v in pairs(ents.FindByClass("npc_*")) do
		if v:IsValid() and v.fishowner == ply then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("prop_physics_multiplayer")) do
		if v:IsValid() and v.fishowner == ply then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("fishing_hook")) do
		if v:IsValid() and v.fishowner == ply then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("fishing_bait")) do
		if v:IsValid() and v.fishowner == ply then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("fishing_rod")) do
		if v:IsValid() and v.fishowner == ply then
			v:Remove()
		end
	end
end

function GM:PlayerDisconnected( ply )
	cleanupafter(ply)
end

function Loadout( ply )
	ply:Give("weapon_physcannon")
	--ply:Give("weapon_physgun") -- For dev tests
	ply:SelectWeapon("weapon_physcannon")
	return true
end

function gravgunPunt( userid, ent )
	/*if 	ent:GetModel() == "models/props_c17/oildrum001_explosive.mdl" or
		ent:GetClass() == "npc_grenade_frag" then
		return true
	end*/
	return true
end

hook.Add( "GravGunPunt", "gravgunPunt", gravgunPunt ) 

function gravgunPickup( ply, ent )
	if not ent:IsValid() then return false end
	
	if ent:GetName() == "Friendly" or ent:GetClass() == "npc_turret_floor" then
		return true
	elseif ent:GetName() == "Enemy" then
		return false
	end
	return true
end
hook.Add("GravGunPickupAllowed", "gravgunPickup", gravgunPickup)

function GM:PlayerShouldTakeDamage( ply, attacker )
	if ply != attacker and attacker:IsPlayer() then 
		return false
	end
 	return true
end

function GM:ShowHelp( ply ) 
 	ply:ConCommand( "gofishhelp" ) 
end

function StartNoise( ply )
	timer.Simple(1,function()
		net.Start("startthebloodynoise")
		net.Send(ply)
		net.WriteEntity( ply )
		end
	)
end
hook.Add( "PlayerInitialSpawn", "StartNoise", StartNoise ); 

function PlayerSpawns( ply )
	ply:SetTeam(TEAM_FISHING)
end
hook.Add( "PlayerSpawn", "PlayerSpawns", PlayerSpawns )  

function NPCGotKilled( victim, killer, weapon )
	if not killer:IsPlayer() then return end
	if victim:GetName() == "Enemy" then
		killer:AddScore(1)
	elseif victim:GetName() == "Friendly" then
		killer:AddScore(-1)
	end
end
hook.Add("OnNPCKilled","NPCGotKilled",NPCGotKilled)

function GM:DoPlayerDeath( ply, attacker, dmginfo ) 
	ply:CreateRagdoll() 
	ply:AddDeaths( 1 )
	ply:SetTeam(TEAM_DEAD)
	 
	if ( attacker:IsValid() && attacker:IsPlayer() ) then 
		if ( attacker == ply ) then 
			attacker:AddScore( -1 ) 
		else
			attacker:AddScore( -10 ) 
		end 
	end 
end

local spawnsound = Sound("ui/buttonclickrelease.wav")
function ProcessChat( ply, text )
	local thingies = {
		{"!rod", "fishing_rod"},
		{"!bait", "fishing_bait"},
		{"!hook", "fishing_hook"}
	}
	
	for _,m in pairs(thingies) do
		if string.find(text, m[1]) == 1 then
		
			local sent = scripted_ents.GetStored( m[2] )
 			if ( sent ) then
 				local sent = sent.t
				local trace = {}
				trace.start = ply:GetShootPos()
				trace.endpos = trace.start + (ply:GetAimVector() * 1024)
				trace.filter = ply
				local tr = util.TraceLine( trace ) 
 				
 				local entity = sent:SpawnFunction( ply, tr )
				entity.fishowner = ply
 					
 					if ply:GetVar( "gofish_".. m[2], nil ) != nil and ply:GetVar( "gofish_".. m[2], nil ):IsValid() then
 						ply:GetVar( "gofish_".. m[2], nil ):Remove()
 					end
 					ply:SetVar( "gofish_".. m[2], entity )
 			end
 			ply:EmitSound( spawnsound, 100, 100 )
 			
			return "" -- Don't say anything
		end
	end
end
hook.Add ( "PlayerSay", "ProcessChat", ProcessChat ) 

function Notice(...)
	for k,v in pairs(player:GetAll()) do
		v:PrintMessage( HUD_PRINTTALK, tostring(...) ) 
	end
end
hook.Add( "PlayerLoadout", "gravAndShot", Loadout)

Catchphrase = {
	
		// ITEMS & AMMO
		{"item_battery", 			"models/Items/battery.mdl"}, -- Armor Kit
		{"item_healthkit", 			"models/Items/HealthKit.mdl"}, -- Health Kit
		{"item_healthvial", 		"models/healthvial.mdl"}, -- Health Vial
		{"item_ammo_ar2_altfire",	"models/Items/combine_rifle_ammo01.mdl"}, -- AR2 Ammo Secondary
		{"item_ammo_smg1_grenade",	"models/Items/AR2_Grenade.mdl"}, -- SMG Grenade

		// ITEMS & AMMO
		{"item_battery", 			"models/Items/battery.mdl"}, -- Armor Kit
		{"item_healthkit", 			"models/Items/HealthKit.mdl"}, -- Health Kit
		{"item_healthvial", 		"models/healthvial.mdl"}, -- Health Vial
		{"item_ammo_ar2_altfire",	"models/Items/combine_rifle_ammo01.mdl"}, -- AR2 Ammo Secondary
		{"item_ammo_smg1_grenade",	"models/Items/AR2_Grenade.mdl"}, -- SMG Grenade
		
		// PROPS
		{"prop_physics_multiplayer",	"models/props_c17/oildrum001_explosive.mdl"}, -- Explosive Barrel
		{"prop_physics_multiplayer",	"models/props_wasteland/laundry_cart002.mdl"},
		{"prop_physics_multiplayer",	"models/props_junk/Shoe001a.mdl"}, -- Boot ;)
		{"prop_physics_multiplayer",	"models/props_junk/PlasticCrate01a.mdl"}, -- Plastic Crate
		{"prop_physics_multiplayer",	"models/props_junk/watermelon01.mdl"}, -- Watermelon
		{"prop_physics_multiplayer",	"models/props_junk/MetalBucket01a.mdl"}, -- Metal Bucket
		{"prop_physics_multiplayer",	"models/props_c17/doll01.mdl"}, -- Babeh
		{"prop_physics_multiplayer",	"models/Gibs/wood_gib01a.mdl"}, -- Wooden Gib 1
		{"prop_physics_multiplayer",	"models/props_c17/metalPot002a.mdl"}, -- Metal Pot 1
		{"prop_physics_multiplayer",	"models/props_c17/metalPot001a.mdl"}, -- Metal Pot 2
		{"prop_physics_multiplayer",	"models/props_c17/streetsign001c.mdl"}, -- Sign 1
		{"prop_physics_multiplayer",	"models/props_c17/SuitCase001a.mdl"}, -- Suitcase
		{"prop_physics_multiplayer",	"models/props_junk/cardboard_box003b.mdl"},
		{"prop_physics_multiplayer",	"models/props_junk/cardboard_box002b.mdl"},
		{"prop_physics_multiplayer",	"models/props_lab/kennel_physics.mdl"},
		{"prop_physics_multiplayer",	"models/props_junk/wood_crate001a_damaged.mdl"},
		{"prop_physics_multiplayer",	"models/props_interiors/SinkKitchen01a.mdl"},
		{"prop_physics_multiplayer",	"models/props_junk/garbage_metalcan001a.mdl"},
		{"prop_physics_multiplayer",	"models/props_junk/garbage_plasticbottle002a.mdl"},
		{"prop_physics_multiplayer",	"models/props_vehicles/carparts_door01a.mdl"},
		{"prop_physics_multiplayer",	"models/props_junk/Wheebarrow01a.mdl"},
		{"prop_physics_multiplayer",	"models/props_c17/TrapPropeller_Blade.mdl"},
		
		// NPCS
		{"npc_antlion",				"models/AntLion.mdl"}, -- Antlion
		{"npc_antlionguard",		"models/antlion_guard.mdl"}, -- Antlion Guard
		{"npc_combinedropship",		"models/Combine_dropship.mdl"}, -- Combine Dropship
		{"npc_combinegunship",		"models/gunship.mdl"}, -- Combine Gunship
		{"npc_crow",				"models/Crow.mdl"}, -- Crow
		{"npc_cscanner",			"models/Combine_Scanner.mdl"}, -- City Scanner
		{"npc_fastzombie",			"models/Zombie/Fast.mdl"}, -- Fast Zombie
		{"npc_headcrab", 			"models/headcrabclassic.mdl"}, -- Classic Headcrab
		{"npc_headcrab_black",		"models/headcrabblack.mdl"}, -- Black Headcrab
		{"npc_headcrab_fast", 		"models/headcrab.mdl"}, -- Fast Headcrab
		{"npc_helicopter",			"models/Combine_Helicopter.mdl"}, -- Helicopter
		{"npc_manhack",				"models/manhack.mdl"}, -- Manhack
		{"npc_pigeon",				"models/pigeon.mdl"}, -- Pigeon
		{"npc_poisonzombie",		"models/Zombie/Poison.mdl"}, -- Poison Zombie
		{"npc_rollermine",			"models/Roller.mdl"}, -- Rollermine
		{"npc_seagull",				"models/Seagull.mdl"}, -- Seagull
		{"npc_stalker",				"models/stalker.mdl"}, -- Stalker
		{"npc_strider",				"models/combine_strider.mdl"}, -- Strider
		{"npc_turret_floor",		"models/Combine_turrets/Floor_turret.mdl"}, -- Floor Turret
		{"npc_vortigaunt",			"models/vortigaunt.mdl"}, -- Vortigaunt
		{"npc_zombie",				"models/Zombie/Classic.mdl"}, -- Zombie
		{"npc_zombie_torso",		"models/Zombie/Classic_torso.mdl"}, -- Zombie Torso
		
		// ARMED NPCS
		{"npc_citizen",			"models/Humans/Group03/Male_01.mdl", 		{"weapon_pistol", "weapon_shotgun", "weapon_smg1"}}, -- Citizen
		{"npc_citizen",			"models/Humans/Group03/Female_01.mdl", 		{"weapon_ar2","weapon_pistol", "weapon_shotgun", "weapon_smg1"}}, -- Citizen
		{"npc_metropolice",		"models/Police.mdl",						{"weapon_pistol", "weapon_stunstick", "weapon_smg1"}}, -- Metropolice
		{"npc_combine_s",		"models/Combine_Soldier.mdl", 				{"weapon_shotgun", "weapon_ar2", "weapon_smg1"}}, -- Combine Soldier
		{"npc_monk",			"models/monk.mdl",							{"weapon_annabelle"}}, -- Father Gregori
		{"npc_alyx",			"models/Alyx.mdl",							{"weapon_alyxgun"}}, -- Alyx
		
		// WEAPONS
		{"weapon_357",			"models/weapons/w_357.mdl"}, -- Magnum
		{"weapon_ar2",			"models/weapons/w_IRifle.mdl"}, -- AR2
		{"weapon_bugbait",		"models/weapons/w_bugbait.mdl"}, -- Bugbait
		{"weapon_crossbow",		"models/weapons/W_crossbow.mdl"}, -- Crossbow
		{"weapon_crowbar",		"models/weapons/W_crowbar.mdl"}, -- Crowbar
		{"weapon_frag",			"models/weapons/w_grenade.mdl"}, -- Frag
		{"weapon_pistol",		"models/weapons/w_pistol.mdl"}, -- Pistol
		{"weapon_rpg",			"models/weapons/w_rocket_launcher.mdl"}, -- RPG
		{"weapon_rpg",			"models/weapons/w_rocket_launcher.mdl"}, -- RPG
		{"weapon_shotgun",		"models/weapons/w_shotgun.mdl"}, -- Shotgun
		{"weapon_smg1",			"models/weapons/w_smg1.mdl"}, -- SMG
		{"weapon_stunstick",	"models/weapons/w_stunbaton.mdl"}, -- Stunstick
		
		// WEAPONS
		{"weapon_357",			"models/weapons/w_357.mdl"}, -- Magnum
		{"weapon_ar2",			"models/weapons/w_IRifle.mdl"}, -- AR2
		{"weapon_bugbait",		"models/weapons/w_bugbait.mdl"}, -- Bugbait
		{"weapon_crossbow",		"models/weapons/W_crossbow.mdl"}, -- Crossbow
		{"weapon_crowbar",		"models/weapons/W_crowbar.mdl"}, -- Crowbar
		{"weapon_frag",			"models/weapons/w_grenade.mdl"}, -- Frag
		{"weapon_pistol",		"models/weapons/w_pistol.mdl"}, -- Pistol
		{"weapon_rpg",			"models/weapons/w_rocket_launcher.mdl"}, -- RPG
		{"weapon_shotgun",		"models/weapons/w_shotgun.mdl"}, -- Shotgun
		{"weapon_smg1",			"models/weapons/w_smg1.mdl"}, -- SMG
		{"weapon_stunstick",	"models/weapons/w_stunbaton.mdl"} -- Stunstick
	}
	for k,v in pairs(Catchphrase) do
		print("Precaching "..v[2])
		util.PrecacheModel( v[2] )
	end
	

game.ConsoleCommand( "sk_max_alyxgun 25\n")
game.ConsoleCommand( "sk_npc_dmg_alyxgun 1.5\n")
game.ConsoleCommand( "sk_plr_dmg_alyxgun 2.5\n")
game.ConsoleCommand( "sk_barnacle_health 35\n")
game.ConsoleCommand( "sk_barney_health 35\n")
game.ConsoleCommand( "sk_bullseye_health 35\n")
game.ConsoleCommand( "sk_citizen_health 15\n")
game.ConsoleCommand( "sk_combine_s_health 50\n")
game.ConsoleCommand( "sk_combine_s_kick 20\n")
game.ConsoleCommand( "sk_combine_guard_health 70\n")
game.ConsoleCommand( "sk_combine_guard_kick 30\n")
game.ConsoleCommand( "sk_strider_health 350\n")
game.ConsoleCommand( "sk_strider_num_missiles1 5\n")
game.ConsoleCommand( "sk_strider_num_missiles2 7\n")
game.ConsoleCommand( "sk_strider_num_missiles3 7\n")
game.ConsoleCommand( "sk_headcrab_health 10\n")
game.ConsoleCommand( "sk_headcrab_melee_dmg 5\n")
game.ConsoleCommand( "sk_headcrab_fast_health 10\n")
game.ConsoleCommand( "sk_headcrab_poison_health 35\n")
game.ConsoleCommand( "sk_manhack_health 25\n")
game.ConsoleCommand( "sk_manhack_melee_dmg 30\n")
game.ConsoleCommand( "sk_metropolice_health 40\n")
game.ConsoleCommand( "sk_metropolice_stitch_reaction 1.0\n")
game.ConsoleCommand( "sk_metropolice_stitch_tight_hitcount 2\n")
game.ConsoleCommand( "sk_metropolice_stitch_at_hitcount 1\n")
game.ConsoleCommand( "sk_metropolice_stitch_behind_hitcount 3\n")
game.ConsoleCommand( "sk_metropolice_stitch_along_hitcount 2\n")
game.ConsoleCommand( "sk_rollermine_shock 20\n")
game.ConsoleCommand( "sk_rollermine_stun_delay 3\n")
game.ConsoleCommand( "sk_rollermine_vehicle_intercept 2\n")
game.ConsoleCommand( "sk_scanner_health 30\n")
game.ConsoleCommand( "sk_scanner_dmg_dive 25\n")
game.ConsoleCommand( "sk_stalker_health 50\n")
game.ConsoleCommand( "sk_stalker_melee_dmg 10\n")
game.ConsoleCommand( "sk_vortigaunt_health 100\n")
game.ConsoleCommand( "sk_vortigaunt_dmg_claw 10\n")
game.ConsoleCommand( "sk_vortigaunt_dmg_rake 25\n")
game.ConsoleCommand( "sk_vortigaunt_dmg_zap 50\n")
game.ConsoleCommand( "sk_vortigaunt_armor_charge 30\n")
game.ConsoleCommand( "sk_zombie_health 50\n")
game.ConsoleCommand( "sk_zombie_dmg_one_slash 25\n")
game.ConsoleCommand( "sk_zombie_dmg_both_slash 50\n")
game.ConsoleCommand( "sk_zombie_poison_health 175\n")
game.ConsoleCommand( "sk_zombie_poison_dmg_spit 20\n")
game.ConsoleCommand( "sk_antlion_health 30\n")
game.ConsoleCommand( "sk_antlion_swipe_damage 5\n")
game.ConsoleCommand( "sk_antlion_jump_damage 5\n")
game.ConsoleCommand( "sk_antlionguard_health 500\n")
game.ConsoleCommand( "sk_antlionguard_dmg_charge 20\n")
game.ConsoleCommand( "sk_antlionguard_dmg_shove 10\n")
game.ConsoleCommand( "sk_ichthyosaur_health 200\n")
game.ConsoleCommand( "sk_ichthyosaur_melee_dmg 8\n")
game.ConsoleCommand( "sk_gunship_burst_size 15\n")
game.ConsoleCommand( "sk_gunship_health_increments 5\n")
game.ConsoleCommand( "sk_npc_dmg_gunship 40\n")
game.ConsoleCommand( "sk_npc_dmg_gunship_to_plr 5\n")
game.ConsoleCommand( "sk_npc_dmg_helicopter  6\n")
game.ConsoleCommand( "sk_npc_dmg_helicopter_to_plr 4\n")
game.ConsoleCommand( "sk_helicopter_grenadedamage 30\n")
game.ConsoleCommand( "sk_helicopter_grenaderadius 275\n")
game.ConsoleCommand( "sk_helicopter_grenadeforce 55000\n")
game.ConsoleCommand( "sk_npc_dmg_dropship 2\n")
game.ConsoleCommand( "sk_apc_health 750\n")
