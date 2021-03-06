-- pastebin run -f YVqKFnsP
-- nexDHD von Nex4rius
-- https://github.com/Nex4rius/Nex4rius-Programme/tree/master/nexDHD

os.sleep(1)

OC = nil
CC = nil
if require then
  OC = true
  require("shell").setWorkingDirectory("/")
else
  CC = true
  local monitor = peripheral.find("monitor")
  if not monitor then
    print("keinen >Advanced Monitor< gefunden")
  end
  term.redirect(monitor)
  monitor.setTextScale(0.5)
  monitor.setCursorPos(1, 1)
end

local io                     = io
_G.io = io
local shell                  = shell or require("shell")
_G.shell = shell
local fs                     = fs or require("filesystem")
local term                   = term or require("term")
local schreibSicherungsdatei = loadfile("/stargate/schreibSicherungsdatei.lua")
local Farben                 = loadfile("/stargate/farben.lua") or {}
local betaVersionName        = ""
local Sicherung              = {}
local f                      = {}
local component              = {}
local gpu                    = {}
local version
local arg                    = ...

term.clear()

if type(Farben) == "function" then
  Farben = Farben(Sicherung.Theme, OC, CC)
end

if arg then
  arg                        = string.lower(tostring(arg))
end

if OC then
  component = require("component")
  gpu = component.getPrimary("gpu")
  local a = gpu.setForeground
  local b = gpu.setBackground
  gpu.setForeground = function(code) if code then a(code) end end
  gpu.setBackground = function(code) if code then b(code) end end
  pcall(component.getPrimary("screen").setTouchModeInverted, false)
elseif CC then
  component.getPrimary = peripheral.find
  component.isAvailable = function(name)
    cc_immer = {}
    cc_immer.internet = function() return http end
    cc_immer.redstone = function() return true end
    if cc_immer[name] then
      return cc_immer[name]()
    end
    return peripheral.find(name)
  end
  gpu = component.getPrimary("monitor")
  term.redirect(gpu)
  gpu.setResolution = function() gpu.setTextScale(0.5) end
  gpu.setForeground = function(code) if code then gpu.setTextColor(code) end end
  gpu.setBackground = function(code) if code then gpu.setBackgroundColor(code) end end
  gpu.maxResolution = gpu.getSize
  gpu.fill = function() term.clear() end
  fs.remove = fs.remove or fs.delete
end

if gpu.maxResolution() < 80 then
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  local a = gpu.setForeground
  local b = gpu.setBackground
  gpu.setForeground = function(...) if gpu.maxResolution() >= 80 then a(...) end end
  gpu.setBackground = function(...) if gpu.maxResolution() >= 80 then b(...) end end
  term.clear()
end

local function kopieren(a, b, c)
  if type(a) == "string" and type(b) == "string" then
    if c == "-n" then
      fs.remove(b)
    end
    if fs.exists(a) and not fs.exists(b) then
      fs.copy(a, b)
    end
    return true
  end
end

local wget = loadfile("/bin/wget.lua") or function(option, url, ziel)
  if type(url) ~= "string" and type(ziel) ~= "string" then
    return
  elseif type(option) == "string" and option ~= "-f" and type(url) == "string" then
    ziel = url
    url = option
  end
  if http.checkURL(url) then
    if fs.exists(ziel) and option ~= "-f" then
      printError("<Fehler> Ziel existiert bereits")
      return
    else
      local timer = os.startTimer(30)
      http.request(url)
      while true do
        local event, id, data = os.pullEvent()
        if event == "http_success" then
          local d = io.open(ziel, "w")
          d:write(data.readAll())
          d:close()
          data:close()
          return true
        elseif event == "timer" and timer == id then
          printError("<Fehler> Zeitueberschreitung")
          return
        elseif event == "http_failure" then
          printError("<Fehler> Download")
          os.cancelAlarm(timer)
          return
        end
      end
    end
  else
    printError("<Fehler> URL")
    return
  end
end

