#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <fun>
#include <hamsandwich>

new g_Coins[33]
new bool:g_BossUsed
new bool:g_RoundActive
new bool:g_BossModelReady
new bool:g_ItemReady[9]
new Float:g_NextAction[33]
new g_Boss
new g_KnifeItem[33]
new g_ForwardBossSelected
new g_ForwardBossReset
new g_ForwardReturn

new const g_KnifeModels[][] =
{
    "",
    "models/v_toilet_brush.mdl",
    "models/v_wooden_sword.mdl",
    "models/v_cleaver.mdl",
    "models/v_machete.mdl",
    "models/v_chainsaw.mdl"
}

new const Float:g_KnifeDamage[] = { 1.0, 1.0, 1.2, 1.5, 1.0, 2.0 }

public plugin_init()
{
    register_plugin("0816 Prisoner Menu", "0.2.0-boss", "Codex")
    register_clcmd("say /prisoner", "cmd_prisoner_menu")
    register_clcmd("say_team /prisoner", "cmd_prisoner_menu")
    register_clcmd("say /shop", "cmd_shop")
    register_clcmd("say /boss", "cmd_boss")
    register_clcmd("say_team /boss", "cmd_boss")
    register_event("HLTV", "event_new_round", "a", "1=0", "2=0")
    register_event("TeamInfo", "event_team", "a")
    register_logevent("event_round_end", 2, "1=Round_End")
    register_event("CurWeapon", "event_curweapon", "be", "1=1")
    
    RegisterHam(Ham_Spawn, "player", "fw_spawn_post", 1)
    RegisterHam(Ham_Killed, "player", "fw_killed_post", 1)
    RegisterHam(Ham_TakeDamage, "player", "fw_damage")
    set_task(60.0, "task_give_coins", 0, "", 0, "b")

    g_ForwardBossSelected = CreateMultiForward("jb_prisoner_boss_selected", ET_IGNORE, FP_CELL)
    g_ForwardBossReset = CreateMultiForward("jb_prisoner_boss_reset", ET_IGNORE, FP_CELL)
}

public plugin_natives()
{
    register_native("jb_get_prisoner_boss", "native_get_prisoner_boss")
}

public native_get_prisoner_boss(plugin, params)
{
    return g_Boss
}

public plugin_precache()
{
    for(new i = 1; i < sizeof(g_KnifeModels); i++)
    {
        g_ItemReady[i] = file_exists(g_KnifeModels[i]) != 0;
        if(g_ItemReady[i]) precache_model(g_KnifeModels[i]);
    }
    g_ItemReady[6] = true;
    g_ItemReady[7] = true;
    g_ItemReady[8] = file_exists("models/player/vip_skin/vip_skin.mdl") != 0;
    if(g_ItemReady[8]) precache_model("models/player/vip_skin/vip_skin.mdl");
    g_BossModelReady = file_exists("models/player/jail_boss/jail_boss.mdl") != 0;
    if(g_BossModelReady)
    {
        precache_model("models/player/jail_boss/jail_boss.mdl");
        if(file_exists("models/player/jail_boss/jail_bossT.mdl"))
            precache_model("models/player/jail_boss/jail_bossT.mdl");
    }
    else log_amx("[BOSS] Missing jail_boss.mdl; claims disabled.");
}

public event_new_round()
{
    reset_boss(g_Boss);
    g_BossUsed = false;
    g_RoundActive = true;
}

public event_round_end()
{
    g_RoundActive = false;
    reset_boss(g_Boss);
}

public event_team()
{
    new id = read_data(1), team[16];
    read_data(2, team, charsmax(team));
    if(id == g_Boss && !equal(team, "TERRORIST")) reset_boss(id);
}

public client_putinserver(id)
{
    g_Coins[id] = 0;
    g_KnifeItem[id] = 0;
    g_NextAction[id] = 0.0;
}

