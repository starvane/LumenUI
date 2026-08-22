-- example.lua
-- Demonstrates ALL features of the LumenHub UI library, including Key System.
-- Run this script in a Roblox executor that supports the required functions.

local SOURCE_URL = "https://raw.githubusercontent.com/starvane/LumenUI/refs/heads/main/library.lua" -- Replace with your actual loading method (loadstring, require, etc.)
local ok, Lumen = pcall(function()
    return loadstring(game:HttpGet(SOURCE_URL))()
end)

if not ok or not Lumen then
    warn("[LumenHub] Gagal memuat LumenUI:", Chloex)
    return
end

-- ==============================
-- 1. CREATE THE MAIN WINDOW WITH KEY SYSTEM
-- ==============================
local Window = Lumen:Window({
    Title = "LumenHub Complete Demo",
    Author = "Example User",
    Color = Color3.fromRGB(0, 150, 255), -- accent color
    Version = 1,
    Search = true, -- enable global search (Ctrl+Shift+F or Ctrl+O)
    Image = "84034353458936", -- toggle button icon
    Footer = "All features showcased",
    Discord = "https://discord.gg/example", -- optional Discord invite

    -- ==============================
    -- KEY SYSTEM (local validation)
    -- ==============================
    KeySystem = {
        Title = "LumenHub Demo",
        Note = "Enter the demo key to continue. (Valid keys: 1234, demo, secret)",
        Keys = {"1234", "demo", "secret"}, -- list of valid keys
        SaveKey = true,                   -- remember the key for next session
        FileName = GameConfigFolder .. "/demo_key.txt", -- where to save
        GetKeyLink = "https://example.com/get-key", -- optional link to get key
        Validate = function(key)          -- optional custom validation
            -- You can implement more complex logic here
            return key == "custom"        -- e.g., allow "custom" as well
        end,
        OnFail = function(key)
            print("Invalid key attempt:", key)
        end,
        -- Uncomment to use Junkie API instead (requires configuration):
        -- Junkie = {
        --     service = "your_service",
        --     identifier = "your_identifier",
        --     provider = "your_provider" -- optional
        -- }
    }
})

-- ==============================
-- 2. NOTIFICATION FUNCTION (for later use)
-- ==============================
local function showNotify(title, desc, color, delay)
    Lumen:MakeNotify({
        Title = title or "LumenHub",
        Description = desc or "Notification",
        Content = desc or "Notification",
        Color = color or Color3.fromRGB(255, 255, 255),
        Delay = delay or 4
    })
end

-- ==============================
-- 3. TABS AND SECTIONS
-- ==============================

-- ------------------------------
-- Tab 1: Main (Basic Controls)
-- ------------------------------
local mainTab = Window:AddTab({
    Name = "Main",
    Icon = "home"
})

local basicSection = mainTab:AddSection("Basic Controls", true)

-- Paragraph
basicSection:AddParagraph({
    Title = "Welcome to LumenHub!",
    Content = "This demo shows every UI component available.\nFeel free to interact and explore.",
    Icon = "smile"
})

-- Toggle (with save)
local demoToggle = basicSection:AddToggle({
    Title = "Enable Feature",
    Title2 = "Subtitle",
    Content = "This toggle saves its state automatically.",
    Default = true,
    Callback = function(value)
        print("Toggle changed to:", value)
        showNotify("Toggle", "New value: " .. tostring(value), Color3.fromRGB(0, 255, 100))
    end
})

-- Slider
local demoSilder = basicSection:AddSlider({
    Title = "Volume",
    Content = "Adjust volume level (0-100)",
    Min = 0,
    Max = 100,
    Default = 75,
    Increment = 1,
    Callback = function(value)
        print("Volume set to:", value)
    end
})

-- Input
local demoInput = basicSection:AddInput({
    Title = "Username",
    Content = "Enter your name (saved)",
    Placeholder = "Type here...",
    Default = "Player",
    Callback = function(text)
        print("Username:", text)
    end
})

-- Button with sub-button
basicSection:AddButton({
    Title = "Click Me",
    SubTitle = "Reset All",
    Callback = function()
        print("Button clicked!")
        demoInput:Set("Reset")
        demoToggle:Set(false)
        demoSilder:Set(50)
        showNotify("Action", "Reset performed!", Color3.fromRGB(255, 200, 0))
    end,
    SubCallback = function()
        print("Reset clicked!")
        demoToggle:Set(true)
        demoSilder:Set(75)
        demoInput:Set("Player")
        showNotify("Reset", "All values restored.", Color3.fromRGB(0, 200, 255))
    end
})

-- Panel (with input and two buttons)
local panel = basicSection:AddPanel({
    Title = "Quick Action",
    Content = "Type a message and press Send",
    Placeholder = "Your message...",
    Default = "Hello",
    ButtonText = "Send",
    ButtonCallback = function(text)
        print("Sent:", text)
        showNotify("Sent", text, Color3.fromRGB(100, 200, 255))
    end,
    SubButtonText = "Clear",
    SubButtonCallback = function()
        panel:Set("")
        showNotify("Cleared", "Input cleared.")
    end,
    Save = false -- don't save this panel's value
})

