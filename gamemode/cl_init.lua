// GAMEMODE CLIENTSIDE INIT

include( 'shared.lua' )
include( 'helpmenu.lua' )
include( 'cl_numslider.lua' )

language.Add ("fishing_hook", "Fishing Hook")
language.Add ("fishing_rod", "Fishing Rod")
language.Add ("fishing_bait", "Fishing Bait")
language.Add ("npc_helicopter", "Helicopter")
language.Add ("npc_combinegunship", "Gunship")
language.Add ("prop_physics_multiplayer", "Prop")

local color = Color(50, 178, 255, 255)
local colorbg = Color(50, 50, 50, 100)
local timervar = 0

local volume = CreateClientConVar("gofishmusicvolume", 50, true) -- Default 50%
local soundfile = Sound([[gofish/music.mp3]])

function Fade( a, b, frac )
	local res, me
	res = Color( 0, 0, 0, 0 )
	me = ( 1 - frac )
	res.r = ( a.r * me ) + ( b.r * frac )
	res.g = ( a.g * me ) + ( b.g * frac )
	res.b = ( a.b * me ) + ( b.b * frac )
	res.a = ( a.a * me ) + ( b.a * frac )
	return res
end

function ScoreChanged( len, sent )
	local x = sent:ReadInt()
	if x < 0 then 
		color = Color(255, 0, 0, 255)
	else
		color = Color(255, 255, 255, 255)
	end
	timervar = CurTime()
end
net.Receive("ScoreChanged", ScoreChanged) 

function drawthehud()
	surface.SetFont( "TargetID" )
	
	local kk = (CurTime() - timervar) / 1
	if kk > 1 then kk = 1 elseif kk < 0 then kk = 0 end
	
	local text = "Your Score: ".. LocalPlayer():Frags( )
	local w, h = surface.GetTextSize( text )
	local x,y = ScrW()-(w+8), ScrH()/6
	
	draw.RoundedBox(16, x-8, 								y,w+8+100, 32, colorbg)
	draw.SimpleText(os.date("%X"), "TargetID", x+4+w/2 +1,	y+4 +1, Color(0, 0, 0, 100), 1, 0)  
	draw.SimpleText(os.date("%X"), "TargetID", x+4+w/2,		y+4, Color(50, 178, 255, 255), 1, 0)  

	draw.RoundedBox(16, x-8,								y+h+16, w+8+100, 32, Fade( color, colorbg, kk ) )
	draw.SimpleText(text, "TargetID", x+4+w/2 +1,			y+h+16+4 +1, Color(0, 0, 0, 100), 1, 0)  
	draw.SimpleText(text, "TargetID", x+4+w/2,				y+h+16+4, Color(50, 178, 255, 255), 1, 0)  

	draw.RoundedBox(16, x-8,								y-h-16, w+8+100, 32, colorbg )
	draw.SimpleText("[F1] for Help", "TargetID", x+4+w/2 +1,		y-h-16+4 +1, Color(0, 0, 0, 100), 1, 0)  
	draw.SimpleText("[F1] for Help", "TargetID", x+4+w/2,		y-h-16+4, Color(50, 178, 255, 255), 1, 0)  
end
hook.Add("HUDPaint", "drawthehud", drawthehud) 

local soundplaying = soundplaying or false



function startthebloodynoise( len, sent )
	--print("Received message.")
	timer.Create("GoFishAmbientTimer",2*60+42,0, function() 
			LocalPlayer():EmitSound( soundfile, volume:GetInt(), 100 )
			soundplaying = true
		end)
	LocalPlayer():EmitSound( soundfile, volume:GetInt(), 100 )
	soundplaying = true
end
net.Receive("startthebloodynoise", startthebloodynoise)  

local PANEL = {}
AccessorFunc( PANEL, "m_bDraggable", 		"Draggable", 		FORCE_BOOL ) 
AccessorFunc( PANEL, "m_bSizable", 			"Sizable", 			FORCE_BOOL ) 
AccessorFunc( PANEL, "m_bScreenLock", 		"ScreenLock", 		FORCE_BOOL ) 
AccessorFunc( PANEL, "m_bDeleteOnClose", 	"DeleteOnClose", 	FORCE_BOOL ) 
AccessorFunc( PANEL, "m_bBackgroundBlur", 	"BackgroundBlur", 	FORCE_BOOL )

