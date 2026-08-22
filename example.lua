--[[
    ULTIMATE EXAMPLE.LUA — LumenHub UI Library
    ------------------------------------------
    File ini mendemonstrasikan SEMUA komponen/fitur yang tersedia di library
    LumenHub: Window, Tabs, Section, semua Items (Toggle, Slider, Dropdown,
    ColorPicker, Input, Keybind, Keybind2, Button, Panel, Paragraph, Card,
    CardWidget/CardsWidget, Banner, Divider, SubSection, Space, HStack,
    VStack, PresetManager, Config Manager, TargetSelector), Notify,
    InfoTab, Export/Import Config, KeySystem, dan ToggleUI.

    Cara pakai: ganti LIB_URL di bawah dengan URL raw file library kamu,
    atau replace baris loadstring dengan cara load library kamu sendiri.
]]

----------------------------------------------------------------
-- 1) LOAD LIBRARY
----------------------------------------------------------------
local LIB_URL = "https://raw.githubusercontent.com/starvane/LumenUI/refs/heads/main/library.lua"

local Lumen
local okLib, errLib = pcall(function()
    Lumen = loadstring(game:HttpGet(LIB_URL))()
end)

if not okLib or not Lumen then
    warn("[Example] Gagal memuat LumenHub library:", errLib)
    return
end

----------------------------------------------------------------
-- 2) WINDOW (semua opsi GuiConfig)
----------------------------------------------------------------
local Window = Lumen:Window({
    Title = "LumenHub | Ultimate Example",
    Image = "84034353458936",           -- asset id icon toggle button
    Footer = "v1.0.0 • build demo",
    Author = "YourName",
    Color = Color3.fromRGB(120, 190, 255), -- accent color
    ["Tab Width"] = 130,
    Version = 1,                         -- dipakai untuk sistem config
    Search = true,                       -- aktifkan search bar (Ctrl+F / Ctrl+O)
    Folder = "UltimateExample",          -- subfolder config per-game
    Discord = "https://discord.gg/yourinvite",

    -- Contoh KeySystem (nonaktifkan / uncomment sesuai kebutuhan).
    -- Jika field ini diisi, window tidak akan terbuka sebelum key valid.
    --[[
    KeySystem = {
        Title = "LumenHub Key System",
        Note = "Masukkan key kamu di bawah ini untuk melanjutkan.",
        SaveKey = true,
        GetKeyLink = "https://linkvertise.com/yourlink",
        Keys = { "TESTKEY123", "FREEACCESS" },
        Color = Color3.fromRGB(120, 190, 255),
        OnFail = function(key)
            print("Key gagal:", key)
        end,

        -- Alternatif: pakai whitelist service Junkie
        -- Junkie = {
        --     service = "your-service-id",
        --     provider = "your-provider",
        --     identifier = game.PlaceId,
        -- },
    },
    ]]
})

if not Window then
    -- Window nil berarti KeySystem gagal / user tidak lolos verifikasi
    return
end

----------------------------------------------------------------
-- 3) INFO TAB (built-in helper: banner + discord card + custom cards)
----------------------------------------------------------------
Window:InfoTab({
    Name = "Home",
    Icon = "house",
    SectionTitle = "Welcome",
    Banner = "", -- isi assetid banner kalau ada, kosongkan untuk gradient default
    Version = "v1.0.0",
    BannerAspectRatio = 16 / 5,

    DiscordLink = "https://discord.gg/yourinvite",
    DiscordName = "Join Our Community",
    DiscordText = "Support, updates, dan pengumuman.",
    DiscordDesc = "Klik tombol untuk copy invite link.",

    Cards = {
        {
            Title = "Cara Pakai",
            Description = "Jelajahi setiap tab di sebelah kiri untuk melihat semua komponen UI yang tersedia di library ini.",
            Logo = "book-open",
            Buttons = {
                { Name = "Mengerti", Callback = function()
                    Lumen:MakeNotify({
                        Title = "LumenHub",
                        Content = "Selamat menjelajah!",
                        Color = Color3.fromRGB(120, 190, 255),
                    })
                end },
            },
        },
        {
            Title = "Changelog",
            Description = "• Rilis awal example ultimate\n• Menampilkan semua komponen UI",
            Logo = "scroll-text",
        },
    },

    CardsWidget = {
        -- { catwidget = "rbxassetid://0000000000", AspectRatio = 1000/300 },
    },
})

----------------------------------------------------------------
-- 4) TAB: COMPONENTS — semua basic Items
----------------------------------------------------------------
local ComponentsTab = Window:AddTab({ Name = "Components", Icon = "layout-grid" })

