local notifications = {}

local function CreateNotification(text, color, duration)
    local notification = {}
    notification.text = text
    notification.color = color
    notification.start = CurTime()
    notification.duration = duration
    notification.y = ScrH()
    notification.alpha = 0
    notification.id = math.random(1, 1000000)
    
    table.insert(notifications, notification)
    return notification.id
end

local function DrawNotifications()
    local currentTime = CurTime()
    local startY = ScrH() - 100
    
    for i = #notifications, 1, -1 do
        local notif = notifications[i]
        local life = currentTime - notif.start
        local progress = life / notif.duration
        
        if progress >= 1 then
            table.remove(notifications, i)
            continue
        end
        
        local alpha = 0
        local x = ScrW() + 10
        local targetY = startY - (#notifications - i) * 70
        
        if progress < 0.2 then
            alpha = progress / 0.2
            x = ScrW() - 400 * (progress / 0.2)
        elseif progress > 0.8 then
            alpha = (1 - progress) / 0.2
            x = ScrW() - 400
        else
            alpha = 1
            x = ScrW() - 400
        end
        
        notif.alpha = alpha
        notif.y = Lerp(0.1, notif.y, targetY)
        
        draw.RoundedBox(8, x, notif.y, 380, 60, Color(20, 20, 30, 200 * alpha))
        
        surface.SetDrawColor(notif.color.r, notif.color.g, notif.color.b, 150 * alpha)
        surface.DrawOutlinedRect(x, notif.y, 380, 60, 2)
        
        surface.SetDrawColor(notif.color.r, notif.color.g, notif.color.b, 30 * alpha)
        surface.DrawRect(x, notif.y, 380, 60)
        
        draw.SimpleText("КУЛДАУН", "DermaDefaultBold", x + 15, notif.y + 10, Color(220, 220, 255, 255 * alpha))
        
        draw.SimpleText(notif.text, "DermaDefault", x + 15, notif.y + 35, Color(255, 255, 255, 255 * alpha))
        
        local barWidth = 350 * (1 - progress)
        draw.RoundedBox(4, x + 15, notif.y + 55, 350, 3, Color(60, 60, 80, 200 * alpha))
        draw.RoundedBox(4, x + 15, notif.y + 55, barWidth, 3, Color(notif.color.r, notif.color.g, notif.color.b, 255 * alpha))
    end
end

hook.Add("HUDPaint", "DrawCooldownNotifications", DrawNotifications)

net.Receive("SpawnSentKD_StartMessage", function()
    local cooldown = net.ReadString()
    CreateNotification("Кулдаун начался: " .. cooldown .. " сек.", Color(70, 130, 255), 5)
end)

net.Receive("SpawnSentKD_Message", function()
    local cooldown = net.ReadString()
    CreateNotification("Кулдаун: " .. cooldown .. " сек.", Color(255, 100, 100), 3)
end)

net.Receive("SpawnSentKD_", function()
    CreateNotification("Кулдаун закончился!", Color(100, 255, 100), 5)
end)
