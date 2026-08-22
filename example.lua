-- example.lua
-- Contoh pemakaian BolongUi berdasarkan API yang ada di library.
-- Ganti SOURCE_URL dengan URL raw file BolongUi kamu.
--
-- API utama library:
--   Chloex:Window(...)
--   Window:AddTab(...)
--   Tab:AddSection(...)
--   Section:AddButton / AddToggle / AddSlider / AddColorPicker
--   Section:AddInput / AddKeybind / AddDropdown
--   Section:AddParagraph / AddPanel / AddDivider
--   Section:AddTargetSelector / AddConfig / AddPresetManager
--   Section:AddBanner / AddCard
--
-- Referensi struktur API tersebut ada di source UI yang kamu kirim.

local SOURCE_URL = "https://raw.githubusercontent.com/starvane/LumenUI/refs/heads/main/library.lua"

local ok, Chloex = pcall(function()
    return loadstring(game:HttpGet(SOURCE_URL))()
end)

if not ok or not Chloex then
    warn("[Example] Gagal memuat BolongUi:", Chloex)
    return
end

local Window = Chloex:Window({
    Title = "BolongHub Example",
    Author = "Example",
    Footer = "Demo UI",
    Version = 1,
    Folder = "Example",
    Color = Color3.fromRGB(120, 90, 255),
    ["Tab Width"] = 120,
    Search = true,

    -- Aktifkan ini kalau ingin memakai key system:
    KeySystem = {
        Title = "BolongHub",
        Note = "Masukkan key untuk melanjutkan.",
        Keys = { "12345" },
        SaveKey = true,
    },
})

if not Window then
    warn("[Example] Window gagal dibuat.")
    return
end

-- =========================================================
-- MAIN TAB
-- =========================================================

local MainTab = Window:AddTab({
    Name = "Main",
    Icon = "home",
})

local MainSection = MainTab:AddSection("Basic Elements", true)

MainSection:AddParagraph({
    Title = "Welcome",
    Content = "Ini contoh penggunaan komponen dasar dari BolongUi.",
})

MainSection:AddButton({
    Title = "Click Me",
    SubTitle = "Notification",
    Callback = function()
        if Chloex.MakeNotify then
            Chloex:MakeNotify({
                Title = "BolongHub",
                Description = "Button",
                Content = "Button berhasil diklik.",
                Color = Color3.fromRGB(120, 90, 255),
                Delay = 3,
            })
        end
    end,
})

local enabled = MainSection:AddToggle({
    Title = "Enable Feature",
    Content = "Contoh toggle",
    Default = false,
    Callback = function(value)
        print("[Example] Enable Feature:", value)
    end,
})

local volume = MainSection:AddSlider({
    Title = "Volume",
    Content = "0 - 100",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 5,
    Live = true,
    Callback = function(value)
        print("[Example] Volume:", value)
    end,
})

local playerName = MainSection:AddInput({
    Title = "Player Name",
    Content = "Masukkan nama player",
    Placeholder = "Username",
    Default = "",
    Callback = function(text)
        print("[Example] Player Name:", text)
    end,
})

MainSection:AddDivider()

-- =========================================================
-- OPTIONS TAB
-- =========================================================

local OptionsTab = Window:AddTab({
    Name = "Options",
    Icon = "settings",
})

local OptionsSection = OptionsTab:AddSection("Selection", true)

local modeDropdown = OptionsSection:AddDropdown({
    Title = "Mode",
    Content = "Pilih mode",
    Options = {
        "Normal",
        "Hard",
        "Extreme",
    },
    Default = "Normal",
    Multi = false,
    Callback = function(value)
        print("[Example] Mode:", value)
    end,
})

OptionsSection:AddDropdown({
    Title = "Multi Select",
    Content = "Bisa memilih beberapa option",
    Options = {
        "ESP",
        "Aimbot",
        "Speed",
        "Jump",
    },
    Default = {},
    Multi = true,
    Callback = function(values)
        print("[Example] Multi Select:", values)
    end,
})

local colorPicker = OptionsSection:AddColorPicker({
    Title = "Accent Color",
    Content = "Contoh ColorPicker",
    Default = Color3.fromRGB(120, 90, 255),
    Callback = function(color)
        print("[Example] Color:", color)
    end,
})

OptionsSection:AddKeybind({
    Title = "Toggle Key",
    Content = "Tekan tombol untuk contoh callback",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        print("[Example] Keybind:", key)
    end,
})

-- =========================================================
-- TARGET SELECTOR
-- =========================================================

local TargetSection = OptionsTab:AddSection("Target", true)

local TargetSelector = TargetSection:AddTargetSelector({
    Title = "SELECT TARGET",
    DropdownTitle = "Target Type",
    ButtonTitle = "Open Target Panel",

    Options = {
        "KILLER",
        "SURVIVOR",
        "ZOMBIE",
    },

    Values = {
        "KILLER",
        "SURVIVOR",
        "ZOMBIE",
    },

    Default = "KILLER",

    Callback = function(value)
        print("[Example] Target:", value)
    end,
})

-- Contoh akses method TargetSelector:
-- TargetSelector:Set("SURVIVOR")
-- print(TargetSelector:Get())
-- TargetSelector:Show()
-- TargetSelector:Hide()
-- TargetSelector:Toggle()

-- =========================================================
-- CONFIG TAB
-- =========================================================

local ConfigTab = Window:AddTab({
    Name = "Config",
    Icon = "save",
})

local ConfigSection = ConfigTab:AddSection("Configuration", true)

ConfigSection:AddConfig({
    -- Config API menangani save/load/delete/autoload/import/export.
})

ConfigSection:AddParagraph({
    Title = "Config",
    Content = "Gunakan section di atas untuk mencoba Config Manager.",
})

-- =========================================================
-- INFO TAB
-- =========================================================

local InfoTab, InfoItems = Window:InfoTab({
    Name = "Info",
    Icon = "info",
    SectionTitle = "About",
    Version = "1.0.0",

    Cards = {
        {
            Title = "BolongUi",
            Description = "Contoh card dari API InfoTab.",
        },
    },
})

-- =========================================================
-- OPTIONAL RUNTIME EXAMPLES
-- =========================================================

task.spawn(function()
    task.wait(2)

    -- Set value dari komponen setelah dibuat.
    if enabled and enabled.Set then
        enabled:Set(true)
    end

    if volume and volume.Set then
        volume:Set(75)
    end

    if playerName and playerName.Set then
        playerName:Set("ExamplePlayer")
    end

    if modeDropdown and modeDropdown.Set then
        modeDropdown:Set("Hard")
    end
end)

print("[Example] BolongUi example loaded.")