-- Keybind (single)
local keybindSingle = basicSection:AddKeybind({
    Title = "Single Keybind",
    Content = "Press to bind a key (e.g., F)",
    Default = Enum.KeyCode.F,
    Callback = function(key)
        print("Key pressed:", key.Name)
        showNotify("Keybind", "Pressed: " .. key.Name)
    end
})

-- Keybind2 (dual)
local keybindDual = basicSection:AddKeybind2({
    Title = "Dual Keybinds",
    Content = "Slot 1 and Slot 2",
    Slots = {
        { Title = "1", Key = Enum.KeyCode.Q },
        { Title = "2", Key = Enum.KeyCode.E }
    },
    Callback = function(slot, key)
        print("Slot", slot, "pressed:", key.Name)
        showNotify("Keybind "..slot, key.Name)
    end
})

-- Notification button (manual)
basicSection:AddButton({
    Title = "Show Notification",
    Callback = function()
        showNotify("Custom Notification", "This is a manual notification.", Color3.fromRGB(255, 100, 255))
    end
})

-- ------------------------------
-- Tab 2: Advanced Elements
-- ------------------------------
local advTab = Window:AddTab({
    Name = "Advanced",
    Icon = "settings"
})

local advSection = advTab:AddSection("Dropdowns & Color", true)

-- Dropdown (single)
local dropdownSingle = advSection:AddDropdown({
    Title = "Select Option",
    Content = "Choose one from the list",
    Options = {"Option A", "Option B", "Option C"},
    Default = "Option A",
    Callback = function(value)
        print("Dropdown selected:", value)
    end
})

-- Dropdown (multi)
local dropdownMulti = advSection:AddDropdown({
    Title = "Multi-Select",
    Content = "Pick multiple items",
    Multi = true,
    Options = {"Apple", "Banana", "Cherry", "Date"},
    Default = {"Apple", "Cherry"},
    Callback = function(values)
        print("Multi selection:", table.concat(values, ", "))
    end
})

-- Dynamic dropdown manipulation
advSection:AddButton({
    Title = "Add Option",
    SubTitle = "Clear All",
    Callback = function()
        dropdownSingle:AddOption("New Option")
        showNotify("Added", "New option added to dropdown.")
    end,
    SubCallback = function()
        dropdownSingle:Clear()
        dropdownSingle:AddOption("Option A")
        dropdownSingle:AddOption("Option B")
        dropdownSingle:AddOption("Option C")
        showNotify("Cleared", "Dropdown reset.")
    end
})

-- Color Picker (with default palette)
local colorPicker = advSection:AddColorPicker({
    Title = "Pick a Color",
    Content = "Choose an accent color",
    Default = Color3.fromRGB(255, 100, 100),
    Callback = function(color)
        print("Color selected:", color.R, color.G, color.B)
    end
})

-- Color Picker with custom palette
advSection:AddColorPicker({
    Title = "Custom Palette",
    Content = "Limited color set",
    Default = Color3.fromRGB(0, 255, 0),
    Colors = {
        Color3.fromRGB(255,0,0),
        Color3.fromRGB(0,255,0),
        Color3.fromRGB(0,0,255),
        Color3.fromRGB(255,255,0),
        Color3.fromRGB(255,0,255),
        Color3.fromRGB(0,255,255)
    },
    Callback = function(color) 
        print("Custom color picked:", color.R, color.G, color.B)
    end
})

-- ------------------------------
-- Tab 3: Layout & Containers
-- ------------------------------
local layoutTab = Window:AddTab({
    Name = "Layout",
    Icon = "layout"
})

local stackSection = layoutTab:AddSection("Stacks & Cards", true)

-- Horizontal Stack (HStack)
local hstack = stackSection:AddHStack({
    Padding = 10,
    Sizing = "Equal",    -- "Equal" or "Auto"
    EqualHeight = true,
    Height = 60
})
hstack:AddButton({
    Title = "Btn 1",
    Callback = function() print("Btn1") end
})
hstack:AddButton({
    Title = "Btn 2",
    Callback = function() print("Btn2") end
})
hstack:AddButton({
    Title = "Btn 3",
    Callback = function() print("Btn3") end
})

-- Vertical Stack (VStack)
local vstack = stackSection:AddVStack({
    Padding = 5,
    HorizontalAlignment = Enum.HorizontalAlignment.Center
})
vstack:AddButton({
    Title = "Top Button",
    Callback = function() print("Top") end
})
vstack:AddButton({
    Title = "Middle Button",
    Callback = function() print("Middle") end
})
vstack:AddButton({
    Title = "Bottom Button",
    Callback = function() print("Bottom") end
})

-- Card
stackSection:AddCard({
    Title = "Sample Card",
    Description = "This card has a logo and action buttons.",
    Logo = "heart",
    Buttons = {
        { Name = "Like", Callback = function() 
            print("Liked!")
            showNotify("Card", "You liked this card.", Color3.fromRGB(255, 50, 50))
        end },
        { Name = "Share", Callback = function() 
            print("Shared!")
            showNotify("Card", "Shared!", Color3.fromRGB(50, 255, 50))
        end }
    }
})