function f.Pfad(versionTyp)
  if type(versionTyp) ~= "string" then
    return "https://raw.githubusercontent.com/Nex4rius/Nex4rius-Programme/master/nexDHD/"
  elseif versionTyp == "beta" then
    return "https://raw.githubusercontent.com/Nex4rius/Nex4rius-Programme/nexDHD/nexDHD/"
  else
    return "https://raw.githubusercontent.com/Nex4rius/Nex4rius-Programme/" .. versionTyp .. "/nexDHD/"
  end
end

function f.checkSprache()
  if Sicherung.Sprache and Sicherung.Sprache ~= "" then
    if fs.exists("/stargate/sprache/" .. Sicherung.Sprache .. ".lua") then
      return true
    elseif wget("-fQ", f.Pfad(versionTyp) .. "stargate/sprache/" .. Sicherung.Sprache .. ".lua", "/stargate/sprache/" .. Sicherung.Sprache .. ".lua") then
      return true
    end
  else
    local alleSprachen = {}
    local j = 1
    if OC then
      for i in fs.list("/stargate/sprache") do
        local Ende = string.len(i)
        i = string.sub(i, 1, Ende - 4)
        if i ~= "ersetzen" then
          alleSprachen[j] = i
          j = j + 1
        end
      end
    elseif CC then
      for k, i in pairs(fs.list("/stargate/sprache")) do
        local Ende = string.len(i)
        i = string.sub(i, 1, Ende - 4)
        if i ~= "ersetzen" then
          alleSprachen[j] = i
          j = j + 1
        end
      end
    end
    local weiter = true
    while weiter do
      print("Sprache? / Language?")
      for i in pairs(alleSprachen) do
        io.write(alleSprachen[i] .. "   ")
      end
      io.write("\n\n")
      antwortFrageSprache = string.lower(tostring(io.read()))
      for i in pairs(alleSprachen) do
        if antwortFrageSprache == alleSprachen[i] then
          weiter = false
          break
        end
      end
    end
    Sicherung.Sprache = antwortFrageSprache
    schreibSicherungsdatei(Sicherung)
    print("")
    return true
  end
end

function f.checkOpenOS()
  if OC then
    local OpenOS_Version = "OpenOS 1.7.4"
    if wget("-fQ", "https://raw.githubusercontent.com/Nex4rius/Nex4rius-Programme/master/OpenOS-Version", "/einstellungen/OpenOS-Version") then
      local d = io.open("/einstellungen/OpenOS-Version", "r")
      OpenOS_Version = d:read()
      d:close()
    end
    local disk = component.proxy(fs.get("/").address)
    if _OSVERSION == OpenOS_Version then
      gpu.setForeground(Farben.hellgrueneFarbe)
      print("\nOpenOS Version:        " .. _OSVERSION)
    elseif (disk.spaceTotal() - disk.spaceUsed()) / 1024 > 550 and not (arg == sprachen.nein or arg == "nein" or arg == "no") then
      local function split(...)
        local output = {}
        for i = 1, string.len(...) do
          output[i] = string.sub(..., i, i)
        end
        return output
      end
      local Version_neu = split(OpenOS_Version)
      local Version_alt = split(_OSVERSION)
      local neuer
      for i in pairs(Version_neu) do
        if Version_alt[i] ~= Version_neu[i] then
          if type(Version_alt[i]) == "number" and type(Version_neu[i]) == "number" then
            if Version_neu[i] > Version_alt[i] then
              neuer = true
            end
          else
            neuer = true
          end
        end
      end
      gpu.setForeground(Farben.roteFarbe)
      print("\nOpenOS Version:        " .. _OSVERSION .. " -> " .. OpenOS_Version .. "\n")
      if neuer and component.isAvailable("internet") and true == false then -- deaktiviert
        if Sicherung.autoUpdate then
          print("Update OpenOS")
          os.sleep(3)
          if wget("-fQ", "https://raw.githubusercontent.com/Nex4rius/Nex4rius-Programme/master/OpenOS-Updater/updater.lua", "/updater.lua") then
            loadfile("/updater.lua")()
            return
          end
        end
        print("Update OpenOS? [j/N]")
        term.write("Input: ")
        local eingabe = string.lower(io.read())
        if eingabe == sprachen.ja or eingabe == "ja" or eingabe == "yes" or eingabe == "y" or eingabe == "j" then
          if wget("-fQ", "https://raw.githubusercontent.com/Nex4rius/Nex4rius-Programme/master/OpenOS-Updater/updater.lua", "/updater.lua") then
            loadfile("/updater.lua")()
          end
        end
      end
    else
      gpu.setForeground(Farben.roteFarbe)
      print("\nOpenOS Version:        " .. _OSVERSION .. " -> " .. OpenOS_Version)
    end
    gpu.setForeground(Farben.weisseFarbe)
  elseif CC then
    print("\nCraftOS Version:       " .. os.version())
  end
