#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

#define PLUGIN_VERSION "1.0.0"

public Plugin:myinfo =
{
    name = "TF2 See Allies Outline",
    author = "YourName",
    description = "Allows admins to give players permanent spawn outline to see allies.",
    version = PLUGIN_VERSION,
    url = "None"
};

new bool:g_see_enabled[MAXPLAYERS+1];

// Track when a player last spawned
new Float:g_last_spawn_time[MAXPLAYERS+1];
const Float:OUTLINE_RESPAWN_DURATION = 10.0;

public OnPluginStart()
{
    RegAdminCmd("sm_see", Command_See, ADMFLAG_SLAY, "sm_see <target> <1/0> - Enable/disable permanent spawn outline for target(s)");
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
}

public Action:Command_See(int client, int args)
{
    if (!CheckCommandAccess(client, "sm_see", ADMFLAG_SLAY, true))
    {
        ReplyToCommand(client, "[SM] You do not have access to this command.");
        return Plugin_Handled;
    }
    if (args != 2)
    {
        ReplyToCommand(client, "[SM] Usage: sm_see <target> <1/0>");
        return Plugin_Handled;
    }
    char targetArg[64], enableArg[8];
    GetCmdArg(1, targetArg, sizeof(targetArg));
    GetCmdArg(2, enableArg, sizeof(enableArg));
    int targets[MAXPLAYERS], targetCount;
    bool tn_is_ml;
    char target_name[MAX_TARGET_LENGTH];
    targetCount = ProcessTargetString(targetArg, client, targets, sizeof(targets), COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml);
    if (targetCount <= 0)
    {
        ReplyToTargetError(client, targetCount);
        return Plugin_Handled;
    }
    int enable = StringToInt(enableArg);
    for (int i = 0; i < targetCount; i++)
    {
        int t = targets[i];
        g_see_enabled[t] = (enable != 0);
        if (!enable)
        {
            TF2_RemoveCondition(t, TFCond_SpawnOutline);
        }
    }
    ShowActivity2(client, "[SM] ", "%s permanent outline for %s", enable ? "Enabled" : "Disabled", target_name);
    return Plugin_Handled;
}

public void Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (client > 0 && client <= MaxClients)
    {
        g_last_spawn_time[client] = GetEngineTime();
    }
}

public OnGameFrame()
{
    float now = GetEngineTime();
    for (new i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i))
            continue;
        if (!g_see_enabled[i])
        {
            // If plugin is disabled for this player, make sure outline is removed
            TF2_RemoveCondition(i, TFCond_SpawnOutline);
            continue;
        }
        // Check if we're in the 10s after respawn (game handles outline)
        if (now - g_last_spawn_time[i] < OUTLINE_RESPAWN_DURATION)
            continue;
        // If not already outlined, reapply
        if (!TF2_IsPlayerInCondition(i, TFCond_SpawnOutline))
        {
            TF2_AddCondition(i, TFCond_SpawnOutline, -1.0);
        }
    }
}
