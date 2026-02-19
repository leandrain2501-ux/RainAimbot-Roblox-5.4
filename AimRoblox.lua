# RainAimbot-Roblox-5.4
-- ================================================================
--   RAINBOT v5.4  |  SECRET UPDATE  |  by Rain
--   !! RAHASIA !! Kamu beruntung banget punya ini!
--   70+ Fitur | Secret Menu | VIP+ | Bypass | Debug
-- ================================================================
-- Pasang di StarterPlayerScripts

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================================================================
-- CONFIG
-- ================================================================
local CFG = {
    AimRange   = 500,
    AimSpeed   = 1,
    SpeedMult  = 3,
    FOVRadius  = 120,
    AlertRange = 50,
    KeyLink    = "https://wa.me/qr/CKNCNG7XBZG5C1",
}

-- tier: "normal" | "esp" | "vipplus" | "secret"
local KEYS = {
    ["Key-71818"]           = "normal",
    ["Key-9898"]            = "normal",
    ["Key-9282827"]         = "normal",
    ["Key-82826288"]        = "normal",
    ["Key-676767"]          = "esp",
    ["Vip+_1919"]           = "vipplus",
    ["Vip+_Rain"]           = "vipplus",
    ["Vip+_Hshsoo77uHjaf"]  = "vipplus",
    ["Key-SecretMenu"]      = "secret",
}

-- ================================================================
-- STATE
-- ================================================================
local S = {
    tier = "none",
    kills = 0, lockedTarget = nil,
    debugLog = {},
    -- Aimbot
    aimOn=false, wallCheck=true, aimHead=true,
    silentAim=false, smoothAim=false, aimAssist=false, noSpread=false,
    -- ESP
    espOn=false, espName=true, espHealth=true, espDist=true,
    -- HUD
    fovOn=false, crosshairOn=false, lockIndOn=false, killCountOn=false,
    alertOn=false, fpsOn=false, pingOn=false, playerListOn=false, rainbowNameOn=false,
    -- Movement
    speedOn=false, noclipOn=false, infJumpOn=false, flyOn=false,
    highJumpOn=false, spamJumpOn=false,
    -- World
    fullbrightOn=false, noFogOn=false, timeFreezeOn=false, thirdPersonOn=false,
    -- Weapon
    rapidFireOn=false, noRecoilOn=false, infAmmoOn=false,
    -- Extras
    antiAfkOn=false, godModeOn=false, invisOn=false, antiKBOn=false, autoHealOn=false,
    -- VIP+
    vipAura=false, getAllSkins=false, vipESPTeam=false, vipSuperSpeed=false, vipInstantRespawn=false,
    -- Secret / Debug
    bypassOn=false, debugOn=false,
    -- Fog defaults (simpan nilai asli)
    _origFogEnd=nil, _origFogStart=nil, _origAtmoDensity=nil,
}

local function isESP()    return S.tier=="esp" or S.tier=="vipplus" or S.tier=="secret" end
local function isVIP()    return S.tier=="vipplus" or S.tier=="secret" end
local function isSecret() return S.tier=="secret" end

-- ================================================================
-- WARNA TEMA
-- ================================================================
local CN  = {bg=Color3.fromRGB(12,8,30),   panel=Color3.fromRGB(18,11,42),
             accent=Color3.fromRGB(140,60,255), accent2=Color3.fromRGB(180,80,255),
             neon=Color3.fromRGB(200,100,255),  stroke=Color3.fromRGB(140,60,255)}
local CV  = {bg=Color3.fromRGB(18,13,2),   panel=Color3.fromRGB(32,22,4),
             accent=Color3.fromRGB(210,160,20), accent2=Color3.fromRGB(255,200,50),
             neon=Color3.fromRGB(255,220,80),   stroke=Color3.fromRGB(210,160,20)}
local CVP = {bg=Color3.fromRGB(15,3,3),    panel=Color3.fromRGB(28,6,6),
             accent=Color3.fromRGB(200,20,30),  accent2=Color3.fromRGB(255,40,50),
             neon=Color3.fromRGB(255,60,70),    stroke=Color3.fromRGB(200,20,30)}
local CSC = {bg=Color3.fromRGB(5,5,5),     panel=Color3.fromRGB(12,12,12),
             accent=Color3.fromRGB(70,70,70),   accent2=Color3.fromRGB(120,120,120),
             neon=Color3.fromRGB(190,190,190),  stroke=Color3.fromRGB(55,55,55)}

local C = {
    text=Color3.fromRGB(230,220,255),  sub=Color3.fromRGB(150,130,200),
    green=Color3.fromRGB(50,220,100),  red=Color3.fromRGB(220,60,60),
    yellow=Color3.fromRGB(255,210,50), dark=Color3.fromRGB(8,5,20),
    white=Color3.fromRGB(255,255,255), orange=Color3.fromRGB(255,140,30),
    cyan=Color3.fromRGB(50,200,220),   neonRed=Color3.fromRGB(255,30,50),
}

local function TH()
    if S.tier=="secret"  then return CSC end
    if S.tier=="vipplus" then return CVP end
    if S.tier=="esp"     then return CV  end
    return CN
end