end

function f.checkKomponenten()
  term.clear()
  print(sprachen.pruefeKomponenten or "Prüfe Komponenten\n")
  local function check(eingabe)
    if component.isAvailable(eingabe[1]) then
      gpu.setForeground(Farben.hellgrueneFarbe)
      print(eingabe[2])
    else
      gpu.setForeground(Farben.roteFarbe)
      print(eingabe[3])
    end
  end
  local alleKomponenten = {
    {"internet",      sprachen.InternetOK,  sprachen.InternetFehlt},
    {"world_sensor",  sprachen.SensorOK,    sprachen.SensorFehlt},
    {"colorful_lamp", sprachen.LampeOK,     sprachen.LampeFehlt},
    {"redstone",      sprachen.redstoneOK,  sprachen.redstoneFehlt},
    {"stargate",      sprachen.StargateOK,  sprachen.StargateFehlt},
  }
  for i in pairs(alleKomponenten) do
    check(alleKomponenten[i])
  end
  if component.isAvailable("redstone") then
    r = component.getPrimary("redstone")
  else
    r = nil
  end
  if component.isAvailable("modem") and component.getPrimary("modem").isWireless() then
    gpu.setForeground(Farben.hellgrueneFarbe)
    print(sprachen.modemOK)
  else
    gpu.setForeground(Farben.roteFarbe)
    print(sprachen.modemFehlt)
  end
  if gpu.maxResolution() == 80 or gpu.maxResolution() == 79 then
    gpu.setForeground(Farben.hellgrueneFarbe)
    print(sprachen.gpuOK2T)
  elseif gpu.maxResolution() == 160 then
    gpu.setForeground(Farben.orangeFarbe)
    print(sprachen.gpuOK3T)
  else
    gpu.setForeground(Farben.roteFarbe)
    print(sprachen.gpuFehlt)
  end
  local x, y = component.proxy(gpu.getScreen()).getAspectRatio()
  if x == 4 and y == 3 then
    if gpu.maxResolution() >= 80 then
      gpu.setForeground(Farben.hellgrueneFarbe)
      print(sprachen.BildschirmOK)
    else
      print(sprachen.BildschirmT1)
    end
  elseif gpu.maxResolution() >= 80 then
    gpu.setForeground(Farben.hellgrueneFarbe)
    print(sprachen.BildschirmFalsch(x, y))
  else
    gpu.setForeground(Farben.roteFarbe)
    print(sprachen.BildschirmFalschT1(x, y))
  end
  gpu.setForeground(Farben.weisseFarbe)
  if component.isAvailable("stargate") then
    sg = component.getPrimary("stargate")
    if sg.energyToDial(sg.localAddress()) then
      return true
    else
      gpu.setForeground(Farben.roteFarbe)
      print()
      print(sprachen.StargateNichtKomplett or "Stargate ist funktionsunfähig")
      gpu.setForeground(Farben.weisseFarbe)
      os.sleep(5)
      return
    end
  else
    os.sleep(5)
    return
  end