/*function PANEL:Init()
	ply = LocalPlayer()
	
 	self:SetFocusTopLevel( true ) 
 	self.lblTitle = vgui.Create( "DLabel", self ) 
	self:SetDraggable( true ) 
 	self:SetSizable( false ) 
 	self:SetScreenLock( true ) 
 	self:SetDeleteOnClose( true )
 	--self:ShowCloseButton(true)
 	self.lblTitle:SetText( "" )
 	 
 	/*self.btnClose = vgui.Create( "DSysButton", self ) 
 	self.btnClose:SetType( "close" ) 
 	self.btnClose.DoClick = function ( button ) self:Close() end 
 	self.btnClose:SetDrawBorder( false ) 
 	self.btnClose:SetDrawBackground( false ) 
	self.btnClose:SetVisible( false )
	 
 	// This turns off the engine drawing 
 	self:SetPaintBackgroundEnabled( false ) 
 	self:SetPaintBorderEnabled( false ) 
 	self.m_fCreateTime = SysTime() 
	
	
 	self.rod = vgui.Create( "SpawnIcon", self ) 
 	self.rod:SetModel( "models/props_junk/harpoon002a.mdl", 0 )
 	self.rod:SetSize( 64 ) 
	self.rod.DoClick = function() ply:ConCommand("say !rod") end
	--self.rod:SetToolTip( Format( "%s", "Create a fishing rod" ) ) 


 	self.hook = vgui.Create( "SpawnIcon", self ) 
 	self.hook:SetModel( "models/props_junk/meathook001a.mdl", 0 )
 	self.hook:SetSize( 64 ) 
	self.hook.DoClick = function() ply:ConCommand("say !hook") end
	--self.hook:SetToolTip( Format( "%s", "Create a fishing hook" ) ) 


 	self.bait = vgui.Create( "SpawnIcon", self ) 
 	self.bait:SetModel( "models/weapons/w_bugbait.mdl", 0 )
 	self.bait:SetSize( 64 ) 
	self.bait.DoClick = function() ply:ConCommand("say !bait") end
	--self.bait:SetToolTip( Format( "%s", "Create a bait" ) ) 

	
	self.volume = vgui.Create( "NewNumSlider", self )
	self.volume:SetText( "        Music Volume" )
	self.volume:SetMin( 0 ) // Minimum number of the slider
	self.volume:SetMax( 100 ) // Maximum number of the slider
	self.volume:SetDecimals( 0 ) // Sets a decimal. Zero means it's a whole number
	self.volume:SetConVar( "gofishmusicvolume" ) // Set the convar 
	self.volume.OnValueChanged = function( val )   
		if volume:GetInt() != self.volume:GetValue() then
			self.volume:SetText( "        Restart music to apply volume!" )
		end
	end
	
	/*self.play = vgui.Create("DSysButton", self)
	self.play:SetType( "up" )
	self.play:SetSize( 20, 20 )
	
	self:InvalidateLayout( true )
	

end

function PANEL:Close() 
	self:SetVisible( false ) 
	self:Remove() 
end

function PANEL:Paint() 
	local w = 8 + 64 + 8 + 64 + 8 + 64 +  8
	local h = 8 + 64 + 8 + 32 + 8
	draw.RoundedBox( 8, 0, 0, w, h, Color(150, 150, 150, 255) )
	draw.RoundedBox( 8, 0+3, 0+3, w-6, h-6, Color(50, 50, 50, 255) )
end 

function PANEL:PerformLayout()
	local w = 8 + 64 + 8 + 64 + 8 + 64 +  8
	local h = 8 + 64 + 8 + 32 + 8
	
	self.rod:SetPos(8, 8)
	self.hook:SetPos( 8 + self.rod:GetWide() + 8, 8 )
	self.bait:SetPos( 8 + self.rod:GetWide() + 8 + 64 + 8, 8)
	
	self.volume:SetSize( w - 16, 32 )
	self.volume:SetPos( 8, 64 +16 )
	
	/*self.play:SetPos( 8, 64 +16 )
	
	if soundplaying == true then
		self.play:SetText( "g" )
		self.play.DoClick = function()
				LocalPlayer():ConCommand( "stopsounds\n" )
				soundplaying = false
				timer.Remove("GoFishAmbientTimer")
				--startthebloodynoise()
				self:InvalidateLayout( true )
			end
		self.volume:SetText( "        Playing..." )
	elseif soundplaying == false then
		self.play:SetType( "right" )
		self.play.DoClick = function()
			startthebloodynoise()
			self:InvalidateLayout( true )
			end
		self.volume:SetText( "        Stopped." )
	end
	
	self:SetSize( w, h )
	--DFrame.PerformLayout( self )
end 

local vguiExampleWindow = vgui.RegisterTable( PANEL, "EditablePanel" )  
local THEFISHINGMENU = nil

function SpawnMenuOpen()
	if ( THEFISHINGMENU and THEFISHINGMENU:IsValid() ) then return end -- Don't open a new window if one is already up.
 	THEFISHINGMENU = vgui.CreateFromTable( vguiExampleWindow ) 
 	THEFISHINGMENU:MakePopup()
 	THEFISHINGMENU:Center()
 	
 	THEFISHINGMENU:Center()
 	local x,y = THEFISHINGMENU:GetPos()
 	THEFISHINGMENU:SetPos(x,y+100)
	return false
end

function SpawnMenuClose()
	if not ( THEFISHINGMENU and THEFISHINGMENU:IsValid() ) then return end
 	THEFISHINGMENU:Close()
	return false
end

concommand.Add( "+menu", SpawnMenuOpen )
concommand.Add( "-menu", SpawnMenuClose )*/
