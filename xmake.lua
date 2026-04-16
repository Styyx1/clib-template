-- set required xmake version
set_xmakever("2.8.2")

option("skyrim_vr", function()
    set_default(false)
    set_description("Build for Skyrim VR using the CommonLibVR submodule")
end)

local is_vr = is_config("skyrim_vr", true)
local commonlib_default_path = is_vr and "lib/commonlibVR" or "lib/commonlibsse"
local commonlib_dep = is_vr and "commonlibsse-ng" or "commonlibsse"

-- includes (need xmake.lua file in the same directory)
includes(commonlib_default_path)
includes("extern/styyx-utils")

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
includes("xmake-rules.lua")

-- commonlib options
if is_vr then
    set_config("skyrim_se", false)
    set_config("skyrim_ae", false)
    set_config("skyrim_vr", true)
else
    set_config("skyrim_ae", true)
end

-- set_config("rex_toml", true) -- enable if you want to use rex_toml for config
-- set_config("use-hook-utils", true) -- enable if you want to use StyyxUtils::HookUtils

-- add plugin target
target("plugin-template")
    add_deps(commonlib_dep)
    add_deps("styyx-util")
    if is_vr then
        set_targetdir("build/VR/skse/plugins")
    elseif has_config("skyrim_ae") then
        set_targetdir("build/AE/skse/plugins")
    else
        set_targetdir("build/SE/skse/plugins")
    end
    add_rules("skse-template.plugin", {
        name = "plugin-template",
        author = "styyx",
        description = "A plugin template for commonlibsse."
    })
    if is_vr then
        add_defines("SKYRIM_SUPPORT_VR=1", "SKSE_TEMPLATE_SKYRIM_VR=1", { public = true })
    elseif has_config("skyrim_ae") then
        add_defines("SKSE_TEMPLATE_SKYRIM_AE=1", { public = true })
    else
        add_defines("SKSE_TEMPLATE_SKYRIM_SE=1", { public = true })
    end
    add_files("src/*.cpp")
    add_headerfiles("src/**.h")
    add_includedirs("src")
    set_pcxxheader("src/pch.h")

    after_build(function (target)

    local dist_root = path.join(os.projectdir(), "Distr")

    local runtime = "SE"
    if is_vr then
        runtime = "VR"
    elseif has_config("skyrim_ae") then
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

-- builds Skyrim VR. use with ``xmake shiprelease-vr``
task("shiprelease-vr")
    set_menu {
        usage = "xmake shiprelease-vr",
        description = "Build release for Skyrim VR",
    }

    on_run(function ()
        print("Building VR version...")
        os.exec("xmake f -m releasedbg --skyrim_vr=true")
        os.exec("xmake")
    end)

