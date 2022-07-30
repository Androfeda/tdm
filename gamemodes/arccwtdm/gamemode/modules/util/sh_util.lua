local CLR_B = Color(0, 0, 0, 255)

function GM:ShadowText(text, font, x, y, color, color2, t, l, glow)
	draw.SimpleText(text, font .. "_Shadow", x + CGSS(2), y + CGSS(2), color2, t, l)

	if glow then
		draw.SimpleText(text, font .. "_Glow", x, y, CLR_B, t, l)
		draw.SimpleText(text, font .. "_Glow", x, y, CLR_B, t, l)
	end

	draw.SimpleText(text, font, x, y, color, t, l)
end