local Dispatcher = require("dispatcher")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")
local lfs = require("libs/libkoreader-lfs")
local DataStorage = require("datastorage")
local InputDialog = require("ui/widget/inputdialog")
local ConfirmBox = require("ui/widget/confirmbox")
local Menu = require("ui/widget/menu")
local Screen = require("device").screen

local Unearthed = WidgetContainer:extend{
    name = "unearthed",
    is_doc_only = false,
    settings = {
        book_location = "",
        api_key = "",
        user_id = "",
        auto_sync_on_startup = false,
        auto_sync_local_on_startup = true,
        auto_sync_hourly = false,
        auto_sync_local_hourly = false,
        last_sync_date = nil,
        last_sync_local_date = nil,
        last_sync_hourly_time = nil,
        last_sync_local_hourly_time = nil,
        local_url = "",
        local_secret = "",
    },
}

function Unearthed:onDispatcherRegisterActions()
    Dispatcher:registerAction("unearthed_action", {category="none", event="Unearthed", title=_("Unearthed"), general=true,})
end

function Unearthed:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)
    self:loadSettings()
    self:migrateLocalUrl()
    self:checkAutoSync()
    self:checkAutoSyncLocal()
    self:setupHourlySync()
end

function Unearthed:loadSettings()
    local settings_file = DataStorage:getDataDir() .. "/unearthed_settings.lua"
    if lfs.attributes(settings_file, "mode") == "file" then
        local ok, stored_settings = pcall(dofile, settings_file)
        if ok and stored_settings then
            -- Merge stored settings with defaults
            for k, v in pairs(stored_settings) do
                self.settings[k] = v
            end
            
            if stored_settings.auto_sync ~= nil and self.settings.auto_sync_on_startup == nil then
                self.settings.auto_sync_on_startup = stored_settings.auto_sync
                self.settings.auto_sync = nil
            end
            if stored_settings.auto_sync_local ~= nil and self.settings.auto_sync_local_on_startup == nil then
                self.settings.auto_sync_local_on_startup = stored_settings.auto_sync_local
                self.settings.auto_sync_local = nil
            end
        end
    end
end

function Unearthed:saveSettings()
    local settings_file = DataStorage:getDataDir() .. "/unearthed_settings.lua"
    local file = io.open(settings_file, "w")
    if file then
        file:write("return ")
        file:write(require("dump")(self.settings))
        file:close()
    end
end

function Unearthed:migrateLocalUrl()
    local url = self.settings.local_url
    if url and url:sub(1, 7) == "http://" then
        self.settings.local_url = "https://" .. url:sub(8)
        self:saveSettings()
        UIManager:show(InfoMessage:new{
            text = _("Unearthed: Local URL updated to HTTPS automatically (http → https).\nNo other changes needed."),
            timeout = 4,
        })
    end
end

function Unearthed:showGeneralSettings()
    local menu_items = {
        {
            text = _("Book location"),
            callback = function()
                local input_dialog
                input_dialog = InputDialog:new{
                    title = _("Book Location"),
                    input = self.settings.book_location,
                    buttons = {
                        {
                            {
                                text = _("Cancel"),
                                callback = function()
                                    UIManager:close(input_dialog)
                                end,
                            },
                            {
                                text = _("Save"),
                                callback = function()
                                    self.settings.book_location = input_dialog:getInputText()
                                    self:saveSettings()
                                    UIManager:close(input_dialog)
                                    UIManager:show(InfoMessage:new{
                                        text = _("Book location saved"),
                                    })
                                end,
                            },
                        },
                    },
                }
                UIManager:show(input_dialog)
            end,
        },
        {
            text = _("Test book location"),
            callback = function()
                local location = self.settings.book_location
                if lfs.attributes(location, "mode") == "directory" then
                    UIManager:show(InfoMessage:new{
                        text = _("Book location is valid: ") .. location,
                    })
                else
                    UIManager:show(InfoMessage:new{
                        text = _("Book location is not valid: ") .. location,
                    })
                end
            end,
        },
    }
    
    local settings_menu = Menu:new{
        title = _("Unearthed Settings"),
        item_table = menu_items,
        width = Screen:getWidth() * 0.8,
        height = Screen:getHeight() * 0.8,
    }
    
    UIManager:show(settings_menu)
end