-- Section biasa (collapsible, default tertutup)
local SecToggle = ComponentsTab:AddSection("Toggles")
SecToggle:AddToggle({
    Title = "Basic Toggle",
    Content = "Toggle sederhana tanpa subtitle",
    Default = false,
    Callback = function(value)
        print("Basic Toggle:", value)
    end,
})
SecToggle:AddToggle({
    Title = "Toggle With Subtitle",
    Title2 = "Subtitle di bawah judul",
    Content = "Toggle ini punya baris Title2 tambahan dan deskripsi panjang yang otomatis wrap ketika melebihi lebar panel.",
    Default = true,
    Callback = function(value)
        print("Toggle w/ Subtitle:", value)
    end,
})
SecToggle:AddToggle({
    Title = "Toggle Tanpa Save",
    Content = "Save = false, tidak ikut tersimpan ke config",
    Default = false,
    Save = false,
    Callback = function(value) end,
})

local SecSlider = ComponentsTab:AddSection("Sliders")
SecSlider:AddSlider({
    Title = "Integer Slider",
    Content = "Increment 1, range 0-100",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Callback = function(value)
        print("Integer Slider:", value)
    end,
})
SecSlider:AddSlider({
    Title = "Decimal Slider (Live)",
    Content = "Live = true, callback dipanggil terus saat drag",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Increment = 0.01,
    Live = true,
    Callback = function(value)
        print("Decimal Slider:", value)
    end,
})
SecSlider:AddSlider({
    Title = "FOV Slider",
    Content = "Contoh range custom 20 - 120",
    Min = 20,
    Max = 120,
    Default = 90,
    Increment = 1,
    Callback = function(value) end,
})

local SecDropdown = ComponentsTab:AddSection("Dropdowns")
local SingleDrop = SecDropdown:AddDropdown({
    Title = "Single Select",
    Content = "Pilih salah satu opsi",
    Multi = false,
    Options = { "Opsi A", "Opsi B", "Opsi C", "Opsi D" },
    Default = "Opsi A",
    Callback = function(value)
        print("Single Dropdown:", value)
    end,
})
local MultiDrop = SecDropdown:AddDropdown({
    Title = "Multi Select",
    Content = "Bisa pilih lebih dari satu",
    Multi = true,
    Options = { "Player", "NPC", "Enemy", "Item", "Zombie" },
    Default = { "Player", "Enemy" },
    Callback = function(values)
        print("Multi Dropdown:", table.concat(values, ", "))
    end,
})
SecDropdown:AddButton({
    Title = "Refresh Opsi (SetValues)",
    Callback = function()
        SingleDrop:SetValues({ "Baru 1", "Baru 2", "Baru 3" }, "Baru 1")
        Lumen:MakeNotify({ Title = "Dropdown", Content = "Opsi diganti secara dinamis" })
    end,
})
SecDropdown:AddButton({
    Title = "Clear Multi Dropdown",
    Callback = function()
        MultiDrop:Clear()
    end,
})

local SecColor = ComponentsTab:AddSection("Color Pickers")
SecColor:AddColorPicker({
    Title = "Highlight Color",
    Content = "Klik kotak warna untuk membuka palette (SV box + Hue + Hex/RGB)",
    Default = Color3.fromRGB(255, 60, 60),
    Callback = function(color)
        print("ColorPicker:", color)
    end,
})
SecColor:AddColorPicker({
    Title = "ESP Color",
    Default = Color3.fromRGB(60, 255, 120),
    Callback = function(color) end,
})

local SecInput = ComponentsTab:AddSection("Inputs")
SecInput:AddInput({
    Title = "Webhook URL",
    Content = "Contoh input text panjang",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = "",
    Callback = function(text)
        print("Input Webhook:", text)
    end,
})
SecInput:AddInput({
    Title = "Player Name",
    Placeholder = "Masukkan username...",
    Callback = function(text) end,
})

local SecKeybind = ComponentsTab:AddSection("Keybinds")
SecKeybind:AddKeybind({
    Title = "Toggle UI Key",
    Content = "Klik tombol lalu tekan key baru",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        print("Keybind ditekan:", key)
    end,
})
SecKeybind:AddKeybind2({
    Title = "Combo Key (2 slot)",
    Content = "Mendukung 2 keybind sekaligus dalam satu baris",
    Slots = {
        { Title = "1", Key = Enum.KeyCode.E },
        { Title = "2", Key = Enum.KeyCode.Q },
    },
    Callback = function(slot, key)
        print("Keybind2 slot", slot, "ditekan:", key)
    end,
})