stock bool:action_ready(id)
{
    if(!is_user_alive(id) || cs_get_user_team(id) != CS_TEAM_T) return false;
    new Float:now = get_gametime();
    if(now < g_NextAction[id]) return false;
    g_NextAction[id] = now + 1.0;
    return true;
}

public fw_spawn_post(id)
{
    if(is_user_alive(id))
    {
        g_KnifeItem[id] = 0
        remove_task(id)
        cs_reset_user_model(id)
        if(id == g_Boss) reset_boss(id)
        if(cs_get_user_team(id) == CS_TEAM_T)
            g_Coins[id] += 1
    }
}

public fw_killed_post(victim, attacker, shouldgib)
{
    remove_task(victim)
    if(victim == g_Boss)
    {
        reset_boss(victim)
        client_print(0, print_chat, "[系統] 囚犯老大已陣亡，本回合不再補選。")
    }
}

public client_disconnected(id)
{
    remove_task(id)
    g_Coins[id] = 0
    g_NextAction[id] = 0.0
    if(id == g_Boss)
        reset_boss(id)

    g_KnifeItem[id] = 0
}

public cmd_prisoner_menu(id)
{
    if(!is_user_alive(id) || cs_get_user_team(id) != CS_TEAM_T)
    {
        client_print(id, print_chat, "[系統] 此選單限囚犯使用")
        return PLUGIN_HANDLED
    }

    new title[64]
    formatex(title, charsmax(title), "\y囚犯選單 \w| 監獄幣: %d", g_Coins[id])
    new menu = menu_create(title, "prisoner_menu_handle")
    menu_additem(menu, "當囚犯老大", "1")
    menu_additem(menu, "囚犯商店", "2")
    menu_display(id, menu)
    return PLUGIN_HANDLED
}

public prisoner_menu_handle(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new data[8], name[64], access, callback
    menu_item_getinfo(menu, item, access, data, charsmax(data), name, charsmax(name), callback)
    menu_destroy(menu)

    switch(str_to_num(data))
    {
        case 1: cmd_boss(id)
        case 2: cmd_shop(id)
    }
    return PLUGIN_HANDLED
}

public cmd_boss(id)
{
    if(!action_ready(id)) return PLUGIN_HANDLED;
    if(!g_RoundActive)
    {
        client_print(id, print_chat, "[系統] 請等下一回合再申請。");
        return PLUGIN_HANDLED;
    }
    if(g_BossUsed)
    {
        client_print(id, print_chat, "[系統] 本回合老大名額已使用，死亡或離線不再補選。");
        return PLUGIN_HANDLED;
    }
    if(!g_BossModelReady)
    {
        client_print(id, print_chat, "[系統] 缺少深藍囚服模型，請通知管理員。");
        return PLUGIN_HANDLED;
    }
    g_BossUsed = true;
    g_Boss = id;
    ExecuteForward(g_ForwardBossSelected, g_ForwardReturn, id);
    set_user_health(id, 150);
    cs_set_user_model(id, "jail_boss", true);
    set_pev(id, pev_body, 0);
    set_pev(id, pev_skin, 0);
    client_print(0, print_chat, "[系統] %n 成為本回合囚犯老大：150 HP、深藍囚服。", id);
    client_print(id, print_chat, "[系統] 使用原本麥克風按鍵說話，僅囚犯能收到語音。");
    return PLUGIN_HANDLED;
}

public cmd_shop(id)
{
    if(!is_user_alive(id) || cs_get_user_team(id) != CS_TEAM_T)
        return PLUGIN_HANDLED

    new title[64]
    formatex(title, charsmax(title), "\y囚犯商店 \w| 監獄幣: %d", g_Coins[id])
    new menu = menu_create(title, "shop_handle")
    menu_additem(menu, "馬桶刷 - 1 幣", "1")
    menu_additem(menu, "木劍 - 3 幣", "2")
    menu_additem(menu, "菜刀 - 5 幣", "3")
    menu_additem(menu, "開山刀 - 10 幣", "4")
    menu_additem(menu, "電鋸 - 20 幣", "5")
    menu_additem(menu, "隱身藥水 - 12 幣", "6")
    menu_additem(menu, "加速鞋 - 8 幣", "7")
    menu_additem(menu, "偽裝服 - 15 幣", "8")
    menu_display(id, menu)
    return PLUGIN_HANDLED
}