function Unearthed:showSettings()
    local menu_items = {
        {
            text = _("API Key"),
            callback = function()
                local input_dialog
                input_dialog = InputDialog:new{
                    title = _("API Key"),
                    input = self.settings.api_key,
                    buttons = {
                        {
                            {
                                text = _("Cancel"),
                                callback = function()
                                    UIManager:close(input_dialog)
                                end,
                            },
                            {
                                text = _("Save"),
                                callback = function()
                                    self.settings.api_key = input_dialog:getInputText()
                                    self:saveSettings()
                                    UIManager:close(input_dialog)
                                    UIManager:show(InfoMessage:new{
                                        text = _("API Key saved"),
                                    })
                                end,
                            },
                        },
                    },
                }
                UIManager:show(input_dialog)
            end,
        },
        {
            text = _("User ID"),
            callback = function()
                local input_dialog
                input_dialog = InputDialog:new{
                    title = _("User ID"),
                    input = self.settings.user_id,
                    is_password = true,  -- Mask the input as a password
                    buttons = {
                        {
                            {
                                text = _("Cancel"),
                                callback = function()
                                    UIManager:close(input_dialog)
                                end,
                            },
                            {
                                text = _("Save"),
                                callback = function()
                                    self.settings.user_id = input_dialog:getInputText()
                                    self:saveSettings()
                                    UIManager:close(input_dialog)
                                    UIManager:show(InfoMessage:new{
                                        text = _("User ID saved"),
                                    })
                                end,
                            },
                        },
                    },
                }
                UIManager:show(input_dialog)
            end,
        },
        {
            text = _("Auto sync on startup"),
            callback = function()
                local confirm_box = ConfirmBox:new{
                    text = _("Enable automatic daily sync with Unearthed Online on startup?\n\nWhen enabled, highlights will be sent to Unearthed Online once per day when the app is opened."),
                    ok_text = self.settings.auto_sync_on_startup and _("Disable") or _("Enable"),
                    ok_callback = function()
                        self.settings.auto_sync_on_startup = not self.settings.auto_sync_on_startup
                        self:saveSettings()
                        UIManager:show(InfoMessage:new{
                            text = self.settings.auto_sync_on_startup and 
                                   _("Auto sync on startup enabled") or 
                                   _("Auto sync on startup disabled"),
                        })
                    end,
                }
                UIManager:show(confirm_box)
            end,
        },
        {
            text = _("Auto sync hourly"),
            callback = function()
                local confirm_box = ConfirmBox:new{
                    text = _("Enable automatic hourly sync with Unearthed Online?\n\nWhen enabled, highlights will be sent to Unearthed Online once per hour while KOReader is running."),
                    ok_text = self.settings.auto_sync_hourly and _("Disable") or _("Enable"),
                    ok_callback = function()
                        self.settings.auto_sync_hourly = not self.settings.auto_sync_hourly
                        self:saveSettings()
                        if self.settings.auto_sync_hourly then
                            self:setupHourlySync()
                        end
                        UIManager:show(InfoMessage:new{
                            text = self.settings.auto_sync_hourly and 
                                   _("Auto sync hourly enabled") or 
                                   _("Auto sync hourly disabled"),
                        })
                    end,
                }
                UIManager:show(confirm_box)
            end,
        },
    }
    
    local settings_menu = Menu:new{
        title = _("Unearthed Settings"),
        item_table = menu_items,
        width = Screen:getWidth() * 0.8,
        height = Screen:getHeight() * 0.8,
    }
    
    UIManager:show(settings_menu)
end

function Unearthed:showLocalSettings()
    local menu_items = {
        {
            text = _("Local URL"),
            callback = function()
                local input_dialog
                input_dialog = InputDialog:new{
                    title = _("Local URL - sometimes your computer's ip address can change, so please re-check the Unearthed Local app"),
                    input = self.settings.local_url,
                    buttons = {
                        {
                            {
                                text = _("Cancel"),
                                callback = function()
                                    UIManager:close(input_dialog)
                                end,
                            },
                            {
                                text = _("Save"),
                                callback = function()
                                    self.settings.local_url = input_dialog:getInputText()
                                    self:saveSettings()
                                    UIManager:close(input_dialog)
                                    UIManager:show(InfoMessage:new{
                                        text = _("Local URL saved"),
                                    })
                                end,
                            },
                        },
                    },
                }
                UIManager:show(input_dialog)
            end,
        },
        {
            text = _("Secret"),
            callback = function()
                local input_dialog
                input_dialog = InputDialog:new{
                    title = _("Secret - this can be anything, but it must match the secret in the Unearthed Local app"),
                    input = self.settings.local_secret,
                    buttons = {
                        {
                            {
                                text = _("Cancel"),
                                callback = function()
                                    UIManager:close(input_dialog)
                                end,
                            },
                            {
                                text = _("Save"),
                                callback = function()
                                    self.settings.local_secret = input_dialog:getInputText()
                                    self:saveSettings()
                                    UIManager:close(input_dialog)
                                    UIManager:show(InfoMessage:new{
                                        text = _("Local Secret saved"),
                                    })
                                end,
                            },
                        },
                    },
                }
                UIManager:show(input_dialog)
            end,
        },
        {
            text = _("Auto sync on startup"),
            callback = function()
                local confirm_box = ConfirmBox:new{
                    text = _("Enable automatic daily sync with Unearthed Local on startup?\n\nWhen enabled, highlights will be sent to Unearthed Local once per day when the app is opened."),
                    ok_text = self.settings.auto_sync_local_on_startup and _("Disable") or _("Enable"),
                    ok_callback = function()
                        self.settings.auto_sync_local_on_startup = not self.settings.auto_sync_local_on_startup
                        self:saveSettings()
                        UIManager:show(InfoMessage:new{
                            text = self.settings.auto_sync_local_on_startup and 
                                   _("Auto sync on startup enabled") or 
                                   _("Auto sync on startup disabled"),
                        })
                    end,
                }
                UIManager:show(confirm_box)
            end,
        },
        {
            text = _("Auto sync hourly"),
            callback = function()
                local confirm_box = ConfirmBox:new{
                    text = _("Enable automatic hourly sync with Unearthed Local?\n\nWhen enabled, highlights will be sent to Unearthed Local once per hour while KOReader is running."),
                    ok_text = self.settings.auto_sync_local_hourly and _("Disable") or _("Enable"),
                    ok_callback = function()
                        self.settings.auto_sync_local_hourly = not self.settings.auto_sync_local_hourly
                        self:saveSettings()
                        if self.settings.auto_sync_local_hourly then
                            self:setupHourlySync()
                        end
                        UIManager:show(InfoMessage:new{
                            text = self.settings.auto_sync_local_hourly and 
                                   _("Auto sync hourly enabled") or 
                                   _("Auto sync hourly disabled"),
                        })
                    end,
                }
                UIManager:show(confirm_box)
            end,
        },
    }
    
    local settings_menu = Menu:new{
        title = _("Unearthed Settings"),
        item_table = menu_items,
        width = Screen:getWidth() * 0.8,
        height = Screen:getHeight() * 0.8,
    }
    
    UIManager:show(settings_menu)