local SecButton = ComponentsTab:AddSection("Buttons")
SecButton:AddButton({
    Title = "Single Button",
    Callback = function()
        Lumen:MakeNotify({ Title = "Button", Content = "Single button diklik" })
    end,
})
SecButton:AddButton({
    Title = "Main Action",
    SubTitle = "Secondary Action",
    Callback = function()
        print("Main action")
    end,
    SubCallback = function()
        print("Sub action")
    end,
})

local SecPanel = ComponentsTab:AddSection("Panels")
SecPanel:AddPanel({
    Title = "Quick Panel",
    Content = "Panel dengan input + 1 tombol",
    Placeholder = "Ketik sesuatu...",
    Default = "",
    Button = "Kirim",
    Callback = function(text)
        print("Panel Kirim:", text)
    end,
})
SecPanel:AddPanel({
    Title = "Panel Dual Button",
    Content = "Panel dengan input + 2 tombol",
    Placeholder = "Value...",
    Button = "Simpan",
    SubButton = "Reset",
    Callback = function(text)
        print("Panel Simpan:", text)
    end,
    SubCallback = function(text)
        print("Panel Reset diklik")
    end,
})

local SecParagraph = ComponentsTab:AddSection("Paragraphs", false) -- AlwaysOpen = false (terbuka & tanpa arrow toggle)
local ParaFunc = SecParagraph:AddParagraph({
    Title = "Info Section",
    Content = "Ini adalah paragraph biasa untuk menampilkan teks panjang, cocok untuk changelog, disclaimer, atau instruksi.",
    Icon = "info",
})
SecParagraph:AddButton({
    Title = "Update Paragraph Text",
    Callback = function()
        ParaFunc:SetContent("Teks paragraph berhasil diupdate secara dinamis via :SetContent()!")
    end,
})

----------------------------------------------------------------
-- 5) TAB: LAYOUT — komponen layout & dekorasi
----------------------------------------------------------------
local LayoutTab = Window:AddTab({ Name = "Layout", Icon = "layers" })

local SecLayout = LayoutTab:AddSection("Layout Helpers", true) -- AlwaysOpen = true (tanpa header, selalu terbuka)
SecLayout:AddSubSection("Sub Section Header")
SecLayout:AddToggle({ Title = "Contoh Toggle di dalam AlwaysOpen Section", Default = false })
SecLayout:AddDivider()
SecLayout:AddSpace({ Height = 10 })

local HRow = SecLayout:AddHStack({ Padding = 8, EqualHeight = true })
HRow:AddButton({ Title = "Kiri", Callback = function() print("HStack kiri") end })
HRow:AddButton({ Title = "Tengah", Callback = function() print("HStack tengah") end })
HRow:AddButton({ Title = "Kanan", Callback = function() print("HStack kanan") end })

SecLayout:AddDivider()

local VCol = SecLayout:AddVStack({ Padding = 4 })
VCol:AddToggle({ Title = "VStack Toggle 1", Default = false })
VCol:AddToggle({ Title = "VStack Toggle 2", Default = true })
VCol:AddSlider({ Title = "VStack Slider", Min = 0, Max = 10, Default = 5 })

local SecCards = LayoutTab:AddSection("Cards & Widgets")
SecCards:AddCard({
    Title = "Card Tanpa Logo",
    Description = "Card sederhana tanpa logo dan tombol.",
})
SecCards:AddCard({
    Title = "Card Dengan Logo & Tombol",
    Description = "Card lengkap dengan logo icon dan dua tombol aksi.",
    Logo = "star",
    Buttons = {
        { Name = "Aksi 1", Callback = function() print("Card aksi 1") end },
        { Name = "Aksi 2", Callback = function() print("Card aksi 2") end },
    },
})
SecCards:AddBanner({
    -- Image = "rbxassetid://0000000000", -- kosongkan untuk gradient default
    Version = "v1.0.0",
    AspectRatio = 16 / 5,
})
-- SecCards:AddCardWidget({ catwidget = "https://example.com/image.png" })
-- SecCards:AddCardsWidget({ { catwidget = "..." }, { catwidget = "..." } })

----------------------------------------------------------------
-- 6) TAB: TARGET SELECTOR (floating panel terpisah)
----------------------------------------------------------------
local TargetTab = Window:AddTab({ Name = "Target", Icon = "crosshair" })
local SecTarget = TargetTab:AddSection("Target Selector", true)

-- Cara 1: manual, panggil Lumen:TargetSelector langsung (floating window sendiri)
local ManualSelector = Lumen:TargetSelector({
    Title = "SELECT TARGET",
    Options = { "PLAYER", "NPC", "ZOMBIE" },
    Default = "PLAYER",
    Accent = Color3.fromRGB(120, 190, 255),
    MaxColumns = 3,
    Callback = function(value)
        print("Target dipilih:", value)
    end,
})
SecTarget:AddButton({
    Title = "Buka/Tutup Target Panel",
    Callback = function()
        ManualSelector:Toggle()
    end,
})

