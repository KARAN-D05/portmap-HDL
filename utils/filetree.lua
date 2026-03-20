-- Repository Filetree Generator - Lua

local IGNORE = {
    [".git"]         = true,
    [".github"]      = true,
    ["__pycache__"]  = true,
    ["node_modules"] = true,
    [".DS_Store"]    = true,
    ["Thumbs.db"]    = true,
}

local ICONS = {
    [".v"]    = "📄",  [".sv"]  = "📄",  [".vh"]  = "📄",  [".svh"] = "📄",
    [".py"]   = "🐍",  [".nim"] = "👑",  [".tcl"] = "🔧",  [".lua"] = "🌙",
    [".c"]    = "⚙️",  [".h"]   = "⚙️",  [".cpp"] = "⚙️",
    [".md"]   = "📝",  [".txt"] = "📝",
    [".json"] = "📋",  [".yml"] = "📋",  [".yaml"] = "📋",
    [".sh"]   = "🖥️",  [".bat"] = "🖥️",
    [".xdc"]  = "📌",  [".sdc"] = "📌",
    ["dir"]   = "📁",
}

local DEFAULT_DEPTH = 4

local function is_windows()
    return package.config:sub(1, 1) == "\\"
end

local function is_dir(path)
    if is_windows() then
        local ok = os.execute('cmd /c "if exist "' .. path .. '\\nul" exit 0 else exit 1" >nul 2>&1')
        return ok == true
    else
        local ok = os.execute('test -d "' .. path .. '"')
        return ok == true
    end
end

local function should_ignore(name)
    if IGNORE[name] then return true end
    if name:sub(1, 1) == "." then return true end
    return false
end

local function get_extension(filename)
    local ext = filename:match("(%.[^%.]+)$")
    return ext and ext:lower() or ""
end

local function get_icon(name, entry_is_dir)
    if entry_is_dir then return ICONS["dir"] or "📁" end
    local ext = get_extension(name)
    return ICONS[ext] or "📄"
end

local function list_dir(path)
    local all   = {}
    local dirs  = {}
    local files = {}

    local cmd
    if is_windows() then
        cmd = 'dir /b "' .. path .. '" 2>nul'
    else
        cmd = 'ls -1A "' .. path .. '" 2>/dev/null'
    end

    local fh = io.popen(cmd)
    if not fh then return dirs, files end

    for name in fh:lines() do
        if not should_ignore(name) then
            all[#all + 1] = name
        end
    end
    fh:close()

    local sep = is_windows() and "\\" or "/"
    for _, name in ipairs(all) do
        local full_path = path .. sep .. name
        if is_dir(full_path) then
            dirs[#dirs + 1] = name
        else
            files[#files + 1] = name
        end
    end

    local ci_sort = function(a, b) return a:lower() < b:lower() end
    table.sort(dirs,  ci_sort)
    table.sort(files, ci_sort)

    return dirs, files
end

local function walk(path, prefix, depth, max_depth)
    local lines = {}

    if depth > max_depth then
        lines[#lines + 1] = prefix .. "└── ..."
        return lines
    end

    local dirs, files = list_dir(path)

    local entries = {}
    for _, d in ipairs(dirs)  do entries[#entries + 1] = { name=d, is_dir=true  } end
    for _, f in ipairs(files) do entries[#entries + 1] = { name=f, is_dir=false } end

    local sep = is_windows() and "\\" or "/"

    for i, entry in ipairs(entries) do
        local is_last = (i == #entries)

        local branch = is_last and "└── " or "├── "

        local icon = get_icon(entry.name, entry.is_dir)
        lines[#lines + 1] = prefix .. branch .. icon .. " " .. entry.name

        if entry.is_dir then
            local child_prefix = prefix .. (is_last and "    " or "│   ")
            local child_path   = path .. sep .. entry.name

            local child_lines = walk(child_path, child_prefix, depth + 1, max_depth)
            for _, line in ipairs(child_lines) do
                lines[#lines + 1] = line
            end
        end
    end

    return lines
end

local function count_entries(lines)
    local dir_count  = 0
    local file_count = 0
    local ext_counts = { [".v"]=0, [".circ"]=0, [".md"]=0,
                         [".bat"]=0, [".sh"]=0, [".ps1"]=0,
                         [".py"]=0, [".c"]=0 }
    for _, line in ipairs(lines) do
        if line:find("📁") then
            dir_count = dir_count + 1
        elseif line:find("──") then
            file_count = file_count + 1
            local fname = line:match("[^%s]+$") or ""
            local ext = ("." .. (fname:match("[^%.]+$") or "")):lower()
            local raw_ext = fname:match("(%.[^%.]+)$")
            if raw_ext then
                raw_ext = raw_ext:lower()
                if ext_counts[raw_ext] ~= nil then
                    ext_counts[raw_ext] = ext_counts[raw_ext] + 1
                end
            end
        end
    end
    return dir_count, file_count, ext_counts
end

local function render(root_name, lines, output_md)
    print("")
    if output_md then print("```") end

    print("📁 " .. root_name .. "/")

    for _, line in ipairs(lines) do
        print(line)
    end

    local dir_count, file_count, ext_counts = count_entries(lines)
    print("")
    print(dir_count .. " directories, " .. file_count .. " files")

    local order = { ".v", ".circ", ".md", ".py", ".c", ".bat", ".sh", ".ps1" }
    local parts = {}
    for _, ext in ipairs(order) do
        if ext_counts[ext] and ext_counts[ext] > 0 then
            parts[#parts + 1] = ext .. ": " .. ext_counts[ext]
        end
    end
    if #parts > 0 then
        print("(" .. table.concat(parts, "  ") .. ")")
    end

    if output_md then
        print("```")
        print("")
        print("> *Generated by [filetree](https://github.com/KARAN-D05/portmap-HDL/tree/main/utils) — Lua tree generator*")
    end
    print("")
end

local root      = "."
local max_depth = DEFAULT_DEPTH
local output_md = false

local i = 1
while i <= #arg do
    local a = arg[i]
    if a == "--depth" or a == "-d" then
        i = i + 1
        max_depth = tonumber(arg[i]) or DEFAULT_DEPTH
    elseif a == "--md" or a == "-m" then
        output_md = true
    elseif a == "--help" or a == "-h" then
        print("filetree — repository file tree generator")
        print("Usage: lua filetree.lua [dir] [--depth N] [--md]")
        print("  dir       directory to scan   (default: current directory)")
        print("  --depth N max recursion depth (default: " .. DEFAULT_DEPTH .. ")")
        print("  --md      wrap output in markdown code fence")
        os.exit(0)
    else
        root = a
    end
    i = i + 1
end

root = root:match("^(.-)[\\/]?$") or root

local root_name
if root == "." then
    local fh = io.popen(is_windows() and "cd" or "pwd")
    if fh then
        local pwd = fh:read("*l")
        fh:close()
        root_name = pwd and (pwd:match("([^\\/]+)$") or ".") or "."
    else
        root_name = "."
    end
else
    root_name = root:match("([^\\/]+)$") or root
end

local tree_lines = walk(root, "", 1, max_depth)
render(root_name, tree_lines, output_md)