end

function Unearthed:sortHighlightsByLocation(highlights)
    local function extractLocationNumber(location)
        if not location or location == "" then
            return 0
        end
        
        location = tostring(location)
        
        local number = location:match("(%d+)")
        local result = number and tonumber(number) or 0
                
        return result
    end
    
    table.sort(highlights, function(a, b)
        local loc_a = extractLocationNumber(a.location or "")
        local loc_b = extractLocationNumber(b.location or "")
        
        if loc_a == loc_b then
            return false
        end
        
        return loc_a < loc_b
    end)
    
    return highlights
end


function Unearthed:exportHighlights()
    local DocumentRegistry = require("document/documentregistry")
    local DataStorage = require("datastorage")
    local util = require("util")
    local json = require("json")
    
    -- Create unearthed directory if it doesn't exist
    local unearthed_dir = DataStorage:getDataDir() .. "/unearthed"
    if not lfs.attributes(unearthed_dir, "mode") then
        lfs.mkdir(unearthed_dir)
    else
        -- Remove all existing JSON files in the unearthed directory
        local success, iter, dir_obj = pcall(lfs.dir, unearthed_dir)
        if success then
            for file in iter, dir_obj do
                if file ~= "." and file ~= ".." and file:match("%.json$") then
                    local file_path = unearthed_dir .. "/" .. file
                    os.remove(file_path)
                end
            end
        end
        
        -- UIManager:show(InfoMessage:new{
        --     text = "Cleared existing exported highlights",
        -- })
    end
    
    -- Get all books with highlights
    local books_with_highlights = {}
    local book_dir = self.settings.book_location
    
    -- UIManager:show(InfoMessage:new{
    --     text = "Looking for highlights in: " .. book_dir,
    -- })
    
    if lfs.attributes(book_dir, "mode") == "directory" then
        -- Search recursively for highlight files
        self:findHighlightsRecursively(book_dir, books_with_highlights)
    else
        UIManager:show(InfoMessage:new{
            text = _("Book location is not valid: ") .. book_dir .. "\nPlease update in settings.",
        })
        return
    end
    
    if #books_with_highlights == 0 then
        UIManager:show(InfoMessage:new{
            text = _("No highlights found to export. Please make sure you have highlights saved."),
        })
        return
    end
    
    -- Export highlights for each book
    local exported_count = 0
    local failed_books = {}
    
    for _, book_info in ipairs(books_with_highlights) do
        local primary_file = book_info.path
        local fallback_file = book_info.fallback_path
        local book_name = book_info.book_name
        local has_custom = book_info.has_custom

        -- Load and merge metadata from custom and standard sources
        local ok, metadata = self:loadAndMergeMetadata(primary_file, fallback_file)
        if ok and metadata then
            -- Debug info about metadata source
            -- if has_custom then
            --     UIManager:show(InfoMessage:new{
            --         text = "Using custom metadata for: " .. book_name ..
            --                (fallback_file and " (with fallback)" or ""),
            --     })
            -- end
            
            -- Check if there are annotations
            if metadata.annotations and #metadata.annotations > 0 then
                -- Create JSON structure
                local highlights_json = {}
                
                -- Extract book details
                local book_title = metadata.doc_props and metadata.doc_props.title or book_name
                -- local book_title = book_name -- Use filename as title instead of metadata
                local author = metadata.doc_props and metadata.doc_props.authors or ""
                local subtitle = ""
                local asin = ""

                -- Format the book title to be more readable (remove file extension, replace underscores with spaces)
                book_title = book_title:gsub("%.%w+$", ""):gsub("_", " ")

                -- Try to extract subtitle from description if available
                if metadata.doc_props and metadata.doc_props.description then
                    -- Simple heuristic: if title is in the description, what follows might be the subtitle
                    local desc = metadata.doc_props.description
                    local title_pattern = book_title .. "[:%s]+(.-)[%s<]"
                    local subtitle_match = desc:match(title_pattern)
                    if subtitle_match then
                        subtitle = subtitle_match
                    end
                end
                
                -- Try to extract ASIN/ISBN from identifiers
                if metadata.doc_props and metadata.doc_props.identifiers then
                    asin = metadata.doc_props.identifiers
                end
                
                for _, annotation in ipairs(metadata.annotations) do
                    if annotation.text then
                        -- Use pageno for location if available
                        local location = ""
                        if annotation.pageno then
                            location = "Page " .. annotation.pageno
                        elseif annotation.page then
                            location = "Page " .. annotation.page
                        elseif annotation.chapter then
                            location = annotation.chapter
                        elseif annotation.pos0 then
                            location = annotation.pos0
                        end
                        
                        local color = annotation.color or "grey"

                        table.insert(highlights_json, {
                            title = book_title,
                            subtitle = subtitle,
                            author = author,
                            asin = asin,
                            content = annotation.text,
                            note = annotation.note or "",
                            color = color,
                            location = location
                        })
                    end
                end
                
                -- Write to export file
                local export_path = unearthed_dir .. "/" .. book_name .. "_highlights.json"
                local export_file = io.open(export_path, "w")
                if export_file then
                    export_file:write(json.encode(highlights_json))
                    export_file:close()
                    exported_count = exported_count + 1
                end
            else
                table.insert(failed_books, {
                    name = book_name,
                    reason = "No annotations found in metadata"
                })
            end
        else
            local error_msg = "Failed to load metadata"
            if has_custom and fallback_file then
                error_msg = error_msg .. " (tried custom and fallback files)"
            elseif has_custom then
                error_msg = error_msg .. " (custom metadata file)"
            else
                error_msg = error_msg .. " (standard metadata file)"
            end

            table.insert(failed_books, {
                name = book_name,
                reason = error_msg
            })
        end
    end
    
    -- Show detailed results
    local result_text = string.format(_("Exported highlights for %d books to the 'unearthed' folder."), exported_count)
    
    if #failed_books > 0 then
        result_text = result_text .. "\n\nFailed books:"
        for _, book in ipairs(failed_books) do
            result_text = result_text .. "\n- " .. book.name .. ": " .. book.reason
        end
    end
    
    -- UIManager:show(InfoMessage:new{
    --     text = result_text,
    -- })
