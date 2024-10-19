local vui = vgui.Create

surface.CreateFont("FontWar", {
    font = "Arial",
    extended = true,
    size = 20
})

surface.CreateFont("FontWarHelp", {
    font = "Impact",
    extended = true,
    size = 15
})



net.Receive("SpawnSentKD_", function(len, ply)

    notification.AddLegacy( "Кулдаун завершен, можно спавнить!", NOTIFY_GENERIC, 5 )
    surface.PlaySound( "buttons/button17.wav" )
    Msg( "Кулдаун прошел!\n" )
    
end)


net.Receive("SpawnSentKD_Message", function(len, ply)

    local message = net.ReadString()

    notification.AddLegacy( "Подождите окончания кулдауна: " ..message.. " сек.", NOTIFY_ERROR, 3 )
    surface.PlaySound( "buttons/button14.wav" )
    Msg( "Подождите окончания кулдауна!\n" )

end)



net.Receive("SpawnSentKD_StartMessage", function(len, ply)

    local Timer_Start = net.ReadString()

    notification.AddLegacy( "Подождите " ..Timer_Start.. " секунд до следующего спавна!", NOTIFY_HINT, 5 )
    surface.PlaySound( "buttons/button15.wav" )
    Msg( "Подождите!\n" )

end)

net.Receive("SpawnSentKD_MenuTrigger", function(len, ply)

    local PrivaRead = net.ReadString()
    local EntityTable = net.ReadTable()
    local plymenu = net.ReadPlayer()


    if PrivaRead != "superadmin" then

        local WarningFrame = vui( "DFrame" )
        WarningFrame:SetPos(ScrW() / 2.22, ScrH() / 2.22)
        WarningFrame:SetSize( 200, 100 ) 
        WarningFrame:SetTitle( "" )  
        WarningFrame:SetDraggable( false ) 
        WarningFrame:ShowCloseButton( false ) 
        WarningFrame:MakePopup()
        WarningFrame.Paint = function(self, w, h)

            draw.RoundedBox(2, 0, 0, w, h, Color(0, 0, 0, 200))
            
            draw.SimpleText("Отказано!", "FontWar", 100, 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	    end

        local CloseButton = vui( "DButton", WarningFrame )
        CloseButton:SetText( "Закрыть" )
        CloseButton:SetPos( 50, 70 )
        CloseButton:SetSize( 100, 20 )
        CloseButton.DoClick = function()
            WarningFrame:Remove()
            surface.PlaySound( "menusound.wav" )
        end

        local Text = vui( "DLabel", WarningFrame )
        Text:SetPos( 50, 40 )
        Text:SetText( "Недостаточно прав!" )
        Text:SizeToContents()

        

    else


        local MainMenu = vui( "DFrame" )
        MainMenu:SetPos(ScrW() / 2.90, ScrH() / 2.90)
        MainMenu:SetSize( 600, 300 ) 
        MainMenu:SetTitle( "" )  
        MainMenu:SetDraggable( false ) 
        MainMenu:ShowCloseButton( false ) 
        MainMenu:MakePopup()
        MainMenu.Paint = function(self, w, h)

            draw.RoundedBox(20, 0, 0, w, h, Color(0, 0, 0, 225))


            draw.RoundedBox(0, 186, 25, 3, 300, Color(0, 0, 0, 255))
            draw.RoundedBox(0, 0, 25, 600, 3, Color(0, 0, 0, 255))
            
            draw.SimpleText("Установка кд", "FontWar", 300, 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	    end


        local CloseButton = vui( "DButton", MainMenu )
        CloseButton:SetText( "Закрыть" )
        CloseButton:SetPos( 490, 270 )
        CloseButton:SetSize( 100, 20 )
        CloseButton.DoClick = function()
            MainMenu:Remove()
            surface.PlaySound( "exitsound.mp3" )
        end

        local Texthelp = vui( "DLabel", MainMenu )
        Texthelp:SetPos( 50, 30 )
        Texthelp:SetText( "Список / Удалить" )
        Texthelp:SizeToContents()

        local Texthelp1 = vui( "DLabel", MainMenu )
        Texthelp1:SetPos( 365, 59 )
        Texthelp1:SetText( "- Название обьекта | Пример - combine_mine" )
        Texthelp1:SizeToContents()

        local Texthelp2 = vui( "DLabel", MainMenu )
        Texthelp2:SetPos( 365, 91 )
        Texthelp2:SetText( "- Кулдаун" )
        Texthelp2:SizeToContents()

        local Texthelp3 = vui( "DLabel", MainMenu )
        Texthelp3:SetPos( 250, 30 )
        Texthelp3:SetText( "Добавить" )
        Texthelp3:SizeToContents()


        local DScrollPanel = vui( "DScrollPanel", MainMenu ) 
        DScrollPanel:Dock( LEFT ) 
        DScrollPanel:SetWide(170)
        DScrollPanel:DockMargin(0,28,0,28)

        for _, v in ipairs(EntityTable) do
            if v.name == "Не Удалять!Wаrning!" then
            
            else

                local DButton = DScrollPanel:Add( "DButton" ) 
                DButton:SetText( v.name.." - "..v.cooldown.." сек" )
                DButton:Dock( TOP ) 
                DButton:DockMargin( 0, 0, 0, 10 )
                DButton.DoClick = function()
                surface.PlaySound( "delete.mp3" )

                net.Start( "SpawnSentKD_MenuTriggerTableDel" )
                net.WriteString(v.name)
                net.SendToServer()

                DButton:Remove()
                
            end

            end

            
        end



        local NameEntry = vui("DTextEntry", MainMenu)
        NameEntry:SetPos(200, 57)
        NameEntry:SetSize(150, 20)
        NameEntry:SetText("string")


        local CooldownEntry = vui("DNumberWang", MainMenu)
        CooldownEntry:SetPos(200, 89)
        CooldownEntry:SetSize(150, 20)
        CooldownEntry:SetMin(10)
        CooldownEntry:SetMax(1000)
        CooldownEntry:SetValue(10)


        local AddEntryButton = vui("DButton", MainMenu)
        AddEntryButton:SetText("Добавить в список")
        AddEntryButton:SetPos(200, 120)
        AddEntryButton:SetSize(150, 20)
        AddEntryButton.DoClick = function()


            surface.PlaySound( "menusound.wav" )
            local NameEntryKD = NameEntry:GetValue()
            local cooldownKD = CooldownEntry:GetValue()

            NameEntry:SetText("string")
            CooldownEntry:SetValue(10)

            if NameEntryKD == "" then  
                return 
            end

            if NameEntryKD == "string" then  
                return 
            end

            if cooldownKD <= 0 then 
                cooldownKD = 1
            end

            net.Start( "SpawnSentKD_MenuTriggerTable" ) 
            net.WriteString(NameEntryKD) 
            net.WriteFloat(cooldownKD) 
            net.SendToServer()

            MainMenu:Remove()

            net.Start( "SpawnSentKD_MenuTriggerReturMenu" ) 
            net.WritePlayer(plymenu) 
            net.SendToServer()
            

        end





    end

end)
