-- set required xmake version
set_xmakever("2.8.2")

-- includes (need xmake.lua file in the same directory)
local clib_path = os.getenv("CLIB_LOCATION")
local utils_path = os.getenv("UTIL_LOCATION")

if not clib_path then
    includes("lib")
else
    includes(clib_path)
end

if not utils_path then
    includes("extern/styyx-utils")
else
    includes(utils_path)
end

-- set up for project
set_project("plugin-template")
set_version("1.0.0")
set_license("MIT")

-- language and warnings
set_languages("c++23")
set_warnings("allextra")

-- xmake rules
add_rules("mode.debug", "mode.releasedbg")
set_defaultmode("releasedbg")
add_rules("plugin.compile_commands.autoupdate", {outputdir = ".vscode"}) --useful for clion or vscode
add_rules("plugin.vsxmake.autoupdate")

-- commonlib options
set_config("skyrim_ae", true)

-- set_config("rex_toml", true) -- enable if you want to use rex_toml for config
-- set_config("use-hook-utils", true) -- enable if you want to use StyyxUtils::HookUtils

-- add plugin target
target("plugin-template")
    add_deps("commonlibsse")
    add_deps("styyx-util")
    if has_config("skyrim_ae") then
        set_targetdir("build/AE/skse/plugins")
    else
        set_targetdir("build/SE/skse/plugins")
    end
    add_rules("commonlibsse.plugin", {
        name = "plugin-template",
        author = "styyx",
        description = "A plugin template for commonlibsse."
    })
    add_files("src/*.cpp")
    add_headerfiles("src/**.h")
    add_includedirs("src")
    set_pcxxheader("src/pch.h")

    after_build(function (target)

    local dist_root = path.join(os.projectdir(), "Distr")

    local runtime = "SE"
    if has_config("skyrim_ae") then
        runtime = "AE"
    end

    local plugins = path.join(dist_root, runtime, "SKSE", "Plugins")

    os.mkdir(plugins)

    -- plugin files
    os.trycp(target:targetfile(), plugins)
    os.trycp(target:symbolfile(), plugins)

    -- configs
    os.trycp("$(projectdir)/release/**.json", plugins)
    os.trycp("$(projectdir)/release/**.toml", plugins)

end)

-- builds both game versions. use with ``xmake shiprelease``
task("shiprelease")
    set_menu {
        usage = "xmake shiprelease",
        description = "Build release for SE and AE",
    }

    on_run(function ()
        print("Building AE version...")
        os.exec("xmake f -m releasedbg --skyrim_ae=true")
        os.exec("xmake")

        print("Building SE version...")
        os.exec("xmake f -m releasedbg --skyrim_ae=false")
        os.exec("xmake")

        print("Restoring default config (AE)...")
        os.exec("xmake f -m releasedbg --skyrim_ae=true")
    end)