end

function Unearthed:loadAndMergeMetadata(primary_file, fallback_file)
    -- Load primary metadata (custom_metadata.lua if it exists)
    local primary_metadata = {}
    local primary_ok, primary_content = pcall(dofile, primary_file)
    if primary_ok and primary_content then
        primary_metadata = primary_content
    end

    -- If no fallback file, return primary metadata
    if not fallback_file then
        return primary_ok, primary_metadata
    end

    -- Load fallback metadata (standard metadata file)
    local fallback_metadata = {}
    local fallback_ok, fallback_content = pcall(dofile, fallback_file)
    if fallback_ok and fallback_content then
        fallback_metadata = fallback_content
    end

    -- If primary failed but fallback succeeded, return fallback
    if not primary_ok and fallback_ok then
        return fallback_ok, fallback_metadata
    end

    -- If primary succeeded, merge with fallback for missing fields
    if primary_ok then
        local merged_metadata = primary_metadata

        -- Merge doc_props if missing or incomplete in primary
        if not merged_metadata.doc_props then
            merged_metadata.doc_props = fallback_metadata.doc_props or {}
        else
            -- Fill in missing doc_props fields from fallback
            if fallback_metadata.doc_props then
                for key, value in pairs(fallback_metadata.doc_props) do
                    if not merged_metadata.doc_props[key] or merged_metadata.doc_props[key] == "" then
                        merged_metadata.doc_props[key] = value
                    end
                end
            end
        end

        -- Check for custom_props and prioritize them over doc_props
        if merged_metadata.custom_props then
            for key, value in pairs(merged_metadata.custom_props) do
                if value and value ~= "" then
                    -- Override doc_props with custom_props
                    if not merged_metadata.doc_props then
                        merged_metadata.doc_props = {}
                    end
                    merged_metadata.doc_props[key] = value
                end
            end
        end

        -- Merge annotations if missing in primary (primary takes precedence)
        if not merged_metadata.annotations or #merged_metadata.annotations == 0 then
            merged_metadata.annotations = fallback_metadata.annotations or {}
        end

        -- Merge other top-level fields if missing in primary
        for key, value in pairs(fallback_metadata) do
            if key ~= "doc_props" and key ~= "annotations" and key ~= "custom_props" then
                if not merged_metadata[key] then
                    merged_metadata[key] = value
                end
            end
        end

        return true, merged_metadata
    end

    -- Both failed
    return false, nil
end

function Unearthed:findHighlightsRecursively(dir, result_table)
    -- Debug the current directory we're searching
    -- UIManager:show(InfoMessage:new{
    --     text = "Searching in: " .. dir,
    -- })

    local success, iter, dir_obj = pcall(lfs.dir, dir)
    if not success then
        UIManager:show(InfoMessage:new{
            text = "Error accessing directory: " .. dir,
        })
        return
    end

    for file in iter, dir_obj do
        if file ~= "." and file ~= ".." then
            local path = dir .. "/" .. file
            local attr = lfs.attributes(path)

            if attr and attr.mode == "directory" then
                -- Check if this is an .sdr directory
                if file:match("%.sdr$") then
                    -- First check for custom metadata file
                    local custom_metadata_file = path .. "/custom_metadata.lua"
                    local custom_exists = lfs.attributes(custom_metadata_file, "mode") == "file"

                    -- Try different standard metadata file patterns
                    local metadata_patterns = {
                        "/metadata.epub.lua",
                        "/metadata.pdf.lua",
                        "/metadata.mobi.lua",
                        "/metadata.azw.lua",
                        "/metadata.azw3.lua",
                        "/metadata.txt.lua",
                        "/metadata.rtf.lua",
                        "/metadata.doc.lua",
                        "/metadata.docx.lua",
                        "/metadata.fb2.lua",
                        "/metadata.djvu.lua",
                        "/metadata.cbz.lua",
                        "/metadata.lua"
                    }

                    local standard_metadata_file = nil
                    for _, pattern in ipairs(metadata_patterns) do
                        local metadata_file = path .. pattern
                        if lfs.attributes(metadata_file, "mode") == "file" then
                            standard_metadata_file = metadata_file
                            break
                        end
                    end

                    -- If we have either custom or standard metadata, add to results
                    if custom_exists or standard_metadata_file then
                        local primary_file = custom_exists and custom_metadata_file or standard_metadata_file

                        -- UIManager:show(InfoMessage:new{
                        --     text = "Found metadata file: " .. primary_file ..
                        --            (custom_exists and standard_metadata_file and
                        --             (" + fallback: " .. standard_metadata_file) or ""),
                        -- })

                        table.insert(result_table, {
                            path = primary_file,
                            fallback_path = (custom_exists and standard_metadata_file) and standard_metadata_file or nil,
                            book_name = file:gsub("%.sdr$", ""),
                            has_custom = custom_exists
                        })
                    else
                        UIManager:show(InfoMessage:new{
                            text = "No metadata file found in: " .. path,
                        })
                    end
                else
                    -- Recursively search subdirectories
                    self:findHighlightsRecursively(path, result_table)
                end
            end
        end
    end