end

function f.update(versionTyp, a)
  if type(a) == "table" then
    Sicherung = a
  end
  if versionTyp == nil then
    versionTyp = "master"
  end
  if wget("-f", f.Pfad(versionTyp) .. "installieren.lua", "/installieren.lua") then
    Sicherung.installieren = true
    if schreibSicherungsdatei(Sicherung) then
      local d = io.open ("/autorun.lua", "w")
      d:write('loadfile("/installieren.lua")("' .. versionTyp .. '")')
      d:close()
      loadfile("/autorun.lua")()
    else
      print(sprachen.fehlerName or "<FEHLER>")
    end
  elseif versionTyp == "master" then
    wget("-f", f.Pfad(versionTyp) .. "installieren.lua", "/installieren.lua")
    loadfile("/installieren.lua")()
  end
  os.exit()
end

function f.checkServerVersion(branch)
  local branch = branch or "master"
  gpu.setForeground(Farben.Hintergrundfarbe)
  if wget("-fQ", f.Pfad(branch) .. "stargate/version.txt", "/serverVersion.txt") then
    local d = io.open ("/serverVersion.txt", "r")
    serverVersion = d:read()
    d:close()
    local a = loadfile("/bin/rm.lua") or fs.delete
    a("/serverVersion.txt")
  else
    serverVersion = sprachen.fehlerName
  end
  gpu.setForeground(Farben.weisseFarbe)
  return serverVersion
end

function f.checkDateien()
  local d = io.open ("/bin/stargate.lua", "w")
  d:write('-- pastebin run -f YVqKFnsP\n')
  d:write('-- von Nex4rius\n')
  d:write('-- https://github.com/Nex4rius/Nex4rius-Programme/tree/master/nexDHD\n')
  d:write('\n')
  d:write('if not pcall(loadfile("/autorun.lua"), require("shell").parse(...)[1]) then\n')
  d:write('   loadfile("/bin/wget-lua")("-f", "https://raw.githubusercontent.com/Nex4rius/Nex4rius-Programme/master/GitHub-Downloader/github.lua", "/bin/github.lua")\n')
  d:write('   loadfile("/bin/github.lua")("Nex4rius", "Nex4rius-Programme", "master", "nexDHD")\n')
  d:write('end\n')
  d:close()
  local dateien = {
    "stargate/Kontrollprogramm.lua",
    "stargate/Sicherungsdatei.lua",
    "stargate/adressen.lua",
    "stargate/check.lua",
    "stargate/version.txt",
    "stargate/farben.lua",
    "stargate/schreibSicherungsdatei.lua",
    "stargate/chevron.lua",
    "stargate/sprache/ersetzen.lua",
  }
  if OC then
    table.insert(dateien, "autorun.lua")
    table.insert(dateien, "bin/stargate.lua")
  elseif CC then
    table.insert(dateien, "startup")
  end
  local sprachen = sprachen or {}
  for i in pairs(dateien) do
    if not fs.exists("/" .. dateien[i]) then
      io.write(sprachen.fehlerName or "<FEHLER>")
      print(" Datei fehlt: " .. dateien[i])
      if component.isAvailable("internet") then
        if not wget("-f", f.Pfad(versionTyp) .. dateien[i], "/" .. dateien[i]) then
          return
        end
      else
        return
      end
      os.sleep(1)
    end
  end
  if not fs.exists("/einstellungen") then
    fs.makeDirectory("/einstellungen")
  end
  if not fs.exists("/einstellungen/adressen.lua") then
    kopieren("-n", "/stargate/adressen.lua", "/einstellungen/adressen.lua")
  end
  if not fs.exists("/einstellungen/Sicherungsdatei.lua") then
    kopieren("-n", "/stargate/Sicherungsdatei.lua", "/einstellungen/Sicherungsdatei.lua")
  end
  local alleSprachen = {"deutsch", "english", "russian", "czech"}
  local neueSprache
  for k, v in pairs(alleSprachen) do
    if v == tostring(Sicherung.Sprache) then
      neueSprache = true
    end
  end
  if neueSprache then
    table.insert(alleSprachen, tostring(Sicherung.Sprache))
  end
  for i in pairs(alleSprachen) do
    if fs.exists("/stargate/sprache/" .. alleSprachen[i] .. ".lua") then
      return true
    elseif component.isAvailable("internet") then
      for i in pairs(alleSprachen) do
        if wget("-f", f.Pfad(versionTyp) .. "stargate/sprache/" .. alleSprachen[i] .. ".lua", "/stargate/sprache/" .. alleSprachen[i] .. ".lua") then
          return true
        end
      end
    end
  end
  print("<FEHLER> keine Sprachdatei gefunden")
  return