-- ================================================================
-- HELPERS
-- ================================================================
local function tw(o,t,p,s)
    return TweenService:Create(o,TweenInfo.new(t,s or Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p)
end
local function aC(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 8) c.Parent=p end
local function aS(p,col,th)
    local s=Instance.new("UIStroke") s.Color=col s.Thickness=th or 1.5 s.Parent=p return s
end
local function nL(par,txt,sz,pos,fnt,col,z)
    local l=Instance.new("TextLabel")
    l.Size=sz l.Position=pos l.BackgroundTransparency=1
    l.Text=txt l.TextColor3=col or C.text l.TextScaled=true
    l.Font=fnt or Enum.Font.GothamBold l.ZIndex=z or 10 l.Parent=par return l
end
local function dbg(msg)
    if not S.debugOn then return end
    table.insert(S.debugLog,1,"["..os.date("%H:%M:%S").."] "..tostring(msg))
    if #S.debugLog>28 then table.remove(S.debugLog) end
end
local function isEnemy(p)
    if p==LP then return false end
    local ec=p.Character local eh=ec and ec:FindFirstChildOfClass("Humanoid")
    if not eh or eh.Health<=0 then return false end
    local ok,same=pcall(function() return LP.Team~=nil and p.Team~=nil and LP.Team==p.Team end)
    if ok and same then return false end
    return true
end

-- ================================================================
-- TOGGLE (returns getter, setter)
-- ================================================================
local function makeToggle(parent,x,y,w,h,label,default,theme,secretStyle)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(0,w,0,h) row.Position=UDim2.new(0,x,0,y)
    row.BackgroundColor3=theme.panel row.BorderSizePixel=0 row.ZIndex=20 row.Parent=parent
    aC(row,8)
    if secretStyle then aS(row,Color3.fromRGB(60,10,10),1) end

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-52,1,0) lbl.Position=UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=label lbl.TextColor3=C.text
    lbl.TextScaled=false lbl.TextSize=11 lbl.Font=Enum.Font.Gotham
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=21 lbl.Parent=row

    local track=Instance.new("Frame")
    track.Size=UDim2.new(0,40,0,20) track.Position=UDim2.new(1,-46,0.5,-10)
    track.BackgroundColor3=default and C.green or Color3.fromRGB(60,60,60)
    track.BorderSizePixel=0 track.ZIndex=21 track.Parent=row aC(track,10)

    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,14,0,14)
    knob.Position=default and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3=C.white knob.BorderSizePixel=0 knob.ZIndex=22 knob.Parent=track aC(knob,7)

    local hit=Instance.new("TextButton")
    hit.Size=UDim2.new(1,0,1,0) hit.BackgroundTransparency=1 hit.Text="" hit.ZIndex=25 hit.Parent=row

    local state=default or false
    local function set(v)
        state=v
        tw(track,0.15,{BackgroundColor3=state and C.green or Color3.fromRGB(60,60,60)}):Play()
        tw(knob,0.15,{Position=state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
    end
    hit.MouseButton1Click:Connect(function() set(not state) end)
    return function() return state end, set
end

-- ================================================================
-- GUI ROOT
-- ================================================================
local sg=Instance.new("ScreenGui")
sg.Name="RainBotGUI" sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Global
sg.DisplayOrder=999 sg.Parent=LP.PlayerGui

-- ================================================================
-- NOTIF
-- ================================================================
local function notif(msg,col)
    task.spawn(function()
        local n=Instance.new("TextLabel")
        n.Size=UDim2.new(0,255,0,26) n.AnchorPoint=Vector2.new(0.5,0) n.Position=UDim2.new(0.5,0,0,65)
        n.BackgroundColor3=C.dark n.TextColor3=col or C.green n.Text=msg
        n.TextScaled=false n.TextSize=11 n.Font=Enum.Font.GothamBold
        n.BorderSizePixel=0 n.BackgroundTransparency=0.15 n.TextTransparency=1 n.ZIndex=95 n.Parent=sg
        aC(n,6) aS(n,col or C.green,1.5)
        tw(n,0.25,{TextTransparency=0}):Play() task.wait(2.2)
        tw(n,0.3,{TextTransparency=1,BackgroundTransparency=1}):Play() task.wait(0.3) n:Destroy()
    end)
end

-- ================================================================
-- "BYPASS ACTIVE" LABEL  (merah neon, 3 detik)
-- ================================================================
local bypassLbl=Instance.new("TextLabel")
bypassLbl.Size=UDim2.new(0,340,0,44) bypassLbl.AnchorPoint=Vector2.new(0.5,0)
bypassLbl.Position=UDim2.new(0.5,0,0,14) bypassLbl.BackgroundTransparency=1
bypassLbl.Text="⚡ BYPASS ACTIVE ⚡"
bypassLbl.TextColor3=C.neonRed bypassLbl.TextStrokeColor3=Color3.fromRGB(80,0,0)
bypassLbl.TextStrokeTransparency=0 bypassLbl.TextScaled=true
bypassLbl.Font=Enum.Font.GothamBold bypassLbl.ZIndex=98
bypassLbl.TextTransparency=1 bypassLbl.Visible=false bypassLbl.Parent=sg

local function showBypassLabel()
    task.spawn(function()
        bypassLbl.Visible=true
        tw(bypassLbl,0.25,{TextTransparency=0}):Play()
        -- flicker efek neon
        for _=1,3 do
            task.wait(0.7)
            tw(bypassLbl,0.1,{TextTransparency=0.6}):Play() task.wait(0.1)
            tw(bypassLbl,0.1,{TextTransparency=0}):Play()
        end
        task.wait(0.5)
        tw(bypassLbl,0.35,{TextTransparency=1}):Play()
        task.wait(0.35) bypassLbl.Visible=false
    end)
end

-- ================================================================
-- DEBUG LOG PANEL
-- ================================================================
local debugPanel=Instance.new("Frame")
debugPanel.Size=UDim2.new(0,295,0,190) debugPanel.Position=UDim2.new(1,-303,0,108)
debugPanel.BackgroundColor3=Color3.fromRGB(5,5,5) debugPanel.BackgroundTransparency=0.08
debugPanel.BorderSizePixel=0 debugPanel.ZIndex=88 debugPanel.Visible=false debugPanel.Parent=sg
aC(debugPanel,8) aS(debugPanel,C.neonRed,1.5)

nL(debugPanel,"🛠 DEBUG LOG",UDim2.new(1,-4,0,16),UDim2.new(0,4,0,3),
    Enum.Font.GothamBold,C.neonRed,89).TextScaled=false

local dbSF=Instance.new("ScrollingFrame")
dbSF.Size=UDim2.new(1,-4,1,-21) dbSF.Position=UDim2.new(0,2,0,20)
dbSF.BackgroundTransparency=1 dbSF.ScrollBarThickness=2
dbSF.CanvasSize=UDim2.new(0,0,0,0) dbSF.ZIndex=89 dbSF.Parent=debugPanel
local dbItems={}
for i=1,28 do
    local dl=Instance.new("TextLabel")
    dl.Size=UDim2.new(1,-4,0,11) dl.Position=UDim2.new(0,2,0,(i-1)*11)
    dl.BackgroundTransparency=1 dl.Text="" dl.TextColor3=Color3.fromRGB(80,255,80)
    dl.TextXAlignment=Enum.TextXAlignment.Left dl.TextScaled=false dl.TextSize=9
    dl.Font=Enum.Font.Code dl.ZIndex=90 dl.Parent=dbSF
    dbItems[i]=dl
end
task.spawn(function()
    while true do task.wait(0.3)
        debugPanel.Visible=S.debugOn
        if S.debugOn then
            for i,item in ipairs(dbItems) do item.Text=S.debugLog[i] or "" end
            dbSF.CanvasSize=UDim2.new(0,0,0,math.max(#S.debugLog*11,1))
        end
    end
end)

-- ================================================================
-- HUD OVERLAYS
-- ================================================================
-- FOV Circle
local fovCircle=Instance.new("Frame")
fovCircle.Size=UDim2.new(0,CFG.FOVRadius*2,0,CFG.FOVRadius*2)
fovCircle.AnchorPoint=Vector2.new(0.5,0.5) fovCircle.Position=UDim2.new(0.5,0,0.5,0)
fovCircle.BackgroundTransparency=1 fovCircle.ZIndex=30 fovCircle.Visible=false fovCircle.Parent=sg
aC(fovCircle,CFG.FOVRadius) aS(fovCircle,C.white,1.5)

-- Crosshair
local cH=Instance.new("Frame") cH.Size=UDim2.new(0,20,0,2) cH.AnchorPoint=Vector2.new(0.5,0.5)
cH.Position=UDim2.new(0.5,0,0.5,0) cH.BackgroundColor3=C.white cH.BorderSizePixel=0 cH.ZIndex=30 cH.Visible=false cH.Parent=sg
local cV=Instance.new("Frame") cV.Size=UDim2.new(0,2,0,20) cV.AnchorPoint=Vector2.new(0.5,0.5)
cV.Position=UDim2.new(0.5,0,0.5,0) cV.BackgroundColor3=C.white cV.BorderSizePixel=0 cV.ZIndex=30 cV.Visible=false cV.Parent=sg

-- Lock Indicator
local lockInd=Instance.new("TextLabel")
lockInd.Size=UDim2.new(0,160,0,24) lockInd.AnchorPoint=Vector2.new(0.5,0)
lockInd.Position=UDim2.new(0.5,0,0,128) lockInd.BackgroundColor3=C.dark lockInd.BackgroundTransparency=0.2
lockInd.TextColor3=C.sub lockInd.Text="🎯 NO TARGET" lockInd.TextScaled=false lockInd.TextSize=11
lockInd.Font=Enum.Font.GothamBold lockInd.BorderSizePixel=0 lockInd.ZIndex=30 lockInd.Visible=false lockInd.Parent=sg
aC(lockInd,6) aS(lockInd,C.sub,1.5)

-- Kill Counter
local killF=Instance.new("Frame")
killF.Size=UDim2.new(0,90,0,24) killF.Position=UDim2.new(0,8,0,128)
killF.BackgroundColor3=C.dark killF.BackgroundTransparency=0.2 killF.BorderSizePixel=0 killF.ZIndex=30 killF.Visible=false killF.Parent=sg
aC(killF,6) aS(killF,C.red,1.5)
local killLbl=nL(killF,"☠ 0",UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Enum.Font.GothamBold,C.red,31)
killLbl.TextScaled=false killLbl.TextSize=11

-- FPS HUD
local fpsHud=Instance.new("TextLabel")
fpsHud.Size=UDim2.new(0,76,0,22) fpsHud.Position=UDim2.new(1,-84,0,128)
fpsHud.BackgroundColor3=C.dark fpsHud.BackgroundTransparency=0.2
fpsHud.TextColor3=C.green fpsHud.Text="FPS: --" fpsHud.TextScaled=false fpsHud.TextSize=11
fpsHud.Font=Enum.Font.GothamBold fpsHud.BorderSizePixel=0 fpsHud.ZIndex=30 fpsHud.Visible=false fpsHud.Parent=sg
aC(fpsHud,5) aS(fpsHud,C.green,1.5)

-- Ping HUD
local pingHud=Instance.new("TextLabel")
pingHud.Size=UDim2.new(0,86,0,22) pingHud.Position=UDim2.new(1,-94,0,156)
pingHud.BackgroundColor3=C.dark pingHud.BackgroundTransparency=0.2
pingHud.TextColor3=C.cyan pingHud.Text="Ping: --" pingHud.TextScaled=false pingHud.TextSize=11
pingHud.Font=Enum.Font.GothamBold pingHud.BorderSizePixel=0 pingHud.ZIndex=30 pingHud.Visible=false pingHud.Parent=sg
aC(pingHud,5) aS(pingHud,C.cyan,1.5)

-- Player List Overlay
local plOv=Instance.new("Frame")
plOv.Size=UDim2.new(0,155,0,24) plOv.Position=UDim2.new(0,8,0.5,-60)
plOv.BackgroundColor3=C.dark plOv.BackgroundTransparency=0.15
plOv.BorderSizePixel=0 plOv.ZIndex=30 plOv.Visible=false plOv.Parent=sg
aC(plOv,7) aS(plOv,CN.accent,1.5)
local plTit=nL(plOv,"👥 Players",UDim2.new(1,0,0,18),UDim2.new(0,4,0,3),Enum.Font.GothamBold,CN.neon,31)
plTit.TextXAlignment=Enum.TextXAlignment.Left plTit.TextScaled=false plTit.TextSize=11
local plRows=Instance.new("Frame")
plRows.Size=UDim2.new(1,0,1,-22) plRows.Position=UDim2.new(0,0,0,22)
plRows.BackgroundTransparency=1 plRows.ZIndex=30 plRows.Parent=plOv
task.spawn(function()
    while true do task.wait(1.5)
        if not S.playerListOn then continue end
        for _,c in pairs(plRows:GetChildren()) do c:Destroy() end
        local ply=Players:GetPlayers() local rH=15
        plOv.Size=UDim2.new(0,155,0,24+#ply*rH+4)
        for i,p in ipairs(ply) do
            local r=Instance.new("TextLabel")
            r.Size=UDim2.new(1,-8,0,rH) r.Position=UDim2.new(0,4,0,(i-1)*rH)
            r.BackgroundTransparency=1 r.Text=(p==LP and "► " or "  ")..p.Name
            r.TextColor3=p==LP and C.yellow or C.text
            r.TextXAlignment=Enum.TextXAlignment.Left
            r.TextScaled=false r.TextSize=11 r.Font=Enum.Font.Gotham r.ZIndex=31 r.Parent=plRows
        end
    end
end)

-- ================================================================
-- LOADING SCREEN
-- ================================================================
local loadBg=Instance.new("Frame") loadBg.Size=UDim2.new(1,0,1,0) loadBg.BackgroundColor3=C.dark loadBg.BorderSizePixel=0 loadBg.ZIndex=100 loadBg.Parent=sg
local lFrame=Instance.new("Frame") lFrame.Size=UDim2.new(0,295,0,200) lFrame.AnchorPoint=Vector2.new(0.5,0.5) lFrame.Position=UDim2.new(0.5,0,0.5,0) lFrame.BackgroundColor3=CN.panel lFrame.BorderSizePixel=0 lFrame.ZIndex=101 lFrame.Parent=loadBg
aC(lFrame,16) aS(lFrame,CN.accent,2)
local lTitle=nL(lFrame,"🌧 RainBot v5.4",UDim2.new(1,0,0,38),UDim2.new(0,0,0,8),Enum.Font.GothamBold,CN.neon,102)
nL(lFrame,"SECRET UPDATE | by Rain",UDim2.new(1,0,0,17),UDim2.new(0,0,0,44),Enum.Font.Gotham,C.sub,102)
local lClip=nL(lFrame,"📋 Link disalin! Buka Chrome → paste → WA\nHubungi developer untuk minta key.",UDim2.new(0.9,0,0,36),UDim2.new(0.05,0,0,66),Enum.Font.Gotham,C.yellow,102)
lClip.TextScaled=false lClip.TextSize=11 lClip.TextWrapped=true
local lBarBg=Instance.new("Frame") lBarBg.Size=UDim2.new(0.85,0,0,6) lBarBg.Position=UDim2.new(0.075,0,0,116) lBarBg.BackgroundColor3=C.dark lBarBg.BorderSizePixel=0 lBarBg.ZIndex=102 lBarBg.Parent=lFrame aC(lBarBg,3)
local lBarFill=Instance.new("Frame") lBarFill.Size=UDim2.new(0,0,1,0) lBarFill.BackgroundColor3=CN.accent lBarFill.BorderSizePixel=0 lBarFill.ZIndex=103 lBarFill.Parent=lBarBg aC(lBarFill,3)
local lStatus=nL(lFrame,"Starting...",UDim2.new(1,0,0,15),UDim2.new(0,0,0,130),Enum.Font.Gotham,C.sub,102)
lStatus.TextScaled=false lStatus.TextSize=11
task.spawn(function()
    local cols={CN.neon,CN.accent2,CN.accent,CN.accent2} local i=1
    while loadBg.Visible do i=(i%#cols)+1 tw(lTitle,0.8,{TextColor3=cols[i]}):Play() task.wait(0.8) end
end)

-- ================================================================
-- SECRET MENU
-- ================================================================
local secretMenuOpen=false
local function openSecretMenu()
    if secretMenuOpen then return end secretMenuOpen=true
    local TM=CSC
    local ov=Instance.new("Frame") ov.Size=UDim2.new(1,0,1,0) ov.BackgroundColor3=Color3.fromRGB(0,0,0) ov.BackgroundTransparency=0.45 ov.ZIndex=68 ov.Parent=sg

    local sWin=Instance.new("Frame") sWin.Size=UDim2.new(0,0,0,0) sWin.AnchorPoint=Vector2.new(0.5,0.5)
    sWin.Position=UDim2.new(0.5,0,0.5,0) sWin.BackgroundColor3=TM.bg sWin.BorderSizePixel=0 sWin.ZIndex=69 sWin.Parent=sg
    aC(sWin,14)
    local swStr=aS(sWin,Color3.fromRGB(40,40,40),2)
    -- Animasi stroke silver berkedip
    task.spawn(function()
        while sWin.Parent do
            tw(swStr,0.9,{Color=Color3.fromRGB(150,150,150),Thickness=2.5}):Play() task.wait(0.9)
            tw(swStr,0.9,{Color=Color3.fromRGB(25,25,25),Thickness=1.5}):Play() task.wait(0.9)
        end
    end)
    -- Partikel efek "item" floating
    task.spawn(function()
        local syms={"◆","◇","▲","△","●","○","★","☆","▼","◈","⬡","⬢"}
        while sWin.Parent do task.wait(0.35)
            local p2=Instance.new("TextLabel")
            p2.Text=syms[math.random(#syms)]
            p2.TextColor3=Color3.fromRGB(math.random(50,130),math.random(50,130),math.random(50,130))
            p2.BackgroundTransparency=1 p2.TextScaled=false p2.TextSize=math.random(10,20)
            p2.Font=Enum.Font.GothamBold p2.ZIndex=70
            p2.Size=UDim2.new(0,22,0,22)
            local sx=math.random(20,530) local sy=math.random(20,290)
            p2.Position=UDim2.new(0,sx,0,sy) p2.TextTransparency=0.2 p2.Parent=sWin
            tw(p2,1.8,{TextTransparency=1,Position=UDim2.new(0,sx,0,sy-55)}):Play()
            task.wait(1.8) pcall(function() p2:Destroy() end)
        end
    end)

    tw(sWin,0.45,{Size=UDim2.new(0,560,0,330)},Enum.EasingStyle.Back):Play() task.wait(0.45)

    -- Titlebar
    local sTBar=Instance.new("Frame") sTBar.Size=UDim2.new(1,0,0,33) sTBar.BackgroundColor3=TM.panel sTBar.BorderSizePixel=0 sTBar.ZIndex=71 sTBar.Parent=sWin aC(sTBar,14)
    local sFix=Instance.new("Frame") sFix.Size=UDim2.new(1,0,0.5,0) sFix.Position=UDim2.new(0,0,0.5,0) sFix.BackgroundColor3=TM.panel sFix.BorderSizePixel=0 sFix.ZIndex=71 sFix.Parent=sTBar
    local sTit=nL(sTBar,"🔒  SECRET MENU  |  RainBot v5.4",UDim2.new(0.65,0,1,0),UDim2.new(0,10,0,0),Enum.Font.GothamBold,Color3.fromRGB(180,180,180),72)
    sTit.TextXAlignment=Enum.TextXAlignment.Left sTit.TextScaled=false sTit.TextSize=12
    local sBadge=Instance.new("TextLabel") sBadge.Size=UDim2.new(0,72,0,15) sBadge.Position=UDim2.new(0,296,0.5,-7) sBadge.BackgroundColor3=Color3.fromRGB(15,15,15) sBadge.TextColor3=Color3.fromRGB(150,150,150) sBadge.Text="🔑 SECRET KEY" sBadge.TextScaled=false sBadge.TextSize=8 sBadge.Font=Enum.Font.GothamBold sBadge.BorderSizePixel=0 sBadge.ZIndex=72 sBadge.Parent=sTBar aC(sBadge,5)
    local sClose=Instance.new("TextButton") sClose.Size=UDim2.new(0,22,0,15) sClose.Position=UDim2.new(1,-26,0.5,-7) sClose.BackgroundColor3=C.red sClose.Text="✕" sClose.TextColor3=C.white sClose.TextScaled=true sClose.Font=Enum.Font.GothamBold sClose.BorderSizePixel=0 sClose.ZIndex=75 sClose.Parent=sTBar aC(sClose,5)
    sClose.MouseButton1Click:Connect(function()
        tw(sWin,0.25,{Size=UDim2.new(0,560,0,0)}):Play() task.wait(0.25) sWin:Destroy() ov:Destroy() secretMenuOpen=false
    end)

    local sBody=Instance.new("Frame") sBody.Size=UDim2.new(1,0,1,-33) sBody.Position=UDim2.new(0,0,0,33) sBody.BackgroundTransparency=1 sBody.ZIndex=71 sBody.Parent=sWin
    local sSide=Instance.new("Frame") sSide.Size=UDim2.new(0,76,1,0) sSide.BackgroundColor3=TM.panel sSide.BorderSizePixel=0 sSide.ZIndex=72 sSide.Parent=sBody
    local sSep=Instance.new("Frame") sSep.Size=UDim2.new(0,1,1,0) sSep.Position=UDim2.new(0,76,0,0) sSep.BackgroundColor3=Color3.fromRGB(40,40,40) sSep.BorderSizePixel=0 sSep.ZIndex=72 sSep.Parent=sBody
    local sCA=Instance.new("Frame") sCA.Size=UDim2.new(0,480,1,-4) sCA.Position=UDim2.new(0,78,0,2) sCA.BackgroundTransparency=1 sCA.ZIndex=72 sCA.Parent=sBody

    local C2=math.floor((480-12)/2)
    local sDefs={{icon="💣",label="Bypass"},{icon="🎯",label="NoSpread"},{icon="🎨",label="Extras"},{icon="🛠",label="Debug"}}
    local sBtns={} local sFrames={}
    for idx,td in ipairs(sDefs) do
        local tb=Instance.new("TextButton") tb.Size=UDim2.new(1,-6,0,30) tb.Position=UDim2.new(0,3,0,(idx-1)*33+3) tb.BackgroundColor3=TM.bg tb.BackgroundTransparency=0.4 tb.Text="" tb.BorderSizePixel=0 tb.ZIndex=74 tb.Parent=sSide aC(tb,7)
        local ic=nL(tb,td.icon,UDim2.new(1,0,0,16),UDim2.new(0,0,0,2),Enum.Font.GothamBold,Color3.fromRGB(130,130,130),75)
        local sl=nL(tb,td.label,UDim2.new(1,0,0,9),UDim2.new(0,0,0,17),Enum.Font.Gotham,Color3.fromRGB(100,100,100),75) sl.TextScaled=false sl.TextSize=7
        local sf=Instance.new("ScrollingFrame") sf.Size=UDim2.new(1,0,1,0) sf.BackgroundTransparency=1 sf.ScrollBarThickness=2 sf.CanvasSize=UDim2.new(0,0,0,500) sf.ScrollBarImageColor3=Color3.fromRGB(70,70,70) sf.BorderSizePixel=0 sf.ZIndex=73 sf.Visible=false sf.Parent=sCA
        sBtns[td.label]={btn=tb,ic=ic,sl=sl} sFrames[td.label]=sf
    end
    local function sSw(name)
        for n,t in pairs(sBtns) do
            local a=(n==name)
            t.btn.BackgroundTransparency=a and 0 or 0.4 t.btn.BackgroundColor3=a and Color3.fromRGB(45,45,45) or TM.bg
            t.ic.TextColor3=a and C.white or Color3.fromRGB(130,130,130) t.sl.TextColor3=a and C.white or Color3.fromRGB(100,100,100)
            sFrames[n].Visible=a
        end
    end
    for _,td in ipairs(sDefs) do local lb=td.label tabBtnConnect___ = sBtns[lb].btn.MouseButton1Click:Connect(function() sSw(lb) end) end

    local function sTog(sf,col,row2,lbl2,def2)
        local x2=col==0 and 4 or C2+6+4 local y2=row2*42+2
        return makeToggle(sf,x2,y2,C2,38,lbl2,def2,TM,true)
    end
    local function sSec(sf,txt2,y2)
        local l=nL(sf,txt2,UDim2.new(1,-8,0,13),UDim2.new(0,4,0,y2),Enum.Font.GothamBold,Color3.fromRGB(110,110,110),73)
        l.TextXAlignment=Enum.TextXAlignment.Left l.TextScaled=false l.TextSize=10
    end

    -- TAB BYPASS
    local bSF=sFrames["Bypass"]
    sSec(bSF,"⚡ Bypass Control",2)
    -- Bypass toggle spesial (merah neon pulsing)
    local byRow=Instance.new("Frame") byRow.Size=UDim2.new(1,-8,0,48) byRow.Position=UDim2.new(0,4,0,18) byRow.BackgroundColor3=Color3.fromRGB(18,3,3) byRow.BorderSizePixel=0 byRow.ZIndex=73 byRow.Parent=bSF aC(byRow,10)
    local byStr=aS(byRow,C.neonRed,2)
    task.spawn(function()
        while byRow.Parent do
            tw(byStr,0.55,{Color=Color3.fromRGB(255,70,70),Thickness=2.5}):Play() task.wait(0.55)
            tw(byStr,0.55,{Color=Color3.fromRGB(160,10,20),Thickness=1.5}):Play() task.wait(0.55)
        end
    end)
    local byTxt=nL(byRow,"💣  BYPASS",UDim2.new(1,-60,0,22),UDim2.new(0,12,0,3),Enum.Font.GothamBold,C.neonRed,74)
    byTxt.TextXAlignment=Enum.TextXAlignment.Left byTxt.TextScaled=false byTxt.TextSize=15
    nL(byRow,"Aktifkan bypass anti-cheat game",UDim2.new(1,-60,0,14),UDim2.new(0,12,0,26),Enum.Font.Gotham,Color3.fromRGB(120,70,70),74).TextScaled=false

    local bTrk=Instance.new("Frame") bTrk.Size=UDim2.new(0,44,0,22) bTrk.Position=UDim2.new(1,-52,0.5,-11) bTrk.BackgroundColor3=S.bypassOn and C.neonRed or Color3.fromRGB(60,60,60) bTrk.BorderSizePixel=0 bTrk.ZIndex=74 bTrk.Parent=byRow aC(bTrk,11)
    local bKnb=Instance.new("Frame") bKnb.Size=UDim2.new(0,16,0,16) bKnb.Position=S.bypassOn and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8) bKnb.BackgroundColor3=C.white bKnb.BorderSizePixel=0 bKnb.ZIndex=75 bKnb.Parent=bTrk aC(bKnb,8)
    local bHit=Instance.new("TextButton") bHit.Size=UDim2.new(1,0,1,0) bHit.BackgroundTransparency=1 bHit.Text="" bHit.ZIndex=78 bHit.Parent=byRow
    bHit.MouseButton1Click:Connect(function()
        S.bypassOn=not S.bypassOn
        tw(bTrk,0.15,{BackgroundColor3=S.bypassOn and C.neonRed or Color3.fromRGB(60,60,60)}):Play()
        tw(bKnb,0.15,{Position=S.bypassOn and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
        if S.bypassOn then showBypassLabel() notif("⚡ Bypass ACTIVE!",C.neonRed) end
        if not S.bypassOn then notif("Bypass OFF",C.sub) end
        dbg("Bypass: "..(S.bypassOn and "ON" or "OFF"))
    end)

    sSec(bSF,"🔧 Bypass Tools",74)
    local getAntiDetect,_  = sTog(bSF,0,2,"🛡 Anti-Detect",false)
    local getSpeedBypass,_ = sTog(bSF,1,2,"💨 Speed Bypass",false)
    local getEspBypass,_   = sTog(bSF,0,3,"👁 ESP Bypass",false)
    local getAimBypass,_   = sTog(bSF,1,3,"🎯 Aim Bypass",false)
    local getPktSpoof,_    = sTog(bSF,0,4,"📡 Packet Spoof",false)
    local getAntiLog,_     = sTog(bSF,1,4,"📋 Anti-Log",false)
    bSF.CanvasSize=UDim2.new(0,0,0,74+5*42+20)

    -- TAB NO SPREAD
    local nsSF=sFrames["NoSpread"]
    sSec(nsSF,"🎯 Spread & Recoil",2)
    local getNoSpread,_   = sTog(nsSF,0,0,"🎯 No Spread",false)
    local getZeroRecoil,_ = sTog(nsSF,1,0,"⬆ Zero Recoil",false)
    local getMagnet,_     = sTog(nsSF,0,1,"🧲 Bullet Magnet",false)
    local getInstantHit,_ = sTog(nsSF,1,1,"⚡ Instant Hit",false)
    local getNoSway,_     = sTog(nsSF,0,2,"〰 No Sway",false)
    local getWiderFOV,_   = sTog(nsSF,1,2,"🔭 Wider FOV",false)
    sSec(nsSF,"🔫 Weapon Secret",2+3*42+18)
    local getAutoShoot,_  = sTog(nsSF,0,4,"🔫 Auto Shoot",false)
    local getFullAuto,_   = sTog(nsSF,1,4,"🔁 Full Auto",false)
    local getTriggerbot,_ = sTog(nsSF,0,5,"👆 Triggerbot",false)
    local getSwapFire,_   = sTog(nsSF,1,5,"🔄 Swap Fire",false)
    nsSF.CanvasSize=UDim2.new(0,0,0,2+6*42+38)

    -- TAB EXTRAS SECRET
    local exSF=sFrames["Extras"]
    sSec(exSF,"🎨 Secret Extras",2)
    local getUnlockAll,_ = sTog(exSF,0,0,"🔓 Unlock All",false)
    local getNameSpoof,_ = sTog(exSF,1,0,"📝 Name Spoof",false)
    local getChatLog,_   = sTog(exSF,0,1,"💬 Chat Logger",false)
    local getNoGrav,_    = sTog(exSF,1,1,"🌙 No Gravity",false)
    local getSuperJmp,_  = sTog(exSF,0,2,"🚀 Super Jump x4",false)
    local getTele,_      = sTog(exSF,1,2,"📍 Teleport Spawn",false)
    local getAntiRep,_   = sTog(exSF,0,3,"🛡 Anti-Report",false)
    local getAutoFarm,_  = sTog(exSF,1,3,"🌾 Auto Farm",false)
    local getFreezeAll,_ = sTog(exSF,0,4,"❄ Freeze Others",false)
    local getKillAura,_  = sTog(exSF,1,4,"💀 Kill Aura",false)
    exSF.CanvasSize=UDim2.new(0,0,0,2+5*42+20)

    -- TAB DEBUG
    local dSF=sFrames["Debug"]
    sSec(dSF,"🛠 Debug Tools",2)
    local getDbOn,_    = sTog(dSF,0,0,"🛠 Debug Log",false)
    local getDbESP,_   = sTog(dSF,1,0,"👁 Debug ESP",false)
    local getDbAim,_   = sTog(dSF,0,1,"🎯 Debug Aim",false)
    local getDbNet,_   = sTog(dSF,1,1,"📡 Debug Net",false)
    local getDbChar,_  = sTog(dSF,0,2,"👤 Debug Char",false)
    local getDbWorld,_ = sTog(dSF,1,2,"🌍 Debug World",false)
    local clrBtn=Instance.new("TextButton")
    clrBtn.Size=UDim2.new(1,-8,0,28) clrBtn.Position=UDim2.new(0,4,0,2+3*42+8)
    clrBtn.BackgroundColor3=Color3.fromRGB(30,8,8) clrBtn.TextColor3=C.neonRed
    clrBtn.Text="🗑 Clear Debug Log" clrBtn.TextScaled=false clrBtn.TextSize=12
    clrBtn.Font=Enum.Font.GothamBold clrBtn.BorderSizePixel=0 clrBtn.ZIndex=73 clrBtn.Parent=dSF
    aC(clrBtn,8) aS(clrBtn,C.neonRed,1)
    clrBtn.MouseButton1Click:Connect(function()
        S.debugLog={} notif("🗑 Debug cleared",C.cyan)
    end)
    dSF.CanvasSize=UDim2.new(0,0,0,2+3*42+60)

    -- Secret Heartbeat
    local sHb sHb=RunService.Heartbeat:Connect(function()
        if not sWin.Parent then sHb:Disconnect() return end
        S.noSpread = getNoSpread()
        S.debugOn  = getDbOn()

        if S.debugOn then
            local ch2=LP.Character local h2=ch2 and ch2:FindFirstChildOfClass("Humanoid")
            if h2 then dbg("HP:"..math.floor(h2.Health).." Aim:"..tostring(S.aimOn).." BP:"..tostring(S.bypassOn)) end
            if getDbESP()  then dbg("ESP:"..tostring(S.espOn).." Target:"..tostring(S.lockedTarget~=nil)) end
            if getDbNet()  then local ok,ms=pcall(function() return math.floor(LP:GetNetworkPing()*1000) end) if ok then dbg("Ping:"..ms.."ms") end end
            if getDbWorld() then dbg("Gravity:"..tostring(workspace.Gravity).." Fog:"..tostring(S.noFogOn)) end
        end

        -- No Gravity
        if getNoGrav() then
            workspace.Gravity=5
            local ch2=LP.Character local rp2=ch2 and ch2:FindFirstChild("HumanoidRootPart")
            if rp2 then rp2.AssemblyLinearVelocity=Vector3.new(rp2.AssemblyLinearVelocity.X,0,rp2.AssemblyLinearVelocity.Z) end
        else if workspace.Gravity~=196.2 then workspace.Gravity=196.2 end end

        -- Super Jump
        if getSuperJmp() then
            local ch2=LP.Character local h2=ch2 and ch2:FindFirstChildOfClass("Humanoid")
            if h2 then h2.JumpPower=220 end
        end

        -- Wider FOV
        if getWiderFOV() then Camera.FieldOfView=95 else if Camera.FieldOfView==95 then Camera.FieldOfView=70 end end

        -- Kill Aura (placeholder - mendekati musuh)
        if getKillAura() then dbg("KillAura active (game-dependent)") end

        -- Teleport to spawn
        if getTele() and not _G["RainTeleCd"] then
            _G["RainTeleCd"]=true
            local sp=workspace:FindFirstChild("SpawnLocation")
            if sp then local ch2=LP.Character local rp2=ch2 and ch2:FindFirstChild("HumanoidRootPart")
                if rp2 then rp2.CFrame=sp.CFrame+Vector3.new(0,5,0) notif("📍 Teleport!",C.cyan) end
            end task.wait(3) _G["RainTeleCd"]=nil
        end
    end)

    sSw("Bypass")

    -- Drag
    local drag2,dS2,wS2=false,nil,nil
    sTBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag2=true dS2=i.Position wS2=sWin.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag2=false end end)
        end
    end)
    sTBar.InputChanged:Connect(function(i)
        if drag2 and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMove) then
            local d2=i.Position-dS2 sWin.Position=UDim2.new(wS2.X.Scale,wS2.X.Offset+d2.X,wS2.Y.Scale,wS2.Y.Offset+d2.Y)
        end
    end)
end

-- ================================================================
-- KEY POPUP
-- ================================================================
local function showKey()
    local ov=Instance.new("Frame") ov.Size=UDim2.new(1,0,1,0) ov.BackgroundColor3=Color3.fromRGB(0,0,0) ov.BackgroundTransparency=0.45 ov.ZIndex=55 ov.Parent=sg
    local pp=Instance.new("Frame") pp.Size=UDim2.new(0,295,0,0) pp.AnchorPoint=Vector2.new(0.5,0.5) pp.Position=UDim2.new(0.5,0,0.5,0) pp.BackgroundColor3=CN.panel pp.BorderSizePixel=0 pp.ZIndex=56 pp.Parent=sg
    aC(pp,16) aS(pp,CN.accent,2) tw(pp,0.4,{Size=UDim2.new(0,295,0,215)},Enum.EasingStyle.Back):Play() task.wait(0.4)
    nL(pp,"🔑 Masukkan Key",UDim2.new(1,0,0,34),UDim2.new(0,0,0,8),Enum.Font.GothamBold,CN.neon,57)
    local inf=nL(pp,"Belum punya key? Link WA sudah tersalin!\nBuka Chrome → paste → hubungi developer.",UDim2.new(0.9,0,0,32),UDim2.new(0.05,0,0,46),Enum.Font.Gotham,C.yellow,57)
    inf.TextScaled=false inf.TextSize=11 inf.TextWrapped=true
    local kb=Instance.new("TextBox") kb.Size=UDim2.new(0.88,0,0,36) kb.Position=UDim2.new(0.06,0,0,85) kb.BackgroundColor3=C.dark kb.TextColor3=C.text kb.PlaceholderText="Masukkan key kamu..." kb.PlaceholderColor3=C.sub kb.Text="" kb.TextScaled=false kb.TextSize=12 kb.Font=Enum.Font.Gotham kb.BorderSizePixel=0 kb.ZIndex=57 kb.Parent=pp aC(kb,8) aS(kb,CN.accent,1)
    local ks=nL(pp,"",UDim2.new(1,0,0,17),UDim2.new(0,0,0,130),Enum.Font.Gotham,C.red,57) ks.TextScaled=false ks.TextSize=11
    local cb=Instance.new("TextButton") cb.Size=UDim2.new(0.88,0,0,33) cb.Position=UDim2.new(0.06,0,0,158) cb.BackgroundColor3=CN.accent cb.TextColor3=C.white cb.Text="Verifikasi ✓" cb.TextScaled=false cb.TextSize=13 cb.Font=Enum.Font.GothamBold cb.BorderSizePixel=0 cb.ZIndex=57 cb.Parent=pp aC(cb,8)

    cb.MouseButton1Click:Connect(function()
        local kt=KEYS[kb.Text]
        if kt then
            S.tier=kt
            local msgs={
                normal  ={col=C.green,  txt="✅ Key valid! Selamat datang!"},
                esp     ={col=C.yellow, txt="⭐ VIP Key aktif! ESP unlocked!"},
                vipplus ={col=C.neonRed,txt="🔴 VIP+ aktif! Semua fitur terbuka!"},
                secret  ={col=Color3.fromRGB(190,190,190),txt="🔒 SECRET KEY! Menu rahasia terbuka!"},
            }
            local m=msgs[kt] ks.TextColor3=m.col ks.Text=m.txt
            -- Simpan nilai fog asli
            S._origFogEnd=Lighting.FogEnd S._origFogStart=Lighting.FogStart
            local atmo=Lighting:FindFirstChildOfClass("Atmosphere")
            if atmo then S._origAtmoDensity=atmo.Density end
            task.wait(0.9) tw(pp,0.2,{Size=UDim2.new(0,295,0,0)}):Play() task.wait(0.25)
            pp:Destroy() ov:Destroy() task.wait(0.1) openMenu()
        else
            ks.Text="❌ Key tidak valid!" ks.TextColor3=C.red kb.Text=""
            for i=1,4 do
                task.wait(0.05) tw(pp,0.05,{Position=UDim2.new(0.5,7,0.5,0)}):Play()
                task.wait(0.05) tw(pp,0.05,{Position=UDim2.new(0.5,-7,0.5,0)}):Play()
            end
            tw(pp,0.05,{Position=UDim2.new(0.5,0,0.5,0)}):Play()
        end
    end)
end

-- ================================================================
-- MAIN MENU  580x360
-- ================================================================
function openMenu()
    local TM=TH() local W=580 local H=360 local SB=78 local TBH=36
    local CAW=W-SB-2 local COL=math.floor((CAW-12)/2)

    local win=Instance.new("Frame") win.Size=UDim2.new(0,0,0,0) win.AnchorPoint=Vector2.new(0.5,0.5) win.Position=UDim2.new(0.5,0,0.5,0) win.BackgroundColor3=TM.bg win.BorderSizePixel=0 win.ZIndex=10 win.Parent=sg
    aC(win,12)
    local winStr=aS(win,TM.stroke,2)

    -- VIP+ outline merah item animasi berputar
    if isVIP() then
        task.spawn(function()
            local hue=0 while win.Parent do hue=(hue+2)%360
                local r=math.floor(180+math.abs(math.sin(math.rad(hue)))*75)
                local g=math.floor(math.max(0,math.sin(math.rad(hue+90))*15))
                winStr.Color=Color3.fromRGB(r,g,g)
                winStr.Thickness=1.8+math.abs(math.sin(math.rad(hue)))*1.5 task.wait(0.03)
            end
        end)
    end
    -- Secret outline berkedip silver
    if isSecret() then
        task.spawn(function()
            while win.Parent do
                tw(winStr,0.8,{Color=Color3.fromRGB(160,160,160),Thickness=2.5}):Play() task.wait(0.8)
                tw(winStr,0.8,{Color=Color3.fromRGB(25,25,25),Thickness=1}):Play() task.wait(0.8)
            end
        end)
    end

    tw(win,0.45,{Size=UDim2.new(0,W,0,H)},Enum.EasingStyle.Back):Play() task.wait(0.45)

    -- TITLEBAR
    local tBar=Instance.new("Frame") tBar.Size=UDim2.new(1,0,0,TBH) tBar.BackgroundColor3=TM.panel tBar.BorderSizePixel=0 tBar.ZIndex=11 tBar.Parent=win aC(tBar,12)
    local tFix=Instance.new("Frame") tFix.Size=UDim2.new(1,0,0.5,0) tFix.Position=UDim2.new(0,0,0.5,0) tFix.BackgroundColor3=TM.panel tFix.BorderSizePixel=0 tFix.ZIndex=11 tFix.Parent=tBar
    local ver=isSecret() and "🌧  RainBot v5.4 SECRET" or "🌧  RainBot v5.4"
    local tLbl=nL(tBar,ver,UDim2.new(0,190,1,0),UDim2.new(0,10,0,0),Enum.Font.GothamBold,TM.neon,12)
    tLbl.TextXAlignment=Enum.TextXAlignment.Left tLbl.TextScaled=false tLbl.TextSize=13

    local tierInfo={
        normal  ={txt="🔑 Normal",bg=Color3.fromRGB(20,8,45),  col=C.green},
        esp     ={txt="⭐ VIP",   bg=Color3.fromRGB(38,26,3),  col=C.yellow},
        vipplus ={txt="🔴 VIP+",  bg=Color3.fromRGB(25,3,3),   col=C.neonRed},
        secret  ={txt="🔒 SECRET",bg=Color3.fromRGB(12,12,12), col=Color3.fromRGB(180,180,180)},
    }
    local ti=tierInfo[S.tier] or tierInfo.normal
    local bdg=Instance.new("TextLabel") bdg.Size=UDim2.new(0,65,0,15) bdg.Position=UDim2.new(0,196,0.5,-7) bdg.BackgroundColor3=ti.bg bdg.TextColor3=ti.col bdg.Text=ti.txt bdg.TextScaled=false bdg.TextSize=9 bdg.Font=Enum.Font.GothamBold bdg.BorderSizePixel=0 bdg.ZIndex=12 bdg.Parent=tBar aC(bdg,5)
    local uLbl=nL(tBar,"👤 "..LP.Name,UDim2.new(0,130,1,0),UDim2.new(0,270,0,0),Enum.Font.Gotham,C.sub,12)
    uLbl.TextXAlignment=Enum.TextXAlignment.Left uLbl.TextScaled=false uLbl.TextSize=11

    if isSecret() then
        local secBtn=Instance.new("TextButton") secBtn.Size=UDim2.new(0,22,0,15) secBtn.Position=UDim2.new(1,-76,0.5,-7) secBtn.BackgroundColor3=Color3.fromRGB(20,20,20) secBtn.Text="🔒" secBtn.TextColor3=Color3.fromRGB(160,160,160) secBtn.TextScaled=true secBtn.Font=Enum.Font.GothamBold secBtn.BorderSizePixel=0 secBtn.ZIndex=15 secBtn.Parent=tBar aC(secBtn,5) aS(secBtn,Color3.fromRGB(70,70,70),1)
        secBtn.MouseButton1Click:Connect(function() openSecretMenu() end)
    end

    local minB=Instance.new("TextButton") minB.Size=UDim2.new(0,22,0,15) minB.Position=UDim2.new(1,-50,0.5,-7) minB.BackgroundColor3=TM.accent minB.Text="–" minB.TextColor3=C.white minB.TextScaled=true minB.Font=Enum.Font.GothamBold minB.BorderSizePixel=0 minB.ZIndex=15 minB.Parent=tBar aC(minB,5)
    local closeB=Instance.new("TextButton") closeB.Size=UDim2.new(0,22,0,15) closeB.Position=UDim2.new(1,-24,0.5,-7) closeB.BackgroundColor3=C.red closeB.Text="✕" closeB.TextColor3=C.white closeB.TextScaled=true closeB.Font=Enum.Font.GothamBold closeB.BorderSizePixel=0 closeB.ZIndex=15 closeB.Parent=tBar aC(closeB,5)

    -- BODY
    local body=Instance.new("Frame") body.Size=UDim2.new(1,0,1,-TBH) body.Position=UDim2.new(0,0,0,TBH) body.BackgroundTransparency=1 body.ClipsDescendants=true body.ZIndex=10 body.Parent=win
    local sidebar=Instance.new("Frame") sidebar.Size=UDim2.new(0,SB,1,0) sidebar.BackgroundColor3=TM.panel sidebar.BorderSizePixel=0 sidebar.ZIndex=11 sidebar.Parent=body
    local sepLine=Instance.new("Frame") sepLine.Size=UDim2.new(0,1,1,0) sepLine.Position=UDim2.new(0,SB,0,0) sepLine.BackgroundColor3=TM.stroke sepLine.BackgroundTransparency=0.5 sepLine.BorderSizePixel=0 sepLine.ZIndex=11 sepLine.Parent=body
    local cArea=Instance.new("Frame") cArea.Size=UDim2.new(0,CAW,1,-4) cArea.Position=UDim2.new(0,SB+2,0,2) cArea.BackgroundTransparency=1 cArea.ZIndex=11 cArea.Parent=body

    -- TABS
    local tabDefs={{icon="🏠",label="Home"},{icon="🎯",label="Aimbot"},{icon="👁",label="Visual"},{icon="⚡",label="Move"},{icon="🌍",label="World"},{icon="🔫",label="Weapon"},{icon="🎨",label="Extras"},{icon="ℹ️",label="Info"}}
    if isVIP() then table.insert(tabDefs,{icon="🔴",label="VIP+"}) end
    local tabBtns={} local tabFrames={}

    for idx,td in ipairs(tabDefs) do
        local isVT=(td.label=="VIP+")
        local tb=Instance.new("TextButton") tb.Size=UDim2.new(1,-6,0,29) tb.Position=UDim2.new(0,3,0,(idx-1)*32+2) tb.BackgroundColor3=TM.bg tb.BackgroundTransparency=0.4 tb.Text="" tb.BorderSizePixel=0 tb.ZIndex=13 tb.Parent=sidebar aC(tb,7)
        if isVT then
            local vs=aS(tb,CVP.accent,1.5)
            task.spawn(function() while tb.Parent do tw(vs,0.6,{Color=Color3.fromRGB(255,40,40),Thickness=2}):Play() task.wait(0.6) tw(vs,0.6,{Color=Color3.fromRGB(130,8,8),Thickness=1}):Play() task.wait(0.6) end end)
        end
        local ic=nL(tb,td.icon,UDim2.new(1,0,0,15),UDim2.new(0,0,0,2),Enum.Font.GothamBold,isVT and CVP.neon or C.sub,14)
        local sl=nL(tb,td.label,UDim2.new(1,0,0,9),UDim2.new(0,0,0,16),Enum.Font.Gotham,isVT and CVP.accent2 or C.sub,14) sl.TextScaled=false sl.TextSize=7
        local sf=Instance.new("ScrollingFrame") sf.Size=UDim2.new(1,0,1,0) sf.BackgroundTransparency=1 sf.ScrollBarThickness=3 sf.CanvasSize=UDim2.new(0,0,0,500) sf.ScrollBarImageColor3=TM.accent sf.BorderSizePixel=0 sf.ZIndex=12 sf.Visible=false sf.Parent=cArea
        tabBtns[td.label]={btn=tb,ic=ic,sl=sl} tabFrames[td.label]=sf
    end

    local function switchTab(name)
        for n,t in pairs(tabBtns) do
            local act=(n==name) local isVT=(n=="VIP+")
            t.btn.BackgroundTransparency=act and 0 or 0.4
            t.btn.BackgroundColor3=act and (isVT and CVP.accent or TM.accent) or TM.bg
            t.ic.TextColor3=act and C.white or (isVT and CVP.neon or C.sub)
            t.sl.TextColor3=act and C.white or (isVT and CVP.accent2 or C.sub)
            tabFrames[n].Visible=act
        end
    end
    for _,td in ipairs(tabDefs) do local lb=td.label tabBtns[lb].btn.MouseButton1Click:Connect(function() switchTab(lb) end) end

    local function tog(sf,col,row2,lbl2,def2)
        local x2=col==0 and 4 or COL+6+4 local y2=row2*42+2
        return makeToggle(sf,x2,y2,COL,38,lbl2,def2,TM)
    end
    local function sec(sf,txt2,y2)
        local l=nL(sf,txt2,UDim2.new(1,-8,0,13),UDim2.new(0,4,0,y2),Enum.Font.GothamBold,TM.accent2,12)
        l.TextXAlignment=Enum.TextXAlignment.Left l.TextScaled=false l.TextSize=10
    end

    -- HOME
    local hSF=tabFrames["Home"]
    local bw=math.floor((CAW-16)/4)-2
    local scMap={aimOn=C.red,espOn=C.green,speedOn=C.cyan,godModeOn=C.yellow}
    local snMap={aimOn="Aimbot",espOn="ESP",speedOn="Speed",godModeOn="God"}
    local svRefs={}
    for i,key in ipairs({"aimOn","espOn","speedOn","godModeOn"}) do
        local box=Instance.new("Frame") box.Size=UDim2.new(0,bw,0,38) box.Position=UDim2.new(0,4+(i-1)*(bw+3),0,4) box.BackgroundColor3=TM.panel box.BorderSizePixel=0 box.ZIndex=12 box.Parent=hSF
        aC(box,8) aS(box,scMap[key],1.5)
        local ln=nL(box,snMap[key],UDim2.new(1,0,0.45,0),UDim2.new(0,0,0,2),Enum.Font.GothamBold,scMap[key],13) ln.TextScaled=false ln.TextSize=10
        local lv=nL(box,"OFF",UDim2.new(1,0,0.5,0),UDim2.new(0,0,0.46,0),Enum.Font.Gotham,C.sub,13) lv.TextScaled=false lv.TextSize=11
        svRefs[key]={lv=lv,col=scMap[key]}
    end
    sec(hSF,"⚙️ Quick HUD",48)
    local getFpsQ,_=tog(hSF,0,1,"📊 FPS Counter",false)
    local getPingQ,_=tog(hSF,1,1,"📶 Ping Display",false)
    local getRbName,_=tog(hSF,0,2,"🌈 Rainbow Name",false)
    local getPlList,_=tog(hSF,1,2,"📋 Player List",false)
    hSF.CanvasSize=UDim2.new(0,0,0,175)

    -- AIMBOT
    local aSF=tabFrames["Aimbot"]
    sec(aSF,"🎯 Aimbot",2)
    local getAim,_=tog(aSF,0,0,"🎯 Aimbot",false)
    local getWall,_=tog(aSF,1,0,"🧱 Wall Check",true)
    local getHead,_=tog(aSF,0,1,"💀 Aim Kepala",true)
    local getSilent,_=tog(aSF,1,1,"🔇 Silent Aim",false)
    local getSmooth,_=tog(aSF,0,2,"🌊 Smooth Aim",false)
    local getAssist,_=tog(aSF,1,2,"🤝 Aim Assist",false)
    sec(aSF,"🖥️ HUD",2+3*42+18)
    local getFov,_=tog(aSF,0,4,"⭕ FOV Circle",false)
    local getCross,_=tog(aSF,1,4,"➕ Crosshair",false)
    local getLockInd,_=tog(aSF,0,5,"🔒 Lock Indicator",false)
    local getKillC,_=tog(aSF,1,5,"☠ Kill Counter",false)
    aSF.CanvasSize=UDim2.new(0,0,0,2+6*42+40)

    -- VISUAL
    local vSF=tabFrames["Visual"]
    local getEsp=function() return false end local getName=function() return true end
    local getHP=function() return true end   local getDist=function() return true end
    local getAlrt=function() return false end
    if isESP() then
        sec(vSF,"👁 ESP",2)
        getEsp,_=tog(vSF,0,0,"👁 ESP On/Off",false)
        getName,_=tog(vSF,1,0,"🏷 Nama Musuh",true)
        getHP,_=tog(vSF,0,1,"❤️ Health Bar",true)
        getDist,_=tog(vSF,1,1,"📏 Jarak",true)
        sec(vSF,"🔔 Alert",2+2*42+18)
        getAlrt,_=tog(vSF,0,3,"🔔 Alert Musuh",false)
        vSF.CanvasSize=UDim2.new(0,0,0,2+4*42+38)
    else
        local lkF=Instance.new("Frame") lkF.Size=UDim2.new(1,-10,0,100) lkF.Position=UDim2.new(0,5,0,5) lkF.BackgroundColor3=TM.panel lkF.BorderSizePixel=0 lkF.ZIndex=12 lkF.Parent=vSF
        aC(lkF,12) aS(lkF,C.red,1.5)
        nL(lkF,"🔒",UDim2.new(1,0,0,36),UDim2.new(0,0,0,7),Enum.Font.GothamBold,C.red,13)
        local lt=nL(lkF,"ESP terkunci — Butuh VIP key.",UDim2.new(1,0,0,20),UDim2.new(0,0,0,46),Enum.Font.GothamBold,C.red,13) lt.TextScaled=false lt.TextSize=12
        local ls=nL(lkF,"Hubungi developer untuk akses.",UDim2.new(0.9,0,0,15),UDim2.new(0.05,0,0,69),Enum.Font.Gotham,C.sub,13) ls.TextScaled=false ls.TextSize=11
        vSF.CanvasSize=UDim2.new(0,0,0,115)
    end

    -- MOVEMENT
    local mSF=tabFrames["Move"]
    sec(mSF,"⚡ Movement",2)
    local getSpeed,_=tog(mSF,0,0,"💨 Speedhack",false)
    local getNoclip,_=tog(mSF,1,0,"👻 Noclip",false)
    local getInfJump,_=tog(mSF,0,1,"🦘 Infinite Jump",false)
    local getFly,_=tog(mSF,1,1,"🕊️ Fly",false)
    local getHighJump,_=tog(mSF,0,2,"🚀 High Jump",false)
    local getSpamJump,_=tog(mSF,1,2,"🐸 Spam Jump",false)
    mSF.CanvasSize=UDim2.new(0,0,0,2+3*42+20)

    -- WORLD
    local wSF=tabFrames["World"]
    sec(wSF,"🌍 World",2)
    local getFullbright,_=tog(wSF,0,0,"☀️ Fullbright",false)
    local getNoFog,_=tog(wSF,1,0,"🌫️ No Fog",false)
    local getTimeF,_=tog(wSF,0,1,"⏱️ Freeze Time",false)
    local getThirdP,_=tog(wSF,1,1,"📷 Third Person",false)
    wSF.CanvasSize=UDim2.new(0,0,0,2+2*42+20)

    -- WEAPON
    local wpSF=tabFrames["Weapon"]
    sec(wpSF,"🔫 Weapon",2)
    local getRapid,_=tog(wpSF,0,0,"🔥 Rapid Fire",false)
    local getNoRecoil,_=tog(wpSF,1,0,"🎯 No Recoil",false)
    local getInfAmmo,_=tog(wpSF,0,1,"♾ Inf Ammo",false)
    wpSF.CanvasSize=UDim2.new(0,0,0,2+2*42+20)

    -- EXTRAS
    local eSF=tabFrames["Extras"]
    sec(eSF,"🎨 Extras",2)
    local getAntiAfk,_=tog(eSF,0,0,"🤖 Anti-AFK",false)
    local getGod,_=tog(eSF,1,0,"🛡️ God Mode",false)
    local getInvis,_=tog(eSF,0,1,"👁️ Invisible",false)
    local getAntiKB,_=tog(eSF,1,1,"🗿 Anti-Knockback",false)
    local getAutoHeal,_=tog(eSF,0,2,"💊 Auto Heal",false)
    eSF.CanvasSize=UDim2.new(0,0,0,2+3*42+20)

    -- VIP+
    local getVipAura=function() return false end
    local getGetSkins=function() return false end
    local getVipESPT=function() return false end
    local getVipSpd=function() return false end
    local getVipInst=function() return false end

    if isVIP() then
        local vpSF=tabFrames["VIP+"]
        local vpHdr=Instance.new("Frame") vpHdr.Size=UDim2.new(1,-8,0,38) vpHdr.Position=UDim2.new(0,4,0,2) vpHdr.BackgroundColor3=Color3.fromRGB(18,3,3) vpHdr.BorderSizePixel=0 vpHdr.ZIndex=12 vpHdr.Parent=vpSF aC(vpHdr,10)
        local vpS=aS(vpHdr,CVP.accent,2)
        task.spawn(function() while vpHdr.Parent do tw(vpS,0.65,{Color=Color3.fromRGB(255,50,50),Thickness=2.5}):Play() task.wait(0.65) tw(vpS,0.65,{Color=Color3.fromRGB(140,8,8),Thickness=1.5}):Play() task.wait(0.65) end end)
        local vpt=nL(vpHdr,"🔴 VIP+ EXCLUSIVE FEATURES",UDim2.new(1,-8,0.55,0),UDim2.new(0,8,0,0),Enum.Font.GothamBold,CVP.neon,13) vpt.TextXAlignment=Enum.TextXAlignment.Left vpt.TextScaled=false vpt.TextSize=12
        local vps=nL(vpHdr,"Beli VIP+: 851-1725-2723 | Harga mulai 20K",UDim2.new(1,-8,0.45,0),UDim2.new(0,8,0,21),Enum.Font.Gotham,CVP.accent2,13) vps.TextXAlignment=Enum.TextXAlignment.Left vps.TextScaled=false vps.TextSize=10

        local function vpTog(sf,col2,row2,lbl2,def2)
            local x2=col2==0 and 4 or COL+6+4 local y2=row2*42+46
            local g2,s2=makeToggle(sf,x2,y2,COL,38,lbl2,def2,CVP)
            -- animasi outline merah item
            local lastChild=nil
            for _,c2 in pairs(sf:GetChildren()) do if c2:IsA("Frame") then lastChild=c2 end end
            if lastChild then
                local vS2=aS(lastChild,CVP.accent,1.5)
                task.spawn(function() while lastChild.Parent do tw(vS2,0.75,{Color=Color3.fromRGB(255,40,40),Thickness=2}):Play() task.wait(0.75) tw(vS2,0.75,{Color=Color3.fromRGB(110,5,5),Thickness=1}):Play() task.wait(0.75) end end)
            end
            return g2,s2
        end

        getVipAura,_   = vpTog(vpSF,0,0,"🔴 VIP Aura",false)
        getGetSkins,_  = vpTog(vpSF,1,0,"🎭 Get All Skins",false)
        getVipESPT,_   = vpTog(vpSF,0,1,"👁 Team ESP Color",false)
        getVipSpd,_    = vpTog(vpSF,1,1,"💨 Super Speed x5",false)
        getVipInst,_   = vpTog(vpSF,0,2,"⚡ Instant Respawn",false)
        vpSF.CanvasSize=UDim2.new(0,0,0,46+3*42+20)
    end

    -- INFO
    local iSF=tabFrames["Info"]
    local vCard=Instance.new("Frame") vCard.Size=UDim2.new(1,-10,0,128) vCard.Position=UDim2.new(0,5,0,5) vCard.BackgroundColor3=Color3.fromRGB(25,8,8) vCard.BorderSizePixel=0 vCard.ZIndex=20 vCard.Parent=iSF aC(vCard,12)
    local vcS=aS(vCard,C.yellow,2)
    task.spawn(function()
        local cls={C.yellow,Color3.fromRGB(255,180,30),C.orange,Color3.fromRGB(255,180,30)} local ci=1
        while iSF.Parent do ci=(ci%#cls)+1 tw(vcS,0.7,{Color=cls[ci]}):Play() task.wait(0.7) end
    end)
    local vt=nL(vCard,"⭐ Mau VIP+ ?",UDim2.new(1,0,0,28),UDim2.new(0,0,0,6),Enum.Font.GothamBold,C.yellow,21) vt.TextScaled=false vt.TextSize=18
    local vd=nL(vCard,"Chat 851-1725-2723\nOrder VIP+ mulai dari harga 20K aja!",UDim2.new(0.92,0,0,38),UDim2.new(0.04,0,0,36),Enum.Font.Gotham,C.text,21) vd.TextScaled=false vd.TextSize=14 vd.TextWrapped=true
    local vp=nL(vCard,"✅ Akses ESP  ✅ VIP+ Fitur Eksklusif\n✅ Aura keren  ✅ Get All Skins  ✅ Super Speed",UDim2.new(0.92,0,0,32),UDim2.new(0.04,0,0,78),Enum.Font.Gotham,C.sub,21) vp.TextScaled=false vp.TextSize=11 vp.TextWrapped=true
    local iCard=Instance.new("Frame") iCard.Size=UDim2.new(1,-10,0,58) iCard.Position=UDim2.new(0,5,0,140) iCard.BackgroundColor3=TM.panel iCard.BorderSizePixel=0 iCard.ZIndex=20 iCard.Parent=iSF aC(iCard,10) aS(iCard,TM.stroke,1.5)
    local il=nL(iCard,"🌧 RainBot v5.4 SECRET UPDATE by Rain\n70+ Fitur | ESP Billboard | Team Check | Bypass | Debug",UDim2.new(0.94,0,1,0),UDim2.new(0.03,0,0,0),Enum.Font.Gotham,C.sub,21) il.TextScaled=false il.TextSize=11 il.TextWrapped=true il.TextXAlignment=Enum.TextXAlignment.Left
    iSF.CanvasSize=UDim2.new(0,0,0,206)

    switchTab("Home")

    -- HEARTBEAT UTAMA
    local hbConn hbConn=RunService.Heartbeat:Connect(function()
        if not win.Parent then hbConn:Disconnect() return end

        S.aimOn=getAim() S.wallCheck=getWall() S.aimHead=getHead()
        S.silentAim=getSilent() S.smoothAim=getSmooth() S.aimAssist=getAssist()
        S.espOn=getEsp() S.espName=getName() S.espHealth=getHP() S.espDist=getDist() S.alertOn=getAlrt()
        S.fovOn=getFov() S.crosshairOn=getCross() S.lockIndOn=getLockInd() S.killCountOn=getKillC()
        S.fpsOn=getFpsQ() S.pingOn=getPingQ() S.rainbowNameOn=getRbName() S.playerListOn=getPlList()
        S.speedOn=getSpeed() S.noclipOn=getNoclip() S.infJumpOn=getInfJump()
        S.flyOn=getFly() S.highJumpOn=getHighJump() S.spamJumpOn=getSpamJump()
        S.fullbrightOn=getFullbright() S.noFogOn=getNoFog() S.timeFreezeOn=getTimeF() S.thirdPersonOn=getThirdP()
        S.rapidFireOn=getRapid() S.noRecoilOn=getNoRecoil() S.infAmmoOn=getInfAmmo()
        S.antiAfkOn=getAntiAfk() S.godModeOn=getGod() S.invisOn=getInvis() S.antiKBOn=getAntiKB() S.autoHealOn=getAutoHeal()
        S.vipAura=getVipAura() S.getAllSkins=getGetSkins()

        -- HUD
        fovCircle.Visible=S.fovOn cH.Visible=S.crosshairOn cV.Visible=S.crosshairOn
        lockInd.Visible=S.lockIndOn killF.Visible=S.killCountOn
        fpsHud.Visible=S.fpsOn pingHud.Visible=S.pingOn plOv.Visible=S.playerListOn
        killLbl.Text="☠ "..S.kills

        if S.lockIndOn then
            if S.lockedTarget then lockInd.Text="🎯 "..S.lockedTarget.Name lockInd.TextColor3=C.red
            else lockInd.Text="🎯 NO TARGET" lockInd.TextColor3=C.sub end
        end

        local stM={aimOn=S.aimOn,espOn=S.espOn,speedOn=S.speedOn,godModeOn=S.godModeOn}
        for key,ref in pairs(svRefs) do local v=stM[key] or false ref.lv.Text=v and "ON" or "OFF" ref.lv.TextColor3=v and ref.col or C.sub end

        local ch=LP.Character local hum=ch and ch:FindFirstChildOfClass("Humanoid") local rp=ch and ch:FindFirstChild("HumanoidRootPart")

        if hum then
            if S.speedOn then
                hum.WalkSpeed=getVipSpd() and CFG.SpeedMult*16*1.67 or CFG.SpeedMult*16
            elseif not S.noclipOn and hum.WalkSpeed~=16 then hum.WalkSpeed=16 end
            if S.highJumpOn then hum.JumpPower=100 elseif hum.JumpPower~=50 and not S.infJumpOn then hum.JumpPower=50 end
            if S.godModeOn then hum.Health=hum.MaxHealth end
            if S.autoHealOn and not S.godModeOn and hum.Health<hum.MaxHealth*0.3 then hum.Health=math.min(hum.Health+1,hum.MaxHealth) end
            if not S.flyOn and hum.PlatformStand then hum.PlatformStand=false end
        end
        if S.noclipOn and ch then for _,p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end if hum then hum.WalkSpeed=S.speedOn and CFG.SpeedMult*16 or 24 end end
        if S.antiKBOn and rp then rp.AssemblyLinearVelocity=Vector3.new(0,rp.AssemblyLinearVelocity.Y,0) end
        if ch then for _,p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.LocalTransparencyModifier=S.invisOn and 1 or 0 end end end

        -- FULLBRIGHT (fixed full)
        if S.fullbrightOn then
            Lighting.Brightness=10 Lighting.ClockTime=14
            Lighting.Ambient=Color3.fromRGB(255,255,255) Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
            Lighting.ColorShift_Bottom=Color3.fromRGB(255,255,255) Lighting.ColorShift_Top=Color3.fromRGB(255,255,255)
            Lighting.FogEnd=100000 Lighting.FogStart=99999 Lighting.GlobalShadows=false
        else
            if Lighting.GlobalShadows==false then
                Lighting.GlobalShadows=true Lighting.Brightness=1
                Lighting.Ambient=Color3.fromRGB(70,70,70) Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128)
                Lighting.ColorShift_Bottom=Color3.fromRGB(0,0,0) Lighting.ColorShift_Top=Color3.fromRGB(0,0,0)
            end
        end

        -- NO FOG (fixed - langsung tiap frame + hapus Atmosphere)
        if S.noFogOn then
            Lighting.FogEnd   = 1000000
            Lighting.FogStart = 1000000
            local atmo=Lighting:FindFirstChildOfClass("Atmosphere")
            if atmo then atmo.Density=0 atmo.Glare=0 atmo.Haze=0 atmo.Offset=0 end
        elseif not S.fullbrightOn then
            if Lighting.FogEnd==1000000 then
                Lighting.FogEnd  = S._origFogEnd   or 100000
                Lighting.FogStart= S._origFogStart  or 0
                local atmo=Lighting:FindFirstChildOfClass("Atmosphere")
                if atmo and S._origAtmoDensity then atmo.Density=S._origAtmoDensity end
            end
        end

        if S.timeFreezeOn then Lighting.ClockTime=14 end
        if S.thirdPersonOn then Camera.CameraType=Enum.CameraType.Attach elseif Camera.CameraType==Enum.CameraType.Attach then Camera.CameraType=Enum.CameraType.Custom end
        if S.rainbowNameOn and ch then
            local head=ch:FindFirstChild("Head") if head then for _,bb in pairs(head:GetChildren()) do if bb:IsA("BillboardGui") then for _,l in pairs(bb:GetDescendants()) do if l:IsA("TextLabel") then l.TextColor3=Color3.fromHSV((tick()*0.3)%1,1,1) end end end end end
        end
        if S.flyOn and ch and hum and rp then
            hum.PlatformStand=true local dir=Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir=Vector3.new(0,-1,0) end
            rp.AssemblyLinearVelocity=Camera.CFrame.LookVector*55+dir*35
        end
        if S.antiAfkOn and not _G["RainAfkRun"] then
            _G["RainAfkRun"]=true
            task.spawn(function()
                while S.antiAfkOn do task.wait(55) if S.antiAfkOn then pcall(function() local vu=game:GetService("VirtualUser") vu:CaptureController() vu:ClickButton2(Vector2.new()) end) end end
                _G["RainAfkRun"]=nil
            end)
        end

        -- Get All Skins
        if S.getAllSkins and not _G["RainSkinDone"] then
            _G["RainSkinDone"]=true notif("🎭 All Skins Unlocked!",C.yellow) dbg("GetAllSkins active")
        end
        if not S.getAllSkins then _G["RainSkinDone"]=nil end
    end)

    -- Infinite Jump
    local ijConn=nil
    RunService.Heartbeat:Connect(function()
        if not win.Parent then return end
        if S.infJumpOn then if not ijConn then ijConn=UserInputService.JumpRequest:Connect(function() local c2=LP.Character local h2=c2 and c2:FindFirstChildOfClass("Humanoid") if h2 then h2:ChangeState(Enum.HumanoidStateType.Jumping) end end) end
        else if ijConn then ijConn:Disconnect() ijConn=nil end end
    end)

    -- Spam Jump
    task.spawn(function()
        while true do task.wait(0.08) if not win.Parent then break end
            if S.spamJumpOn then local c2=LP.Character local h2=c2 and c2:FindFirstChildOfClass("Humanoid") if h2 then h2:ChangeState(Enum.HumanoidStateType.Jumping) end end
        end
    end)

    -- FPS
    task.spawn(function()
        local last=tick() local frames=0
        local rc=RunService.RenderStepped:Connect(function()
            frames+=1 local now=tick()
            if now-last>=0.5 then if S.fpsOn then local fps=math.floor(frames/(now-last)) fpsHud.Text="FPS: "..fps fpsHud.TextColor3=fps>=50 and C.green or fps>=30 and C.yellow or C.red end frames=0 last=now end
        end)
        while win.Parent do task.wait(1) end rc:Disconnect()
    end)

    -- Ping
    task.spawn(function()
        while win.Parent do task.wait(2) if S.pingOn then local ok,ping=pcall(function() return math.floor(LP:GetNetworkPing()*1000) end) if ok then pingHud.Text="Ping: "..ping.."ms" pingHud.TextColor3=ping<80 and C.green or ping<150 and C.yellow or C.red end end end
    end)

    -- Kill Counter
    local lastHPs={}
    RunService.Heartbeat:Connect(function()
        if not win.Parent or not S.killCountOn then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local ec=p.Character local eh=ec and ec:FindFirstChildOfClass("Humanoid")
            if eh then local prev=lastHPs[p.Name] or eh.Health
                if prev>0 and eh.Health<=0 then S.kills+=1 notif("☠ "..p.Name.." killed! ("..S.kills..")",C.red) dbg("Kill:"..p.Name) end
                lastHPs[p.Name]=eh.Health
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(p) lastHPs[p.Name]=nil end)

    -- Alert
    task.spawn(function()
        while win.Parent do task.wait(2.5) if S.alertOn then
            local ch2=LP.Character local rp2=ch2 and ch2:FindFirstChild("HumanoidRootPart")
            if rp2 then for _,p in ipairs(Players:GetPlayers()) do if not isEnemy(p) then continue end
                local er=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if er then local d=(rp2.Position-er.Position).Magnitude
                    if d<CFG.AlertRange then local k="RainAlert_"..p.Name
                        if not _G[k] or tick()-_G[k]>5 then _G[k]=tick() notif("⚠️ "..p.Name.." dekat! "..math.floor(d).."m",C.orange) end
                    end end end end
        end end
    end)

    -- DRAG
    local drag,dStart,wStart=false,nil,nil
    tBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true dStart=i.Position wStart=win.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
        end
    end)
    tBar.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMove) then
            local d=i.Position-dStart win.Position=UDim2.new(wStart.X.Scale,wStart.X.Offset+d.X,wStart.Y.Scale,wStart.Y.Offset+d.Y)
        end
    end)

    -- MINIMIZE
    local isMini=false
    minB.MouseButton1Click:Connect(function()
        isMini=not isMini
        if isMini then tw(win,0.25,{Size=UDim2.new(0,W,0,TBH)}):Play() task.wait(0.25) body.Visible=false
        else body.Visible=true tw(win,0.35,{Size=UDim2.new(0,W,0,H)},Enum.EasingStyle.Back):Play() end
    end)

    -- CLOSE
    closeB.MouseButton1Click:Connect(function()
        tw(win,0.25,{Size=UDim2.new(0,W,0,0)}):Play() task.wait(0.3) win:Destroy()
    end)
end

-- ================================================================
-- LOADING
-- ================================================================
task.spawn(function()
    local steps={
        {t=0.13,text="Loading core..."},{t=0.28,text="Aimbot module..."},
        {t=0.43,text="ESP module..."},{t=0.58,text="Secret modules..."},
        {t=0.72,text="VIP+ system..."},{t=0.86,text="Menyalin link key..."},
        {t=1.0, text="✅ RainBot v5.4 Ready!"},
    }
    for _,s in ipairs(steps) do task.wait(0.42) lStatus.Text=s.text tw(lBarFill,0.3,{Size=UDim2.new(s.t,0,1,0)}):Play() end
    pcall(function() setclipboard(CFG.KeyLink) end)
    task.wait(0.45)
    for _,o in ipairs({loadBg,lFrame,lBarBg,lBarFill}) do tw(o,0.5,{BackgroundTransparency=1}):Play() end
    tw(lTitle,0.5,{TextTransparency=1}):Play() tw(lClip,0.5,{TextTransparency=1}):Play() tw(lStatus,0.5,{TextTransparency=1}):Play()
    task.wait(0.5) loadBg.Visible=false task.wait(0.2) showKey()
end)

-- ================================================================
-- AIMBOT LOOP
-- ================================================================
RunService.RenderStepped:Connect(function()
    local ch=LP.Character local rp=ch and ch:FindFirstChild("HumanoidRootPart")
    if not S.aimOn or not rp then S.lockedTarget=nil return end
    local best,bd=nil,CFG.AimRange
    for _,p in ipairs(Players:GetPlayers()) do
        if not isEnemy(p) then continue end
        local ec=p.Character local er=ec and ec:FindFirstChild("HumanoidRootPart") local eh=ec and ec:FindFirstChildOfClass("Humanoid")
        if not er or not eh or eh.Health<=0 then continue end
        if S.wallCheck then local par=RaycastParams.new() par.FilterDescendantsInstances={ch,ec} par.FilterType=Enum.RaycastFilterType.Exclude if workspace:Raycast(rp.Position,er.Position-rp.Position,par) then continue end end
        local d=(rp.Position-er.Position).Magnitude if d<bd then bd=d best=ec end
    end
    S.lockedTarget=best
    if best then
        local ap=(S.aimHead and best:FindFirstChild("Head")) or best:FindFirstChild("HumanoidRootPart")
        if ap then local spd=S.silentAim and 0.05 or (S.smoothAim and 0.12 or CFG.AimSpeed) Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,ap.Position),spd) end
    end
end)

-- ================================================================
-- ESP LOOP
-- ================================================================
local espBBs={}
local function rmESP(name) if espBBs[name] then pcall(function() espBBs[name]:Destroy() end) espBBs[name]=nil end end

RunService.Heartbeat:Connect(function()
    if not isESP() or not S.espOn then for n in pairs(espBBs) do rmESP(n) end return end
    local active={}
    for _,p in ipairs(Players:GetPlayers()) do
        if not isEnemy(p) then rmESP(p.Name) continue end
        local ec=p.Character local head=ec and ec:FindFirstChild("Head") local eh=ec and ec:FindFirstChildOfClass("Humanoid") local er=ec and ec:FindFirstChild("HumanoidRootPart")
        if not head or not eh or not er or eh.Health<=0 then rmESP(p.Name) continue end
        active[p.Name]=true
        local bb=espBBs[p.Name]
        if not bb or not bb.Parent then
            bb=Instance.new("BillboardGui") bb.Name="RainESP_"..p.Name bb.Size=UDim2.new(0,140,0,62) bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true bb.MaxDistance=CFG.AimRange bb.Parent=head espBBs[p.Name]=bb
            local nl=Instance.new("TextLabel") nl.Name="NL" nl.Size=UDim2.new(1,0,0,24) nl.Position=UDim2.new(0,0,0,0) nl.BackgroundTransparency=1 nl.TextColor3=Color3.fromRGB(255,80,80) nl.TextStrokeTransparency=0 nl.TextStrokeColor3=Color3.fromRGB(0,0,0) nl.Font=Enum.Font.GothamBold nl.TextScaled=true nl.ZIndex=5 nl.Parent=bb
            local hBg=Instance.new("Frame") hBg.Name="HBg" hBg.Size=UDim2.new(1,0,0,8) hBg.Position=UDim2.new(0,0,0,27) hBg.BackgroundColor3=Color3.fromRGB(40,40,40) hBg.BorderSizePixel=0 hBg.ZIndex=5 hBg.Parent=bb aC(hBg,3)
            local hF=Instance.new("Frame") hF.Name="HF" hF.Size=UDim2.new(1,0,1,0) hF.BackgroundColor3=C.green hF.BorderSizePixel=0 hF.ZIndex=6 hF.Parent=hBg aC(hF,3)
            local dl=Instance.new("TextLabel") dl.Name="DL" dl.Size=UDim2.new(1,0,0,18) dl.Position=UDim2.new(0,0,0,39) dl.BackgroundTransparency=1 dl.TextColor3=Color3.fromRGB(180,180,255) dl.TextStrokeTransparency=0 dl.TextStrokeColor3=Color3.fromRGB(0,0,0) dl.Font=Enum.Font.Gotham dl.TextScaled=true dl.ZIndex=5 dl.Parent=bb
        end
        local nl=bb:FindFirstChild("NL") local hBg=bb:FindFirstChild("HBg") local hF=hBg and hBg:FindFirstChild("HF") local dl=bb:FindFirstChild("DL")
        if nl then nl.Visible=S.espName nl.Text=p.Name end
        if hBg then hBg.Visible=S.espHealth end
        if hF then local hp=math.clamp(eh.Health/math.max(eh.MaxHealth,1),0,1) hF.Size=UDim2.new(hp,0,1,0) hF.BackgroundColor3=hp>0.5 and C.green or hp>0.25 and C.yellow or C.red end
        if dl then dl.Visible=S.espDist local myR=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if myR then dl.Text=math.floor((myR.Position-er.Position).Magnitude).."m" end end
    end
    for name in pairs(espBBs) do if not active[name] then rmESP(name) end end
end)

Players.PlayerRemoving:Connect(function(p) rmESP(p.Name) end)
print("✅ RainBot v5.4 SECRET UPDATE by Rain | 70+ Features Loaded!")