end

function Unearthed:addToMainMenu(menu_items)
    menu_items.unearthed = {
        text = _("Unearthed"),
        sorting_hint = "tools", -- Use "tools" to place it in the main menu
        sub_item_table = {
            {
                text = _("Send Books"),
                callback = function()
                    if self.settings.book_location and self.settings.book_location ~= "" then
                        if self.settings.api_key and self.settings.api_key ~= "" and 
                            self.settings.user_id and self.settings.user_id ~= "" then
                            self:sendToAPI()
                        end

                        if self.settings.local_url and self.settings.local_url ~= "" and 
                            self.settings.local_secret and self.settings.local_secret ~= "" then
                            self:sendToAPILocal()
                        end
                    end
                end,
            },
            {
                text = _("General Settings"),
                callback = function()
                    self:showGeneralSettings()
                end,
            },
            {
                text = _("Online Settings"),
                callback = function()
                    self:showSettings()
                end,
            },
            {
                text = _("Local Settings"),
                callback = function()
                    self:showLocalSettings()
                end,
            },
        }
    }
end

function Unearthed:sendToAPI()

    if not self.settings.book_location or self.settings.book_location == "" then
        UIManager:show(InfoMessage:new{
            text = "Book Location must be configured in settings before sending data.",
        })
        return
    end
    if not self.settings.api_key or self.settings.api_key == "" then
        UIManager:show(InfoMessage:new{
            text = "API Key must be configured in settings before sending data.",
        })
        return
    end
    if not self.settings.user_id or self.settings.user_id == "" then
        UIManager:show(InfoMessage:new{
            text = "User ID must be configured in settings before sending data.",
        })
        return
    end

    local DataStorage = require("datastorage")
    local json = require("json")
    local http = require("socket.http")
    local ltn12 = require("ltn12")
    
    -- Wrap everything in pcall to prevent crashes
    local ok, err = pcall(function()
        -- First perform a highlight export
        self:exportHighlights()
        
        -- Check if API credentials are set
        if not self.settings.api_key or self.settings.api_key == "" or 
           not self.settings.user_id or self.settings.user_id == "" then
            UIManager:show(InfoMessage:new{
                text = "API Key and User ID must be configured in settings before sending data.",
            })
            return
        end
        
        -- Get all JSON files from the unearthed folder
        local unearthed_dir = DataStorage:getDataDir() .. "/unearthed"
        if not lfs.attributes(unearthed_dir, "mode") then
            UIManager:show(InfoMessage:new{
                text = "No unearthed folder found. Please export highlights first.",
            })
            return
        end
        
        local json_files = {}
        local success, iter, dir_obj = pcall(lfs.dir, unearthed_dir)
        if not success then
            UIManager:show(InfoMessage:new{
                text = "Error accessing unearthed directory: " .. unearthed_dir,
            })
            return
        end
        
        for file in iter, dir_obj do
            if file ~= "." and file ~= ".." and file:match("%.json$") then
                table.insert(json_files, unearthed_dir .. "/" .. file)
            end
        end
        
        if #json_files == 0 then
            UIManager:show(InfoMessage:new{
                text = "No JSON files found in the unearthed folder. Please export highlights first.",
            })
            return
        end
        
        -- Combine all JSON files and organize by book
        local books_data = {}
        for _, file_path in ipairs(json_files) do
            local file = io.open(file_path, "r")
            if file then
                local content = file:read("*all")
                file:close()
                
                local decode_ok, highlights = pcall(json.decode, content)
                if decode_ok and highlights and type(highlights) == "table" and #highlights > 0 then
                    -- Group highlights by book
                    for _, highlight in ipairs(highlights) do
                        if highlight and highlight.title then
                            local book_key = highlight.title .. "|" .. (highlight.author or "")
                            
                            if not books_data[book_key] then
                                books_data[book_key] = {
                                    book = {
                                        title = highlight.title,
                                        subtitle = highlight.subtitle or "",
                                        author = highlight.author or "",
                                        imageUrl = "",
                                        asin = highlight.asin or "",
                                        origin = "KOREADER"
                                    },
                                    highlights = {}
                                }
                            end
                            
                            table.insert(books_data[book_key].highlights, {
                                content = highlight.content or "",
                                note = highlight.note or "",
                                color = highlight.color or "grey",
                                location = highlight.location or ""
                            })
                        end
                    end
                end
            end
        end
        
        -- Convert to array for processing
        local books_array = {}
        for _, data in pairs(books_data) do
            table.insert(books_array, data)
        end
        
        if #books_array == 0 then
            UIManager:show(InfoMessage:new{
                text = "No valid highlights found in JSON files.",
            })
            return
        end
        
        -- First insert books to get source IDs
        local books_to_insert = {}
        for _, book_data in ipairs(books_array) do
            table.insert(books_to_insert, book_data.book)
        end
        
        -- Prepare the authorization header
        local auth_header = "Bearer " .. self.settings.api_key .. "~~~user_" .. self.settings.user_id
        local books_request_body = json.encode(books_to_insert)
        local books_response_body = {}

        local req_ok, req_result = pcall(function()
            local _, code = http.request{
                url = "https://unearthed.app/api/public/books-insert-koreader",
                method = "POST",
                headers = {
                    ["Content-Type"] = "application/json; charset=utf-8",
                    ["Authorization"] = auth_header,
                    ["Accept"] = "application/json",
                    ["Content-Length"] = #books_request_body
                },
                source = ltn12.source.string(books_request_body),
                sink = ltn12.sink.table(books_response_body),
                timeout = 60
            }
            return code
        end)
        
        if not req_ok then
            UIManager:show(InfoMessage:new{
                text = "Failed to send books to API: " .. tostring(req_result),
            })
            return
        end
                
        local status_code = req_result
        if status_code ~= 200 and status_code ~= 201 then
            local error_msg = table.concat(books_response_body)
            UIManager:show(InfoMessage:new{
                text = "Error sending books to API: " .. 
                      tostring(status_code) .. "\n" .. 
                      (error_msg ~= "" and error_msg or "No response body"),
            })
            return
        end
        
        -- Parse the response to get book IDs
        local parse_ok, response_data = pcall(json.decode, table.concat(books_response_body))
        if not parse_ok or not response_data then
            UIManager:show(InfoMessage:new{
                text = "Failed to parse API response for books.",
            })
            return
        end
        
        -- Update books with source IDs
        local updated_books = {}
        for _, book_data in ipairs(books_array) do
            local book_title = book_data.book.title
            local source_id = nil
            
            -- Check inserted records
            if response_data.insertedRecords and type(response_data.insertedRecords) == "table" then
                for _, record in ipairs(response_data.insertedRecords) do
                    if record.title == book_title then
                        source_id = record.id
                        break
                    end
                end
            end
            
            -- Check existing records if not found
            if not source_id and response_data.existingRecords and type(response_data.existingRecords) == "table" then
                for _, record in ipairs(response_data.existingRecords) do
                    if record.title == book_title then
                        source_id = record.id
                        break
                    end
                end
            end
            
            if source_id then
                table.insert(updated_books, {
                    book = book_data.book,
                    highlights = book_data.highlights,
                    source_id = source_id
                })
            end
        end
        
        if #updated_books == 0 then
            UIManager:show(InfoMessage:new{
                text = "No books were successfully registered with Unearthed.",
            })
            return
        end
        
        -- Now send highlights for each book with the correct source ID
        local success_count = 0
        local failed_count = 0
        local error_messages = {}
        
        for _, book_data in ipairs(updated_books) do
            local quotes_to_insert = {}
            
            local sorted_highlights = self:sortHighlightsByLocation(book_data.highlights)
            
            for i, highlight in ipairs(sorted_highlights) do
                if highlight.content and highlight.content ~= "" then
                    table.insert(quotes_to_insert, {
                        sourceName = book_data.book.title,
                        sourceId = book_data.source_id,
                        content = highlight.content,
                        note = highlight.note or "",
                        color = highlight.color or "grey",
                        location = highlight.location or "",
                        sequence = i
                    })
                end
            end
            
            if #quotes_to_insert > 0 then
                local quotes_response_body = {}
                local quotes_request_body = json.encode(quotes_to_insert)
                local quotes_ok, quotes_result = pcall(function()
                    local _, code = http.request{
                        url = "https://unearthed.app/api/public/quotes-insert-koreader",
                        method = "POST",
                        headers = {
                            ["Content-Type"] = "application/json; charset=utf-8",
                            ["Authorization"] = auth_header,
                            ["Accept"] = "application/json",
                            ["Content-Length"] = #quotes_request_body
                        },
                        source = ltn12.source.string(quotes_request_body),
                        sink = ltn12.sink.table(quotes_response_body),
                        timeout = 60
                    }
                    return code
                end)

                if quotes_ok and (quotes_result == 200 or quotes_result == 201) then
                    success_count = success_count + 1
                else
                    failed_count = failed_count + 1
                    table.insert(error_messages, string.format("Failed to send highlights for '%s': %s", 
                        book_data.book.title, 
                        quotes_result and tostring(quotes_result) or "Unknown error"))
                end
            end
        end
        
        
        -- Show final results
        local result_text
        if failed_count == 0 then
            result_text = string.format("Successfully synced %d books with Unearthed Online.", success_count)
        else
            result_text = string.format("Sync completed with issues:\n%d books succeeded\n%d books failed\n\nErrors:\n%s", 
                success_count, 
                failed_count,
                table.concat(error_messages, "\n"))
        end
        
        UIManager:show(InfoMessage:new{
            text = result_text,
        })
    end)
    
    -- If there was an error in the main function, show it
    if not ok then
        UIManager:show(InfoMessage:new{
            text = "Error in sendToAPI: " .. tostring(err),
        })
    end