end

function f.mainCheck()
  if component.isAvailable("internet") then
    print(sprachen.derzeitigeVersion .. version or "\nDerzeitige Version:    " .. version)
    local serverVersion = f.checkServerVersion("master")
    local betaServerVersion = f.checkServerVersion("beta")
    print(sprachen.verfuegbareVersion .. serverVersion or "\nVerfügbare Version:    " .. serverVersion)
    if serverVersion == betaServerVersion then else
      print(sprachen.betaVersion .. betaServerVersion .. " BETA" or "Beta-Version:          " .. betaServerVersion .. " BETA")
      if betaServerVersion == sprachen.fehlerName then else
        betaVersionName = "/beta"
      end
    end
    if (arg == sprachen.ja or arg == "ja" or arg == "yes") and serverVersion ~= sprachen.fehlerName then
      print(sprachen.aktualisierenJa or "\nAktualisieren: Ja\n")
      f.update("master")
    elseif arg == "neu" then
      print(sprachen.neuinstallation or "\nNeuinstallation")
      wget("-f", f.Pfad(versionTyp) .. "installieren.lua", "/installieren.lua")
      loadfile("/installieren.lua")("neu")
    elseif arg == sprachen.nein or arg == "nein" or arg == "no" then
      -- nichts
    elseif arg == "beta" and betaServerVersion ~= sprachen.fehlerName then
      print(sprachen.aktualisierenBeta or "\nAktualisieren: Beta-Version\n")
      f.update("beta")
    elseif version ~= serverVersion or version ~= betaServerVersion then
      if Sicherung.installieren == false then
        local EndpunktVersion = string.len(version)
        if Sicherung.autoUpdate == true and version ~= serverVersion and string.sub(version, EndpunktVersion - 3, EndpunktVersion) ~= "BETA" and serverVersion ~= sprachen.fehlerName then
          print(sprachen.aktualisierenJa or "\nAktualisieren: Ja\n")
          f.update("master")
        elseif serverVersion ~= sprachen.fehlerName then
          print(sprachen.aktualisierenFrage .. betaVersionName .. "\n" or "\nAktualisieren? ja/nein" .. betaVersionName .. "\n")
          if Sicherung.autoUpdate and version ~= serverVersion then
            print(sprachen.autoUpdateAn or "automatische Aktualisierungen sind aktiviert")
            print()
            os.sleep(2)
            f.update("master")
          elseif Sicherung.autoUpdate and version == serverVersion then
            -- nichts
          else
            antwortFrage = io.read()
            if string.lower(antwortFrage) == sprachen.ja or string.lower(antwortFrage) == "ja" or string.lower(antwortFrage) == "yes" then
              print(sprachen.aktualisierenJa or "\nAktualisieren: Ja\n")
              f.update("master")
            elseif string.lower(antwortFrage) == "beta" then
              print(sprachen.aktualisierenBeta or "\nAktualisieren: Beta-Version\n")
              f.update("beta")
            else
              print(sprachen.aktualisierenNein .. antwortFrage or "\nAntwort: " .. antwortFrage)
            end
          end
        end
      end
    end
  end
  print("\nnexDHD")
  print(sprachen.laden or "\nLaden...")
  Sicherung.installieren = false
  schreibSicherungsdatei(Sicherung)
  if f.checkDateien() or not component.isAvailable("internet") then
    if fs.exists("/log") and component.isAvailable("keyboard") and Sicherung.debug then
      loadfile("/bin/edit.lua")("-r", "/log")
      loadfile("/bin/rm.lua")("/log")
    end
    local erfolgreich
    local grund = "nochmal"
    while grund == "nochmal" do
      erfolgreich, grund = pcall(loadfile("/stargate/Kontrollprogramm.lua"), f.update, f.checkServerVersion, version, Farben)
      if not erfolgreich then
        print("Kontrollprogramm.lua hat einen Fehler")
        print(grund)
      end
    end
  else
    print(string.format("%s\n%s %s/%s", sprachen.fehlerName, sprachen.DateienFehlen, sprachen.ja, sprachen.nein) or "\nAlles neu herunterladen? ja/nein")
    if Sicherung.autoUpdate then
      print(sprachen.autoUpdateAn or "automatische Aktualisierungen sind aktiviert")
      os.sleep(2)
      wget("-f", f.Pfad(versionTyp) .. "installieren.lua", "/installieren.lua")
      loadfile("/installieren.lua")()
    else
      antwortFrage = io.read()
      if string.lower(antwortFrage) == sprachen.ja or string.lower(antwortFrage) == "ja" or string.lower(antwortFrage) == "yes" then
        wget("-f", f.Pfad(versionTyp) .. "installieren.lua", "/installieren.lua")
        loadfile("/installieren.lua")()
      end
    end
  end
