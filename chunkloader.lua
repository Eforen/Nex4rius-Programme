-- Robot programm to load the chunk on active redstone signal (eg. white signal from stargate programm)

serverAddresse = "https://raw.githubusercontent.com/DarknessShadow/Stargate-Programm/"
versionTyp = "master/"

Pfad = serverAddresse .. versionTyp
os.execute("wget -f " .. Pfad .. "chunkloader.lua chunkloader.lua")
os.execute("wget -f " .. Pfad .. "stargate/sprache.lua sprache.lua")

Sprache = "deutsch"
dofile("sprache.lua")

print(pruefeKomponenten)
if component.isAvailable("redstone") then
  print(redstoneOK)
  r = component.getPrimary("redstone")
  aktiv = true
--  while aktiv true do
    
--  end
else
  print(redstoneFehlt)
end