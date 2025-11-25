local function CreateCooldownMenu()
    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 700)
    frame:SetTitle("")
    frame:SetSizable(false)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(20, 20, 30, 250))
        
        surface.SetDrawColor(70, 130, 255, 100)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        draw.SimpleText("УПРАВЛЕНИЕ КУЛДАУНАМИ", "DermaLarge", w/2, 25, Color(220, 220, 255), TEXT_ALIGN_CENTER)
        
        surface.SetDrawColor(70, 130, 255, 80)
        surface.DrawLine(50, 60, w-50, 60)
    end

    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetSize(30, 30)
    closeButton:SetPos(frame:GetWide() - 40, 10)
    closeButton:SetText("×")
    closeButton:SetFont("DermaLarge")
    closeButton:SetTextColor(Color(255, 100, 100))
    closeButton.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(8, 0, 0, w, h, Color(255, 100, 100, 30))
        end
    end
    closeButton.DoClick = function()
        frame:Close()
    end

    local addPanel = vgui.Create("DPanel", frame)
    addPanel:SetPos(30, 80)
    addPanel:SetSize(540, 120)
    addPanel.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(30, 30, 40, 255))
        surface.SetDrawColor(100, 150, 255, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        draw.SimpleText("ДОБАВИТЬ НОВЫЙ КУЛДАУН", "DermaDefaultBold", 15, 10, Color(200, 220, 255))
    end

    local nameEntry = vgui.Create("DTextEntry", addPanel)
    nameEntry:SetPos(20, 35)
    nameEntry:SetSize(500, 35)
    nameEntry:SetPlaceholderText("Название ентити (например: prop_physics, weapon_pistol)")
    nameEntry:SetFont("DermaDefault")
    nameEntry.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 50))
        surface.SetDrawColor(70, 130, 255, self:IsEditing() and 200 or 100)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        self:DrawTextEntryText(Color(255, 255, 255), Color(70, 130, 255), Color(255, 255, 255))
    end

    local cooldownEntry = vgui.Create("DTextEntry", addPanel)
    cooldownEntry:SetPos(20, 80)
    cooldownEntry:SetSize(240, 35)
    cooldownEntry:SetPlaceholderText("Кулдаун в секундах")
    cooldownEntry:SetNumeric(true)
    cooldownEntry:SetFont("DermaDefault")
    cooldownEntry.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 50))
        surface.SetDrawColor(70, 130, 255, self:IsEditing() and 200 or 100)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        self:DrawTextEntryText(Color(255, 255, 255), Color(70, 130, 255), Color(255, 255, 255))
    end

    local addButton = vgui.Create("DButton", addPanel)
    addButton:SetPos(280, 80)
    addButton:SetSize(240, 35)
    addButton:SetText("ДОБАВИТЬ")
    addButton:SetFont("DermaDefaultBold")
    addButton:SetTextColor(Color(255, 255, 255))
    
    local addButtonHover = 0
    addButton.Paint = function(self, w, h)
        local hover = math.min(addButtonHover + (self:IsHovered() and 3 or -3), 100)
        addButtonHover = hover
        
        local glow = hover * 0.5
        draw.RoundedBox(8, 0, 0, w, h, Color(40 + glow, 80 + glow, 180 + glow))
        
        surface.SetDrawColor(100, 180, 255, 100 + hover)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        if self:IsHovered() then
            draw.RoundedBox(8, -2, -2, w+4, h+4, Color(100, 180, 255, 20))
        end
    end
    
    addButton.DoClick = function()
        local name = nameEntry:GetValue()
        local cooldown = tonumber(cooldownEntry:GetValue())
        
        if name == "" or not cooldown or cooldown <= 0 then
            Derma_Message("Заполните все поля корректно!", "Ошибка")
            return
        end
        
        net.Start("KD_AddEntity")
        net.WriteString(name)
        net.WriteUInt(cooldown, 16)
        net.SendToServer()
        
        nameEntry:SetValue("")
        cooldownEntry:SetValue("")
        
        timer.Simple(0.5, function()
            if IsValid(frame) then
                RefreshList()
            end
        end)
    end

    local listPanel = vgui.Create("DPanel", frame)
    listPanel:SetPos(30, 220)
    listPanel:SetSize(540, 430)
    listPanel.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(30, 30, 40, 255))
        surface.SetDrawColor(100, 150, 255, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        draw.SimpleText("СПИСОК КУЛДАУНОВ", "DermaDefaultBold", 15, 10, Color(200, 220, 255))
    end

    local scroll = vgui.Create("DScrollPanel", listPanel)
    scroll:SetPos(10, 35)
    scroll:SetSize(520, 385)

    function RefreshList()
        net.Start("KD_RequestList")
        net.SendToServer()
    end

    net.Receive("KD_UpdateList", function()
        local entities = net.ReadTable()
        
        scroll:Clear()
        
        for i, ent in ipairs(entities) do
            local item = vgui.Create("DPanel", scroll)
            item:SetPos(0, (i-1)*70)
            item:SetSize(520, 65)
            
            local itemHover = 0
            item.Paint = function(self, w, h)
                local hover = math.min(itemHover + (self:IsHovered() and 3 or -3), 50)
                itemHover = hover
                
                draw.RoundedBox(8, 0, 0, w, h, Color(35 + hover, 35 + hover, 45 + hover))
                
                surface.SetDrawColor(70, 130, 255, 80 + hover)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
                
                if self:IsHovered() then
                    draw.RoundedBox(8, -2, -2, w+4, h+4, Color(70, 130, 255, 10))
                end
            end

            local nameLabel = vgui.Create("DLabel", item)
            nameLabel:SetPos(20, 12)
            nameLabel:SetSize(400, 25)
            nameLabel:SetText(ent.name:upper())
            nameLabel:SetTextColor(Color(220, 240, 255))
            nameLabel:SetFont("DermaDefaultBold")

            local cooldownLabel = vgui.Create("DLabel", item)
            cooldownLabel:SetPos(20, 35)
            cooldownLabel:SetSize(400, 20)
            cooldownLabel:SetText("Кулдаун: " .. ent.cooldown .. " секунд")
            cooldownLabel:SetTextColor(Color(180, 200, 255))
            cooldownLabel:SetFont("DermaDefault")

            local deleteButton = vgui.Create("DButton", item)
            deleteButton:SetPos(430, 15)
            deleteButton:SetSize(80, 35)
            deleteButton:SetText("УДАЛИТЬ")
            deleteButton:SetFont("DermaDefault")
            deleteButton:SetTextColor(Color(255, 255, 255))
            
            local deleteHover = 0
            deleteButton.Paint = function(self, w, h)
                local hover = math.min(deleteHover + (self:IsHovered() and 5 or -5), 80)
                deleteHover = hover
                
                draw.RoundedBox(6, 0, 0, w, h, Color(180 + hover, 60, 60))
                
                surface.SetDrawColor(255, 100, 100, 150 + hover)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
                
                if self:IsHovered() then
                    draw.RoundedBox(6, -2, -2, w+4, h+4, Color(255, 100, 100, 20))
                end
            end
            
            deleteButton.DoClick = function()
                net.Start("KD_RemoveEntity")
                net.WriteString(ent.name)
                net.SendToServer()
                
                timer.Simple(0.5, function()
                    if IsValid(frame) then
                        RefreshList()
                    end
                end)
            end
        end
        
        scroll:InvalidateLayout()
    end)

    RefreshList()

    local refreshButton = vgui.Create("DButton", frame)
    refreshButton:SetPos(30, 660)
    refreshButton:SetSize(540, 30)
    refreshButton:SetText("ОБНОВИТЬ СПИСОК")
    refreshButton:SetFont("DermaDefault")
    refreshButton:SetTextColor(Color(255, 255, 255))
    refreshButton.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(60, 60, 80))
        surface.SetDrawColor(100, 150, 255, self:IsHovered() and 200 or 100)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        if self:IsHovered() then
            draw.RoundedBox(6, 0, 0, w, h, Color(70, 130, 255, 30))
        end
    end
    refreshButton.DoClick = RefreshList
end

concommand.Add("kd_menu", CreateCooldownMenu)

net.Receive("SpawnSentKD_Command", function()

    RunConsoleCommand("kd_menu")

end)