-- Card Widget (image from asset or web)
stackSection:AddCardWidget({
    Image = "rbxassetid://1234567890", -- replace with actual asset ID or web URL
    AspectRatio = 16/5,
    Link = "https://example.com",
    Callback = function() 
        print("Card Widget clicked")
        showNotify("Widget", "You clicked the card widget.")
    end
})

-- Divider
stackSection:AddDivider()

-- SubSection
local sub = stackSection:AddSubSection("Subsection Example")
sub:AddParagraph({
    Title = "Inside Subsection",
    Content = "This is a nested subsection with smaller heading."
})

-- Space (spacer)
stackSection:AddSpace({ Height = 10, Width = 0 }) -- vertical spacer

-- Banner (with version pill)
stackSection:AddBanner({
    Image = "rbxassetid://9876543210", -- replace with actual asset ID or web URL
    Version = "v2.0.1",
    AspectRatio = 16/5
})

-- ------------------------------
-- Tab 4: Config Management
-- ------------------------------
local configTab = Window:AddTab({
    Name = "Config",
    Icon = "save"
})

local configSection = configTab:AddSection("Configuration", true)
configSection:AddConfig({
    -- This adds the full config management UI:
    -- - Name input, Save/Load/Delete/Refresh buttons
    -- - Auto-Save toggle, Auto-Load toggle
    -- - Import/Export JSON
})

-- ------------------------------
-- Tab 5: Preset Manager
-- ------------------------------
local presetTab = Window:AddTab({
    Name = "Presets",
    Icon = "folder"
})

local presetSection = presetTab:AddSection("Preset Manager", true)
local presetManager = presetSection:AddPresetManager({
    Title = "Avatar Presets",
    Content = "Save/load preset values (e.g., character settings).",
    Placeholder = "Preset name...",
    Default = "Default",
    Callback = function(value)
        print("Preset value changed to:", value)
        showNotify("Preset", "Value: " .. value)
    end,
    -- Pre-populated presets
    Presets = {
        ["Warrior"] = "Strength build",
        ["Mage"] = "Intelligence build",
        ["Archer"] = "Dexterity build"
    }
})

presetSection:AddButton({
    Title = "Apply 'Warrior'",
    Callback = function()
        presetManager:Set("Warrior")
    end
})

presetSection:AddButton({
    Title = "Apply 'Mage'",
    Callback = function()
        presetManager:Set("Mage")
    end
})

-- ------------------------------
-- Tab 6: Target Selector
-- ------------------------------
local targetTab = Window:AddTab({
    Name = "Target",
    Icon = "crosshair"
})

local targetSection = targetTab:AddSection("Target Selector", true)
targetSection:AddParagraph({
    Title = "Target Selector",
    Content = "Click the button below to open a floating target panel.\nThe selected target is also reflected in a dropdown."
})

-- Target Selector (combines dropdown + floating panel)
local targetSelector = targetSection:AddTargetSelector({
    Title = "SELECT TARGET",
    DropdownTitle = "Target Type",
    Options = {"KILLER", "SURVIVOR", "ZOMBIE", "BOSS"},
    Default = "SURVIVOR",
    Callback = function(value)
        print("Target selected:", value)
        showNotify("Target", value)
    end
})

-- ------------------------------
-- Tab 7: Info Tab (built-in)
-- ------------------------------
local infoTab, infoItems = Window:InfoTab({
    Name = "Info",
    Icon = "info",
    SectionTitle = "About LumenHub",
    Banner = "rbxassetid://1234567890", -- replace with actual asset
    Version = "v2.0",
    DiscordLink = "https://discord.gg/example",
    DiscordText = "Join our community for support and updates!",
    Cards = {
        {
            Title = "Documentation",
            Description = "Full API reference and examples available online.",
            Logo = "book",
            Buttons = {
                { Name = "Open", Callback = function() 
                    print("Opening docs...")
                    showNotify("Docs", "Documentation link copied to clipboard.")
                end }
            }
        },
        {
            Title = "Credits",
            Description = "LumenHub is created by Lumen Development.",
            Logo = "star"
        }
    },
    CardsWidget = {
        {
            Image = "rbxassetid://9876543210",
            AspectRatio = 16/5,
            Link = "https://example.com",
            Callback = function() print("Widget clicked") end
        }
    }
})

-- ==============================
-- 4. PROGRAMMATIC CONTROL EXAMPLES
-- ==============================
-- You can access elements and modify them later:
print("Initial toggle value:", demoToggle.Value)
demoToggle:Set(false) -- triggers callback

print("Slider value:", demoSilder.Value)
demoSilder:Set(80)

-- Export/Import config (JSON)
local exported = Window:ExportConfig()
print("Exported config:", exported)

-- To import a config, use: Window:ImportConfig(json_string)

-- ==============================
-- 5. CLOSE / DESTROY UI (optional)
-- ==============================
-- If you need to destroy the UI programmatically:
-- Window:DestroyGui()

print("LumenHub Complete Demo loaded successfully!")
print("Press Ctrl+Shift+F or Ctrl+O to search.")
