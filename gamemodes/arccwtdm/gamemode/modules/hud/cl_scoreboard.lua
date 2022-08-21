local SCORE_B = Color(0, 0, 0, 127)
local SCORE_W = Color(255, 255, 255, 255)
local SCORE_BG = Color(41*1, 46*1, 76*1, 200)

local SHOWSCORE2 = false
local SCORE_FADE = 0
local dead = Material("tdm/dead.png", "smooth")
local dead_glow = Material("tdm/dead_glow.png", "smooth")

if Pixie then Pixie:Remove() end
Pixie = nil

local playee = {}
for i=1, 20 do
	local teeam = math.random(1, 3)
	table.insert(playee, {
		Name = "Subject #" .. i,
		Score = i * 10000,
		Kills = 100,
		Deaths = 100,
		Ping = 500,
		Team = teeam == 1 and 1 or teeam == 2 and 2 or 1002,
		Entity = NULL,
	})
end

local pliskin = {}

hook.Add("ScoreboardShow", "TDMScore2_ScoreboardShow", function()
	SHOWSCORE2 = true

	if Pixie then
		Pixie:SetMouseInputEnabled( true )
	end

	return true
end)

hook.Add("ScoreboardHide", "TDMScore2_ScoreboardHide", function()
	SHOWSCORE2 = false

	if Pixie then
		Pixie:SetMouseInputEnabled( false )
	end

	return true
end)

local tshow = {
	[1] = true,
	[2] = true,
	[1002] = true
}

local function ShadowText(text, font, x, y, color, t, l, glow)
	local c = CGSS(1)
	draw.SimpleText(text, font .. "_Shadow", x + (c*3), y + (c*3), SCORE_B, t, l)

	if glow then
		draw.SimpleText(text, font .. "_Glow", x, y, CLR_B, t, l)
		draw.SimpleText(text, font .. "_Glow", x, y, CLR_B, t, l)
	end

	draw.SimpleText(text, font, x, y, color, t, l)
end

local function ShadowBox(x, y, w, h, color)
	local c = CGSS(1)
	surface.SetDrawColor(SCORE_B)
	surface.DrawRect(x + (c*3), y + (c*3), w, h)
	surface.SetDrawColor(color)
	surface.DrawRect(x, y, w, h)
end

