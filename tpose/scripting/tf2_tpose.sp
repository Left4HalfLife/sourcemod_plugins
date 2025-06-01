#include <sourcemod>
#include <tf2_stocks>
#include <sdktools>

public Plugin myinfo = {
    name = "Civilian Pose Plugin",
    author = "dada513, Marximus",
    description = "Adds a command to add a civilian pose",
    version = "2.0",
    url = "https://github.com/dada513/tf2-civplugin"
}

public void OnPluginStart() {
    PrintToServer("Civilian Pose Plugin loaded!");
    RegConsoleCmd("sm_tpose", Command_TPoseSelf);
    RegAdminCmd("sm_settpose", Command_SetTPose, ADMFLAG_SLAY, "Set T-Pose on a target - Usage: sm_settpose \"target\"");
}

// sm_tpose: Only sets the player who sent the command
public Action Command_TPoseSelf(int client, int args) {
    if (client <= 0 || !IsClientInGame(client)) {
        return Plugin_Handled;
    }
    TF2_RemoveWeaponSlot(client, 3);
    TF2_RemoveWeaponSlot(client, 2);
    TF2_RemoveWeaponSlot(client, 1);
    TF2_RemoveWeaponSlot(client, 0);
    PrintToConsole(client, "You are now a civilian (T-pose)!");
    ShowActivity2(client, "[SM] ", "Set T-pose for yourself");
    return Plugin_Handled;
}

// sm_settpose <target>: Admin only, sets T-pose for target(s)
public Action Command_SetTPose(int client, int args) {
    if (!CheckCommandAccess(client, "sm_settpose", ADMFLAG_SLAY, true)) {
        ReplyToCommand(client, "[SM] You do not have access to this command.");
        return Plugin_Handled;
    }
    int targets[MAXPLAYERS];
    int targetCount = 0;
    bool tn_is_ml;
    char target_name[MAX_TARGET_LENGTH];
    if (args == 0) {
        ReplyToCommand(client, "[SM] Usage: sm_settpose <target>");
        return Plugin_Handled;
    } else {
        char arg1[64];
        GetCmdArg(1, arg1, sizeof(arg1));
        targetCount = ProcessTargetString(arg1, client, targets, sizeof(targets), COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml);
        if (targetCount <= 0) {
            ReplyToTargetError(client, targetCount);
            return Plugin_Handled;
        }
    }
    for (int i = 0; i < targetCount; i++) {
        int t = targets[i];
        TF2_RemoveWeaponSlot(t, 3);
        TF2_RemoveWeaponSlot(t, 2);
        TF2_RemoveWeaponSlot(t, 1);
        TF2_RemoveWeaponSlot(t, 0);
        PrintToConsole(t, "You are now a civilian (T-pose)!");
    }
    ShowActivity2(client, "[SM] ", "Set T-pose for %s", target_name);
    return Plugin_Handled;
}