public shop_handle(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new data[8], name[64], access, callback
    menu_item_getinfo(menu, item, access, data, charsmax(data), name, charsmax(name), callback)
    menu_destroy(menu)

    if(!action_ready(id) || !g_RoundActive) return PLUGIN_HANDLED;
    new choice = str_to_num(data)
    if(choice < 1 || choice > 8) return PLUGIN_HANDLED;
    if(!g_ItemReady[choice])
    {
        client_print(id, print_chat, "[系統] 此商品模型尚未安裝。");
        return PLUGIN_HANDLED;
    }
    if(choice == 8 && id == g_Boss)
    {
        client_print(id, print_chat, "[系統] 老大期間不能使用偽裝服。");
        return PLUGIN_HANDLED;
    }
    new cost = shop_cost(choice)
    if(g_Coins[id] < cost)
    {
        client_print(id, print_chat, "[系統] 監獄幣不足")
        return PLUGIN_HANDLED
    }

    g_Coins[id] -= cost
    switch(choice)
    {
        case 1..5:
        {
            g_KnifeItem[id] = choice
            event_curweapon(id)
            client_print(id, print_chat, "[系統] 已購買 %s", name)
        }
        case 6:
        {
            set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 70)
            set_task(20.0, "task_clear_invis", id)
            client_print(id, print_chat, "[系統] 已使用隱身藥水")
        }
        case 7:
        {
            set_user_maxspeed(id, 360.0)
            set_task(20.0, "task_clear_speed", id)
            client_print(id, print_chat, "[系統] 已使用加速鞋")
        }
        case 8:
        {
            cs_set_user_model(id, "vip_skin")
            client_print(id, print_chat, "[系統] 已使用偽裝服")
        }
    }
    return PLUGIN_HANDLED
}

public event_curweapon(id)
{
    if(is_user_alive(id) && get_user_weapon(id) == CSW_KNIFE && g_KnifeItem[id] >= 1 && g_KnifeItem[id] <= 5)
        set_pev(id, pev_viewmodel2, g_KnifeModels[g_KnifeItem[id]])
}

public fw_damage(victim, inflictor, attacker, Float:damage, damagebits)
{
    if(attacker <= 0 || attacker > 32 || !is_user_alive(attacker) || inflictor != attacker)
        return HAM_IGNORED

    if(get_user_weapon(attacker) == CSW_KNIFE && g_KnifeItem[attacker] >= 1 && g_KnifeItem[attacker] <= 5)
    {
        SetHamParamFloat(4, damage * g_KnifeDamage[g_KnifeItem[attacker]])
        return HAM_HANDLED
    }
    return HAM_IGNORED
}

public task_give_coins()
{
    for(new id = 1; id <= get_maxplayers(); id++)
        if(is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_T)
            g_Coins[id] += 1
}

public task_clear_invis(id)
{
    if(is_user_connected(id))
        set_user_rendering(id)
}

public task_clear_speed(id)
{
    if(is_user_alive(id))
        set_user_maxspeed(id, 250.0)
}

stock shop_cost(choice)
{
    switch(choice)
    {
        case 1: return 1
        case 2: return 3
        case 3: return 5
        case 4: return 10
        case 5: return 20
        case 6: return 12
        case 7: return 8
        case 8: return 15
    }
    return 9999
}

stock reset_boss(id)
{
    if(g_Boss)
    {
        g_Boss = 0
        if(is_user_connected(id))
        {
            cs_reset_user_model(id)
            if(is_user_alive(id) && get_user_health(id) > 100) set_user_health(id, 100)
        }
        ExecuteForward(g_ForwardBossReset, g_ForwardReturn, id)
    }
}