-- Cara 2: helper AddTargetSelector (otomatis bikin dropdown + panel + tombol)
SecTarget:AddDivider()
SecTarget:AddTargetSelector({
    Title = "SELECT TARGET (Helper)",
    DropdownTitle = "Target Type",
    ButtonTitle = "Buka Panel Target",
    Options = { "KILLER", "SURVIVOR", "ZOMBIE" },
    Default = "SURVIVOR",
    Callback = function(value)
        print("Target (helper) dipilih:", value)
    end,
})

----------------------------------------------------------------
-- 7) TAB: PRESETS — Preset Manager
----------------------------------------------------------------
local PresetTab = Window:AddTab({ Name = "Presets", Icon = "save" })
local SecPreset = PresetTab:AddSection("Preset Manager", true)
SecPreset:AddPresetManager({
    Title = "Value Presets",
    Content = "Simpan & muat kumpulan value dengan nama custom",
    Placeholder = "Masukkan value di sini...",
    Default = "",
    Callback = function(value)
        print("Preset value aktif:", value)
    end,
})

----------------------------------------------------------------
-- 8) TAB: NOTIFICATIONS — demo Lumen:MakeNotify
----------------------------------------------------------------
local NotifyTab = Window:AddTab({ Name = "Notify", Icon = "bell" })
local SecNotify = NotifyTab:AddSection("Notifications", true)

SecNotify:AddButton({
    Title = "Notify Sukses",
    Callback = function()
        Lumen:MakeNotify({
            Title = "Berhasil",
            Content = "Aksi berhasil dijalankan.",
            Color = Color3.fromRGB(90, 220, 130),
            Delay = 4,
        })
    end,
})
SecNotify:AddButton({
    Title = "Notify Peringatan",
    Callback = function()
        Lumen:MakeNotify({
            Title = "Peringatan",
            Content = "Ada sesuatu yang perlu diperhatikan.",
            Color = Color3.fromRGB(255, 170, 0),
            Delay = 5,
        })
    end,
})
SecNotify:AddButton({
    Title = "Notify Error",
    Callback = function()
        Lumen:MakeNotify({
            Title = "Gagal",
            Content = "Terjadi kesalahan saat memproses permintaan.",
            Color = Color3.fromRGB(255, 90, 90),
            Delay = 6,
        })
    end,
})
SecNotify:AddButton({
    Title = "Notify Panjang (Auto Wrap)",
    Callback = function()
        Lumen:MakeNotify({
            Title = "Info Panjang",
            Content = "Ini adalah contoh notifikasi dengan teks yang cukup panjang untuk menunjukkan bagaimana tinggi kartu notifikasi menyesuaikan secara otomatis mengikuti panjang teks yang ditampilkan.",
            Delay = 7,
        })
    end,
})

----------------------------------------------------------------
-- 9) TAB: SETTINGS — Config manager bawaan + export/import manual
----------------------------------------------------------------
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings" })

-- Config manager bawaan (Save As / Load / Delete / Auto Save / Auto Load / Import-Export JSON)
local SecConfig = SettingsTab:AddSection("Config Manager", true)
SecConfig:AddConfig({})

-- Export / Import manual langsung dari Tabs (tanpa lewat item AddConfig)
local SecManual = SettingsTab:AddSection("Manual Export / Import")
SecManual:AddButton({
    Title = "Export Config ke Clipboard",
    Callback = function()
        Window:ExportConfig()
    end,
})
local ManualImportInput = SecManual:AddInput({
    Title = "Paste Config JSON",
    Placeholder = "{...}",
    Save = false,
})
SecManual:AddButton({
    Title = "Import Config",
    Callback = function()
        Window:ImportConfig(ManualImportInput:GetInput())
    end,
})

-- Contoh Toggle/Slider tambahan yang otomatis tersimpan lewat sistem config
local SecMisc = SettingsTab:AddSection("Misc Settings")
SecMisc:AddToggle({
    Title = "Auto Farm",
    Content = "Contoh fitur yang otomatis ikut tersimpan ke config",
    Default = false,
    Callback = function(value) end,
})
SecMisc:AddSlider({
    Title = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        local char = game:GetService("Players").LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = value
        end
    end,
})

----------------------------------------------------------------
-- 10) SEARCH FEATURE
-- Tekan Ctrl+F / Ctrl+O di dalam window untuk fokus ke search bar
-- (otomatis aktif karena GuiConfig.Search = true).
----------------------------------------------------------------

print("[Example] LumenHub Ultimate Example berhasil dimuat sepenuhnya.")