end

function f.main()
  os.sleep(0.5)
  pcall(gpu.setResolution, 70, 25)
  gpu.setForeground(Farben.weisseFarbe)
  gpu.setBackground(Farben.graueFarbe)
  f.checkDateien()
  if fs.exists("/stargate/version.txt") then
    local d = io.open ("/stargate/version.txt", "r")
    version = d:read()
    d:close()
  else
    version = sprachen.fehlerName
  end
  if fs.exists("/einstellungen/Sicherungsdatei.lua") then
    Sicherung = loadfile("/einstellungen/Sicherungsdatei.lua")()
  else
    Sicherung.installieren = false
  end
  if arg == "master" or arg == "beta" then
    versionTyp = arg
  end
  if f.checkSprache() then
    local neu = loadfile("/stargate/sprache/" .. Sicherung.Sprache .. ".lua")()
    sprachen = loadfile("/stargate/sprache/deutsch.lua")()
    for i in pairs(sprachen) do
      if neu[i] then
        sprachen[i] = neu[i]
      end
    end
    sprachen = sprachen or neu
  else
    print("\nUnbekannte Sprache\nStandardeinstellung = deutsch")
    if fs.exists("/stargate/sprache/deutsch.lua") then
      sprachen = loadfile("/stargate/sprache/deutsch.lua")()
    else
      print(sprachen.fehlerName or "<FEHLER>")
    end
  end
  if arg == sprachen.hilfe or arg == "hilfe" or arg == "help" or arg == "?" then
    gpu.setForeground(Farben.schwarzeFarbe)
    gpu.setBackground(Farben.weisseFarbe)
    print(sprachen.Hilfetext or [==[
      Verwendung: autorun [...]
      ja    -> Aktualisierung zur stabilen Version
      nein  -> keine Aktualisierung
      beta  -> Aktualisierung zur Beta-Version
      hilfe -> zeige diese Nachricht nochmal]==])
  else
    if f.checkKomponenten() then
      f.checkOpenOS()
      f.mainCheck()
    else
      print("\n")
      io.write(sprachen.fehlerName or "<FEHLER>")
      print(" kein Stargate")
      os.sleep(5)
    end
  end
  gpu.setForeground(Farben.weisseFarbe)
  gpu.setBackground(Farben.schwarzeFarbe)
  term.clear()
  gpu.setResolution(gpu.maxResolution())
end

f.main()