end

function Unearthed:sendToAPILocal()

    if not self.settings.local_url or self.settings.local_url == "" then
        UIManager:show(InfoMessage:new{
            text = "Local URL must be configured in settings before sending data.",
        })
        return
    end

    if not self.settings.local_secret or self.settings.local_secret == "" then
        UIManager:show(InfoMessage:new{
            text = "Local Secret must be configured in settings before sending data.",
        })
        return
    end

    if not self.settings.book_location or self.settings.book_location == "" then
        UIManager:show(InfoMessage:new{
            text = "Book Location must be configured in settings before sending data.",
        })
        return
    end

    local DataStorage = require("datastorage")
    local json = require("json")
    local https = require("ssl.https")
    local ltn12 = require("ltn12")

    -- Wrap everything in pcall to prevent crashes
    local ok, err = pcall(function()
        -- First perform a highlight export
        self:exportHighlights()

        -- Get all JSON files from the unearthed folder
        local unearthed_dir = DataStorage:getDataDir() .. "/unearthed"
        if not lfs.attributes(unearthed_dir, "mode") then
            UIManager:show(InfoMessage:new{
                text = "No unearthed folder found. Please export highlights first.",
            })
            return
        end
        
        local json_files = {}
        local success, iter, dir_obj = pcall(lfs.dir, unearthed_dir)
        if not success then
            UIManager:show(InfoMessage:new{
                text = "Error accessing unearthed directory: " .. unearthed_dir,
            })
            return
        end
        
        for file in iter, dir_obj do
            if file ~= "." and file ~= ".." and file:match("%.json$") then
                table.insert(json_files, unearthed_dir .. "/" .. file)
            end
        end
        
        if #json_files == 0 then
            UIManager:show(InfoMessage:new{
                text = "No JSON files found in the unearthed folder. Please export highlights first.",
            })
            return
        end
        
        -- Combine all JSON files and organize by book
        local books_data = {}
        for _, file_path in ipairs(json_files) do
            local file = io.open(file_path, "r")
            if file then
                local content = file:read("*all")
                file:close()
                
                local decode_ok, highlights = pcall(json.decode, content)
                if decode_ok and highlights and type(highlights) == "table" and #highlights > 0 then
                    -- Group highlights by book
                    for _, highlight in ipairs(highlights) do
                        if highlight and highlight.title then
                            local book_key = highlight.title .. "|" .. (highlight.author or "")
                            
                            if not books_data[book_key] then
                                books_data[book_key] = {
                                    book = {
                                        title = highlight.title,
                                        subtitle = highlight.subtitle or "",
                                        author = highlight.author or "",
                                        imageUrl = "",
                                        asin = highlight.asin or "",
                                        origin = "KOREADER"
                                    },
                                    highlights = {}
                                }
                            end
                            
                            table.insert(books_data[book_key].highlights, {
                                content = highlight.content or "",
                                note = highlight.note or "",
                                color = highlight.color or "grey",
                                location = highlight.location or ""
                            })
                        end
                    end
                end
            end
        end
        
        -- Convert to array for processing
        local books_array = {}
        for _, data in pairs(books_data) do
            table.insert(books_array, data)
        end
        
        if #books_array == 0 then
            UIManager:show(InfoMessage:new{
                text = "No valid highlights found in JSON files.",
            })
            return
        end
        
        -- First insert books to get source IDs
        local books_to_insert = {}
        for _, book_data in ipairs(books_array) do
            table.insert(books_to_insert, book_data.book)
        end

        local auth_header = "Bearer " .. self.settings.local_secret
        local books_request_body = json.encode(books_to_insert)
        local books_response_body = {}

        local req_ok, req_result = pcall(function()
            local _, code = https.request{
                url = self.settings.local_url .. "/api/books-insert",
                method = "POST",
                headers = {
                    ["Content-Type"] = "application/json; charset=utf-8",
                    ["Authorization"] = auth_header,
                    ["Accept"] = "application/json",
                    ["Content-Length"] = #books_request_body
                },
                source = ltn12.source.string(books_request_body),
                sink = ltn12.sink.table(books_response_body),
                timeout = 60,
                verify = "none",
            }

            return code
        end)

        if not req_ok then
            UIManager:show(InfoMessage:new{
                text = "Failed to send books to local API. Check 'Unearthed Local' settings. " .. tostring(req_result),
            })
            return
        end
                
        local status_code = req_result
        if status_code ~= 200 and status_code ~= 201 then
            local error_msg = table.concat(books_response_body)
            UIManager:show(InfoMessage:new{
                text = "Error sending books to local API. Check 'Unearthed Local' settings. : " .. 
                      tostring(status_code) .. "\n" .. 
                      (error_msg ~= "" and error_msg or "No response body"),
            })
            return
        end
        -- Parse the response to get book IDs
        local parse_ok, response_data = pcall(json.decode, table.concat(books_response_body))
        if not parse_ok or not response_data then
            UIManager:show(InfoMessage:new{
                text = "Failed to parse API response for books. ",
            })
            return
        end

        -- Create a lookup table for source IDs by book title and author
        local source_id_lookup = {}
        if response_data.sources and type(response_data.sources) == "table" then
            for _, source in ipairs(response_data.sources) do
                if source.sourceId and source.title then
                    local key = (source.title .. "|" .. (source.author or "")):lower()
                    source_id_lookup[key] = source.sourceId
                end
            end
        end
        
        -- Update books with source IDs
        local updated_books = {}
        for _, book_data in ipairs(books_array) do
            local book_key = (book_data.book.title .. "|" .. book_data.book.author):lower()
            local source_id = source_id_lookup[book_key]
            
            if source_id then
                table.insert(updated_books, {
                    book = book_data.book,
                    highlights = book_data.highlights,
                    source_id = source_id
                })
            else
                -- If we couldn't find a source ID, log it but continue with other books
                table.insert(error_messages, "No source ID found for book: " .. book_data.book.title)
            end
        end
        

    
        if #updated_books == 0 then
            UIManager:show(InfoMessage:new{
                text = "No books were successfully registered with Unearthed.",
            })
            return
        end
        
        -- Now send highlights for each book with the correct source ID
        local success_count = 0
        local failed_count = 0
        local error_messages = {}
        
        for _, book_data in ipairs(updated_books) do
            local quotes_to_insert = {}

            local sorted_highlights = self:sortHighlightsByLocation(book_data.highlights)

            for i, highlight in ipairs(sorted_highlights) do
                if highlight.content and highlight.content ~= "" then
                    table.insert(quotes_to_insert, {
                        sourceName = book_data.book.title,
                        sourceId = book_data.source_id,
                        content = highlight.content,
                        note = highlight.note or "",
                        color = highlight.color or "grey",
                        location = highlight.location or "",
                        sequence = i
                    })
                end
            end
            
            if #quotes_to_insert > 0 then

                local quotes_request_body = json.encode(quotes_to_insert)

                
                if self.settings.local_url and self.settings.local_url ~= "" then
                    local quotes_response_body = {}
                    local quotes_ok, quotes_result = pcall(function()
                        local _, code, headers = https.request{
                            url = self.settings.local_url .. "/api/quotes-insert",
                            method = "POST",
                            headers = {
                                ["Content-Type"] = "application/json; charset=utf-8",
                                ["Authorization"] = auth_header,
                                ["Accept"] = "application/json",
                                ["Content-Length"] = #quotes_request_body
                            },
                            source = ltn12.source.string(quotes_request_body),
                            sink = ltn12.sink.table(quotes_response_body),
                            timeout = 60,
                            verify = "none",
                        }
                        
                        -- Try to parse the response body
                        local response_body = table.concat(quotes_response_body)
                        local response_data = {}
                        local parse_ok, parsed = pcall(json.decode, response_body)
                        if parse_ok and parsed then
                            response_data = parsed
                        end
                        
                        return code, response_data
                    end)
                    
                    if quotes_ok then
                        success_count = success_count + 1
                    else
                        failed_count = failed_count + 1
                        table.insert(error_messages, string.format("Failed to send highlights for '%s': %s", 
                            book_data.book.title, 
                            quotes_result and tostring(quotes_result) or "Unknown error"))
                    end
                end
            end
        end

        local result_text
        if failed_count == 0 then
            result_text = string.format("Successfully synced %d books with Unearthed Local.", success_count)
        else
            result_text = string.format("Local sync completed with issues:\n%d books succeeded\n%d books failed\n\nErrors:\n%s", 
                success_count, 
                failed_count,
                table.concat(error_messages, "\n"))
        end
        
        UIManager:show(InfoMessage:new{
            text = result_text,
        })
    end)
    
    if not ok then
        UIManager:show(InfoMessage:new{
            text = "Error in sendToAPILocal: " .. tostring(err),
        })
    end