hook.Add("HUDDrawScoreBoard", "TDMScore2_HUDDrawScoreBoard", function()
	SCORE_FADE = math.Approach( SCORE_FADE, SHOWSCORE2 and 1 or 0, FrameTime() / 0.15 )
	SCORE_B.a = Lerp( SCORE_FADE, 0, 127 )
	SCORE_W.a = Lerp( SCORE_FADE, 0, 255 )
	SCORE_BG.a = Lerp( SCORE_FADE, 0, 200 )

	local c = CGSS(1)

	local brd = (c*12)
	local bbl = (c*20)

	-- Begin
	if SCORE_FADE > 0 then
		if !Pixie then
			-- create "pixie"
			Pixie = vgui.Create( "DFrame" )
			Pixie:SetSize( ScrW() - (c*32), ScrH() - (c*32) )
			Pixie:Center()
			Pixie:SetTitle( "" )
			Pixie:ShowCloseButton( false )
			Pixie:MakePopup()
			Pixie:SetDraggable( false )
			Pixie:SetSizable( false )
			Pixie:SetKeyboardInputEnabled( false )
			function Pixie:Paint(w, h)
				local bog_x, bog_y, bog_w, bog_h = 0, 0, w, h
				draw.RoundedBox( brd, bog_x, bog_y, bog_w, bog_h, SCORE_BG )
		
				ShadowText(GetHostName(), "CGHUD_3", bog_x + bbl, bog_y + bbl, SCORE_W, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				ShadowText(game.GetMap(), "CGHUD_5", bog_x + bbl, bog_y + bbl + (c*34), SCORE_W, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
				-- Middle bar
				ShadowBox(bog_x + (bog_w*0.5) - (c*2*0.5), bog_y + bbl, (c*2), bog_h - (bbl*2), SCORE_W)
		
				-- Middle left
				ShadowBox(bog_x + bbl, bog_y + (bog_h*0.5) - (c*2*0.5), (bog_w*0.5) - (bbl*2), (c*2), SCORE_W)

				for index, p in ipairs(player.GetAll()) do
					if !IsValid(pliskin[p]) then
						local Poncho = vgui.Create( "DButton", Pixie )
						pliskin[p] = Poncho
						Poncho.Player = p
						Poncho:SetSize( 9999, (c*28) )
						function Poncho:Paint(w, h)
							--ShadowBox(0, 0, w, h, SCORE_BG)
							local tc = team.GetColor(self.Player:Team())
							tc = Color( Lerp(0.5, 255, tc.r), Lerp(0.5, 255, tc.g), Lerp(0.5, 255, tc.b), Lerp( SCORE_FADE, 0, 255 ) )
							ShadowText(self.Player:Nick(), "CGHUD_5", (c*38), h*0.5, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
							return true
						end
						function Poncho:DoRightClick()
							local MenuButtonOptions = DermaMenu()
							MenuButtonOptions:AddOption( "hello", function() end )
							MenuButtonOptions:Open()
						end

						local Av = vgui.Create( "AvatarImage", Poncho )
						local ico = (c*28)
						Av:SetPlayer( p, 64 )
						Av:SetSize( ico, ico )
						Av:SetPos( 0, 0 + (Poncho:GetTall()*0.5) - (ico*0.5) )
					end
				end
				
				local ybump = 0
				for t, __ in pairs(tshow) do
					local tc = team.GetColor(t)
					tc = Color( Lerp(0.5, 255, tc.r), Lerp(0.5, 255, tc.g), Lerp(0.5, 255, tc.b), Lerp( SCORE_FADE, 0, 255 ) )
				end

				for t, __ in pairs(tshow) do
					local collect = {}
					for index, p in ipairs(player.GetAll()) do
						if p:Team() != t then continue end
						table.insert(collect, p)
					end

					if #collect > 0 then
						local tc = team.GetColor(t)
						tc = Color( Lerp(0.5, 255, tc.r), Lerp(0.5, 255, tc.g), Lerp(0.5, 255, tc.b), Lerp( SCORE_FADE, 0, 255 ) )
				
						ShadowText(team.GetName(t), "CGHUD_5", bog_x + (bog_w*0.5) + bbl, bog_y + bbl + ybump, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
						ybump = ybump + (c*28)
						ShadowBox(bog_x + (bog_w*0.5) + bbl, bog_y + bbl + ybump, (bog_w*0.5) - (bbl*2), (c*2), tc)
						ybump = ybump + (c*4)
			
						-- Draw user info
						for index, p in ipairs(collect) do
							--ShadowText(p:Nick(), "CGHUD_5", bog_x + (bog_w*0.5) + bbl, bog_y + bbl + ybump, tc, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
							if pliskin[p] then
								local bas = pliskin[p]
								bas:SetPos( bog_x + (bog_w*0.5) + bbl, bog_y + bbl + ybump )
							end
			
							-- Bump y
							if index == #collect then
								ybump = ybump + (c*30)
							else
								ybump = ybump + (c*30)
							end
						end
					end
				end
		
				ShadowText("Domination", "CGHUD_3", bog_x + bbl, bog_y + (bog_h*0.5) + bbl, SCORE_W, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				ShadowText("Winning 1000 to 100", "CGHUD_4", bog_x + bbl, bog_y + (bog_h*0.5) + bbl + (c*34), SCORE_W, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				ShadowText("10000 points to win", "CGHUD_5", bog_x + bbl, bog_y + (bog_h*0.5) + bbl + (c*62), SCORE_W, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
		end
	else
		if Pixie then
			Pixie:Remove()
			Pixie = nil
		end
	end
end)