end

function Unearthed:checkAutoSync()
    if not self.settings.auto_sync_on_startup then
        return
    end
    
    local current_date = os.date("%Y-%m-%d")
    local last_sync = self.settings.last_sync_date
    
    -- Only sync if we haven't synced today
    if not last_sync or last_sync ~= current_date then
        -- Schedule the sync with a slight delay to not slow down app startup
        UIManager:scheduleIn(5, function()
            -- Update last sync date before sending to prevent multiple syncs
            self.settings.last_sync_date = current_date
            self:saveSettings()
            
            self:sendToAPI()
        end)
    end
end

function Unearthed:checkAutoSyncLocal()
    if not self.settings.auto_sync_local_on_startup then
        return
    end
    
    local current_date = os.date("%Y-%m-%d")
    local last_sync = self.settings.last_sync_local_date
    
    -- Only sync if we haven't synced today
    if not last_sync or last_sync ~= current_date then
        -- Schedule the sync with a slight delay to not slow down app startup
        UIManager:scheduleIn(5, function()
            self.settings.last_sync_local_date = current_date
            self:saveSettings()
            
            self:sendToAPILocal()
        end)
    end
end

function Unearthed:setupHourlySync()
    if self.hourly_sync_timer then
        UIManager:unschedule(self.hourly_sync_timer)
        self.hourly_sync_timer = nil
    end
    
    if not self.settings.auto_sync_hourly and not self.settings.auto_sync_local_hourly then
        return
    end
    
    self.hourly_sync_timer = UIManager:scheduleIn(3600, function()
        self:performHourlySync()
    end)
end

function Unearthed:performHourlySync()
    local current_time = os.time()
    local current_hour = os.date("%Y-%m-%d-%H", current_time)
    
    if self.settings.auto_sync_hourly then
        local last_sync_hour = self.settings.last_sync_hourly_time
        if not last_sync_hour or last_sync_hour ~= current_hour then
            self.settings.last_sync_hourly_time = current_hour
            self:saveSettings()
            self:sendToAPI()
        end
    end
    
    if self.settings.auto_sync_local_hourly then
        local last_sync_hour = self.settings.last_sync_local_hourly_time
        if not last_sync_hour or last_sync_hour ~= current_hour then
            self.settings.last_sync_local_hourly_time = current_hour
            self:saveSettings()
            self:sendToAPILocal()
        end
    end
    
    self.hourly_sync_timer = UIManager:scheduleIn(3600, function()
        self:performHourlySync()
    end)
end

return Unearthed
