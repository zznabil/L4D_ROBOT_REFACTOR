#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

#define PLUGIN_NAME "[L4D2] Robot Guns"
#define PLUGIN_AUTHOR "YourName (Enhanced by Jules)"
#define PLUGIN_DESC "Use automatic robot guns to passively attack."
#define PLUGIN_VERSION "1.3"
#define PLUGIN_URL "https://yourwebsite.com"
#define PLUGIN_NAME_SHORT "Robot Guns"
#define PLUGIN_NAME_TECH "l4d2_robot"

#define MAX_ROBOTS_PER_PLAYER 4  // Maximum number of robots a player can have

// Smoother movement parameters
#define ROBOT_LERP_FACTOR 0.15 // Lower is smoother but slower to catch up
#define ROBOT_MAX_FOLLOW_SPEED 300.0 // Maximum speed when catching up
#define ROBOT_SNAP_DISTANCE 500.0 // Distance beyond which robot snaps to player

#define SOUNDCLIPEMPTY		   "weapons/ClipEmpty_Rifle.wav" 
#define SOUNDRELOAD			  "weapons/shotgun/gunother/shotgun_load_shell_2.wav" 
#define SOUNDREADY			 "weapons/shotgun/gunother/shotgun_pump_1.wav"

#define WEAPONCOUNT 18

#define SOUND0 "weapons/hunting_rifle/gunfire/hunting_rifle_fire_1.wav" 
#define SOUND1 "weapons/rifle/gunfire/rifle_fire_1.wav" 
#define SOUND2 "weapons/auto_shotgun/gunfire/auto_shotgun_fire_1.wav" 
#define SOUND3 "weapons/shotgun/gunfire/shotgun_fire_1.wav" 
#define SOUND4 "weapons/SMG/gunfire/smg_fire_1.wav" 
#define SOUND5 "weapons/pistol/gunfire/pistol_fire.wav" 
#define SOUND6 "weapons/magnum/gunfire/magnum_shoot.wav" 
#define SOUND7 "weapons/rifle_ak47/gunfire/rifle_fire_1.wav" 
#define SOUND8 "weapons/rifle_desert/gunfire/rifle_fire_1.wav" 
#define SOUND9 "weapons/sg552/gunfire/sg552-1.wav"
#define SOUND10 "weapons/machinegun_m60/gunfire/machinegun_fire_1.wav"
#define SOUND11 "weapons/shotgun_chrome/gunfire/shotgun_fire_1.wav"
#define SOUND12 "weapons/auto_shotgun_spas/gunfire/shotgun_fire_1.wav"
#define SOUND13 "weapons/sniper_military/gunfire/sniper_military_fire_1.wav"
#define SOUND14 "weapons/scout/gunfire/scout_fire-1.wav"
#define SOUND15 "weapons/awp/gunfire/awp1.wav"
#define SOUND16 "weapons/mp5navy/gunfire/mp5-1.wav"
#define SOUND17 "weapons/smg_silenced/gunfire/smg_fire_1.wav"

#define MODEL0 "weapon_hunting_rifle"
#define MODEL1 "weapon_rifle"
#define MODEL2 "weapon_autoshotgun"
#define MODEL3 "weapon_pumpshotgun"
#define MODEL4 "weapon_smg"
#define MODEL5 "weapon_pistol"
#define MODEL6 "weapon_pistol_magnum"
#define MODEL7 "weapon_rifle_ak47"
#define MODEL8 "weapon_rifle_desert"
#define MODEL9 "weapon_rifle_sg552"
#define MODEL10 "weapon_rifle_m60"
#define MODEL11 "weapon_shotgun_chrome"
#define MODEL12 "weapon_shotgun_spas"
#define MODEL13 "weapon_sniper_military"
#define MODEL14 "weapon_sniper_scout"
#define MODEL15 "weapon_sniper_awp"
#define MODEL16 "weapon_smg_mp5"
#define MODEL17 "weapon_smg_silenced"

static char SOUND[WEAPONCOUNT+3][70]=
{												SOUND0,	SOUND1,	SOUND2,	SOUND3,	SOUND4,	SOUND5,	SOUND6,	SOUND7,	SOUND8,	SOUND9,	SOUND10,SOUND11,SOUND12,SOUND13,SOUND14,SOUND15,SOUND16,SOUND17,SOUNDCLIPEMPTY,	SOUNDRELOAD,	SOUNDREADY};

static char MODEL[WEAPONCOUNT][32]=
{												MODEL0,	MODEL1,	MODEL2,	MODEL3,	MODEL4,	MODEL5,	MODEL6,	MODEL7,	MODEL8,	MODEL9,	MODEL10,MODEL11,MODEL12,MODEL13,MODEL14,MODEL15,MODEL16,MODEL17};

static char weaponbulletdamagestr[WEAPONCOUNT][10]={"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""};

static float fireinterval[WEAPONCOUNT] =		{0.25,	0.068,	0.30,	0.65,	0.060,	0.20,	0.33,	0.145,	0.14,	0.14,	0.068,	0.65,	0.30,	0.265,	0.9,	1.25,	0.065,	0.055	};

static float bulletaccuracy[WEAPONCOUNT] =		{1.15,	1.4,	3.5,	3.5,	1.6,	1.7,	1.7,	1.5,	1.6,	1.5,	1.5,	3.5,	3.5,	1.15,	1.00,	0.8,	1.6,	1.6		};

static float weaponbulletdamage[WEAPONCOUNT] =	{90.0,	30.0,	25.0,	30.0,	20.0,	30.0,	60.0,	70.0,	40.0,	40.0,	50.0,	30.0,	30.0,	90.0,	100.0,	150.0,	35.0,	35.0	};

static int weaponclipsize[WEAPONCOUNT] = {		60, 	60, 	60, 	60, 	60, 	60, 	60, 	60, 	60, 	60, 	60, 	60, 	60, 	60, 	60, 	60, 	60, 	60};

static int weaponbulletpershot[WEAPONCOUNT] =	{1,		1,		7,		7,		1,		1,		1,		1,		1,		1,		1,		7,		7,		1,		1,		1,		1,		1		};

static float weaponloadtime[WEAPONCOUNT] = {	0.1, 	0.1, 	0.1, 	0.1, 	0.1, 	0.1, 	0.1, 	0.1, 	0.1, 	0.1, 	0.1, 	0.1, 	0.1, 	0.1, 	0.1, 	0.1, 	0.1, 	0.1};

static int weaponloadcount[WEAPONCOUNT] =		{15,	50,		1,		1,		50,		30,		8,		40,		60,		50,		1,		1,		1,		30,		15,		20,		50,		50		};

static bool weaponloaddisrupt[WEAPONCOUNT] =	{false,	false,	true,	true,	false,	false,	false,	false,	false,	true,	true,	true,	false,	false,	false,	false,	false,	false	};

static bool weaponbulletpenetration[WEAPONCOUNT] = {true,	false,	false,	false,	false,	false,	true,	false,	false,	false,	true,	false,	false,	true,	true,	true,	false,	false	};


static int robots[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];
static int keybuffer[MAXPLAYERS+1];
static int weapontypes[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];
static int bullet[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];
static float firetime[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];
static bool reloading[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];
static float reloadtime[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];
static float scantime[MAXPLAYERS+1]; // Per-player scan timer
static float botenergy[MAXPLAYERS+1];

static float lastRobotPos[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER][3];
static float targetRobotPos[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER][3];
static float robotTargetAngles[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER][3];
static float g_robotCurrentAngles[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER][3];

static int g_robotTargets[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];

// Player-specific (not per robot) variables for main target scanning results
static int g_playerMainSIenemy[MAXPLAYERS+1];
static int g_playerMainCIenemy[MAXPLAYERS+1];

ConVar l4d_robot_limit;
ConVar l4d_robot_reactiontime;
ConVar l4d_robot_scanrange; 
ConVar l4d_robot_energy; 
ConVar l4d_robot_damagefactor; 
ConVar l4d_robot_messages;
ConVar l4d_robot_glow; 

#define BITFLAG_MESSAGE_INFO (1 << 0)
#define BITFLAG_MESSAGE_STEAL (1 << 1) // This flag seems unused in original logic

static float robot_reactiontime_cvar;
static float robot_scanrange_cvar;
static float robot_energy_cvar;
static float robot_damagefactor_cvar;
static int robot_messages_cvar;
static char robot_glow_cvar[12];

static int g_sprite;
 
static bool L4D2Version = false;
static int GameMode=0;

static bool gamestart = false;

// Persistent robot configuration storage
static bool g_bHasSavedConfig[MAXPLAYERS+1];
static int g_iSavedWeaponTypes[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];
static int g_iSavedRobotCount[MAXPLAYERS+1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() == Engine_Left4Dead2)
	{
		L4D2Version = true;
		return APLRes_Success;
	}
	else if (GetEngineVersion() == Engine_Left4Dead)
	{
		return APLRes_Success;
	}
	strcopy(error, err_max, "Plugin only supports Left 4 Dead and Left 4 Dead 2.");
	return APLRes_SilentFailure;
}

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESC,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public void OnPluginStart()
{
	static char temp_str[32];
	
	Format(temp_str, sizeof(temp_str), "%s_limit", PLUGIN_NAME_TECH);
 	l4d_robot_limit = CreateConVar(temp_str, "32", "Number of total Robots [0-32]", FCVAR_NONE);
	
	Format(temp_str, sizeof(temp_str), "%s_reactiontime", PLUGIN_NAME_TECH);
	l4d_robot_reactiontime = CreateConVar(temp_str, "0.1", "Robot reaction time for player-level scans [0.05, 5.0]", FCVAR_NONE);
	
	Format(temp_str, sizeof(temp_str), "%s_scanrange", PLUGIN_NAME_TECH);
	l4d_robot_scanrange = CreateConVar(temp_str, "2000.0", "Scan enemy range [100.0, 10000.0]", FCVAR_NONE);
 	
	Format(temp_str, sizeof(temp_str), "%s_energy", PLUGIN_NAME_TECH);
	l4d_robot_energy = CreateConVar(temp_str, "-1", "Time limit of a robot for a player (minutes) [-1 = infinite, 0.0 to 100.0]", FCVAR_NONE);
	
	Format(temp_str, sizeof(temp_str), "%s_damagefactor", PLUGIN_NAME_TECH);
	l4d_robot_damagefactor = CreateConVar(temp_str, "1.0", "Damage factor [0.1, 5.0]", FCVAR_NONE);
	
	Format(temp_str, sizeof(temp_str), "%s_messages", PLUGIN_NAME_TECH);
	l4d_robot_messages = CreateConVar(temp_str, "1", "Which messages to enable, as bitflags [1 = Info]", FCVAR_NONE);

	Format(temp_str, sizeof(temp_str), "%s_glow", PLUGIN_NAME_TECH);
	l4d_robot_glow = CreateConVar(temp_str, "0 127 127", "The glow color to use for robots [R G B]", FCVAR_NONE);

	AutoExecConfig(true, PLUGIN_NAME_TECH);
	HookConVarChange(l4d_robot_reactiontime, ConVarChange);
	HookConVarChange(l4d_robot_scanrange, ConVarChange); 
	HookConVarChange(l4d_robot_energy, ConVarChange);
	HookConVarChange(l4d_robot_damagefactor, ConVarChange);
	HookConVarChange(l4d_robot_messages, ConVarChange);
	HookConVarChange(l4d_robot_glow, ConVarChange);

	LoadConfig();

	static char GameName[16];
	GetConVarString(FindConVar("mp_gamemode"), GameName, sizeof(GameName));
	
	if (StrContains(GameName, "survival", false) != -1) GameMode = 3;
	else if (StrContains(GameName, "versus", false) != -1 || StrContains(GameName, "scavenge", false) != -1) GameMode = 2;
	else if (StrContains(GameName, "coop", false) != -1 || StrContains(GameName, "realism", false) != -1) GameMode = 1;
	else GameMode = 0;
 
	RegConsoleCmd("sm_robot", Cmd_AddRobot);
	RegConsoleCmd("sm_removerobot", Cmd_RemoveRobot);

	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_Post);
	HookEvent("finale_win", Event_RoundEnd, EventHookMode_Post);
	HookEvent("mission_lost", Event_RoundEnd, EventHookMode_Post);
	HookEvent("player_spawn", Event_PlayerSpawn_Full, EventHookMode_Post);
	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Post);

 	gamestart = false;
}

public void OnPluginEnd()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i)) {
			CleanupAllRobots(i, true);
		}
	}
}

void LoadConfig()
{
	robot_reactiontime_cvar = GetConVarFloat(l4d_robot_reactiontime);
	robot_scanrange_cvar = GetConVarFloat(l4d_robot_scanrange);
	robot_energy_cvar = GetConVarFloat(l4d_robot_energy) * 60.0;
	robot_damagefactor_cvar = GetConVarFloat(l4d_robot_damagefactor);
	robot_messages_cvar = GetConVarInt(l4d_robot_messages);
	GetConVarString(l4d_robot_glow, robot_glow_cvar, sizeof(robot_glow_cvar));

	static char str_damage[10];
	for (int i = 0; i < WEAPONCOUNT; i++)
	{
		Format(str_damage, sizeof(str_damage), "%d", RoundFloat(weaponbulletdamage[i] * robot_damagefactor_cvar));
		strcopy(weaponbulletdamagestr[i], sizeof(weaponbulletdamagestr[0]), str_damage);
	}
}
void ConVarChange(Handle convar, const char[] oldValue, const char[] newValue)
{
#pragma unused convar, oldValue, newValue
	LoadConfig();
}

public void OnMapStart()
{
	for(int i=0; i < WEAPONCOUNT; i++) {
		if (strlen(MODEL[i]) > 0) PrecacheModel(MODEL[i], true);
		if (strlen(SOUND[i]) > 0) PrecacheSound(SOUND[i], true);
	}
	
	PrecacheSound(SOUNDCLIPEMPTY, true);
	PrecacheSound(SOUNDRELOAD, true);
	PrecacheSound(SOUNDREADY, true);
	
	if (L4D2Version) {
		g_sprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	} else {
		g_sprite = PrecacheModel("materials/sprites/laser.vmt", true);
	}
	gamestart = false;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
#pragma unused event, name, dontBroadcast
    CreateTimer(0.5, Timer_DelayedRoundStartActions, _, TIMER_FLAG_NO_MAPCHANGE);
    gamestart = true;
}

public Action Timer_DelayedRoundStartActions(Handle timer)
{
#pragma unused timer
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && GetClientTeam(i) == 2)
        {
            CleanupAllRobots(i, false);
            LoadPlayerRobotConfig(i);
        } else if (IsValidClient(i)) {
            CleanupAllRobots(i, true);
        }
		botenergy[i] = 0.0;
		g_playerMainSIenemy[i] = 0;
		g_playerMainCIenemy[i] = 0;
		scantime[i] = 0.0;
		keybuffer[i] = 0;
    }
    return Plugin_Stop;
}


public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
#pragma unused event, name, dontBroadcast
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsValidClient(client))
        {
            SavePlayerRobotConfig(client);
        }
    }
	gamestart = false;
}

public void Event_PlayerSpawn_Full(Event event, const char[] name, bool dontBroadcast)
{
#pragma unused name, dontBroadcast
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (IsValidClient(client) && !IsFakeClient(client) && GetClientTeam(client) == 2)
    {
        DataPack dp = new DataPack();
        dp.WriteCell(client);
        CreateTimer(1.0, Timer_RestoreRobotsForClient, dp, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action Timer_RestoreRobotsForClient(Handle timer, DataPack dp)
{
#pragma unused timer
    dp.Reset();
    int client = dp.ReadCell();
    if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2) {
        LoadPlayerRobotConfig(client);
    }
    delete dp;
    return Plugin_Stop;
}

void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
#pragma unused name, dontBroadcast
	if (!gamestart) return;

	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(victim) || GetClientTeam(victim) != 2) return;

	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (IsValidClient(attacker))
	{	
		if (attacker != victim && GetClientTeam(attacker) == 3)
		{
			scantime[victim] = 0.0;
		}
	}
	else
	{
		scantime[victim] = 0.0;
	}
}

void DelRobotEntity(int ent)
{
	if (!RealValidEntity(ent)) return;
	AcceptEntityInput(ent, "Kill");
}

void ReleaseRobot(int controller, int robotIndex, bool delEntity = true)
{
    int r = robots[controller][robotIndex];
    if (RealValidEntity(r))
    {
        robots[controller][robotIndex] = 0;
        weapontypes[controller][robotIndex] = 0;
        g_robotTargets[controller][robotIndex] = 0;
        firetime[controller][robotIndex] = 0.0;
        reloading[controller][robotIndex] = false;
        reloadtime[controller][robotIndex] = 0.0;
        for(int k=0; k<3; k++) {
            lastRobotPos[controller][robotIndex][k] = 0.0;
            targetRobotPos[controller][robotIndex][k] = 0.0;
            g_robotCurrentAngles[controller][robotIndex][k] = 0.0;
            robotTargetAngles[controller][robotIndex][k] = 0.0;
        }
        
        if (delEntity) DelRobotEntity(r);
    }

    bool anyRobotStillExists = false;
    for (int client_idx = 1; client_idx <= MaxClients; client_idx++) {
        if (IsValidClient(client_idx)) {
            for (int robot_idx = 0; robot_idx < MAX_ROBOTS_PER_PLAYER; robot_idx++) {
                if (RealValidEntity(robots[client_idx][robot_idx])) {
                    anyRobotStillExists = true;
                    break;
                }
            }
        }
        if (anyRobotStillExists) break;
    }
    if (!anyRobotStillExists) gamestart = false;
}

public Action Cmd_AddRobot(int client, int args)
{  
	if (GameMode == 2 && !IsFakeClient(client)) {
		PrintToChat(client, "\x07[RobotGuns]\x01 Robots are disabled in Versus/Scaverge modes.");
		return Plugin_Handled;
	}
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Handled;

	int playerRobotCount = 0;
	for (int i = 0; i < MAX_ROBOTS_PER_PLAYER; i++)
	{
		if (RealValidEntity(robots[client][i])) playerRobotCount++;
	}

	if (playerRobotCount >= MAX_ROBOTS_PER_PLAYER)
	{
		PrintToChat(client, "\x07[RobotGuns]\x01 You already have maximum %d robots! Use !removerobot <1-%d>.", MAX_ROBOTS_PER_PLAYER, MAX_ROBOTS_PER_PLAYER);
		return Plugin_Handled;
	}
	
	int robotIndexToSpawn = -1;
	for (int i = 0; i < MAX_ROBOTS_PER_PLAYER; i++)
	{
		if (!RealValidEntity(robots[client][i]))
		{
			robotIndexToSpawn = i;
			break;
		}
	}

	if (robotIndexToSpawn == -1)
	{
		PrintToChat(client, "\x07[RobotGuns]\x01 Error finding available robot slot!");
		return Plugin_Handled;
	}

	int totalRobotsServer = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			for (int j = 0; j < MAX_ROBOTS_PER_PLAYER; j++)
			{
				if (RealValidEntity(robots[i][j])) totalRobotsServer++;
			}
		}
	}
	
	if (totalRobotsServer >= GetConVarInt(l4d_robot_limit))
	{
		PrintToChat(client, "\x07[RobotGuns]\x01 No more robots available! Server limit (%d) reached.", GetConVarInt(l4d_robot_limit));
		return Plugin_Handled;
	}

	if (args >= 1)
	{
		static char arg_wep[24];
		GetCmdArg(1, arg_wep, sizeof(arg_wep));
		if (StrContains(arg_wep, "hunting", false) != -1) weapontypes[client][robotIndexToSpawn]=0;
		else if (StrContains(arg_wep, "m16", false) != -1 || (StrContains(arg_wep, "rifle", false) != -1 && StrContains(arg_wep, "ak47", false) == -1 && StrContains(arg_wep, "desert", false) == -1 && StrContains(arg_wep, "sg552", false) == -1 && StrContains(arg_wep, "m60", false) == -1)) weapontypes[client][robotIndexToSpawn]=1;
		else if (StrContains(arg_wep, "auto", false) != -1 && StrContains(arg_wep, "shotgun", false) != -1) weapontypes[client][robotIndexToSpawn]=2;
		else if (StrContains(arg_wep, "pump", false) != -1) weapontypes[client][robotIndexToSpawn]=3;
		else if (StrContains(arg_wep, "smg", false) != -1 && StrContains(arg_wep, "silenced", false) == -1 && StrContains(arg_wep, "mp5", false) == -1) weapontypes[client][robotIndexToSpawn]=4;
		else if (StrContains(arg_wep, "pistol", false) != -1 && StrContains(arg_wep, "magnum", false) == -1) weapontypes[client][robotIndexToSpawn]=5;
		else if (StrContains(arg_wep, "magnum", false) != -1 && L4D2Version) weapontypes[client][robotIndexToSpawn]=6;
		else if (StrContains(arg_wep, "ak47", false) != -1 && L4D2Version) weapontypes[client][robotIndexToSpawn]=7;
		else if (StrContains(arg_wep, "desert", false) != -1 && L4D2Version) weapontypes[client][robotIndexToSpawn]=8;
		else if (StrContains(arg_wep, "sg552", false) != -1 && L4D2Version) weapontypes[client][robotIndexToSpawn]=9;
		else if (StrContains(arg_wep, "m60", false) != -1 && L4D2Version) weapontypes[client][robotIndexToSpawn]=10;
		else if (StrContains(arg_wep, "chrome", false) != -1 && L4D2Version) weapontypes[client][robotIndexToSpawn]=11;
		else if (StrContains(arg_wep, "spas", false) != -1 && L4D2Version) weapontypes[client][robotIndexToSpawn]=12;
		else if (StrContains(arg_wep, "military", false) != -1 && L4D2Version) weapontypes[client][robotIndexToSpawn]=13;
		else if (StrContains(arg_wep, "scout", false) != -1 && L4D2Version) weapontypes[client][robotIndexToSpawn]=14;
		else if (StrContains(arg_wep, "awp", false) != -1 && L4D2Version) weapontypes[client][robotIndexToSpawn]=15;
		else if (StrContains(arg_wep, "mp5", false) != -1 && L4D2Version) weapontypes[client][robotIndexToSpawn]=16;
		else if (StrContains(arg_wep, "silenced", false) != -1 && L4D2Version) weapontypes[client][robotIndexToSpawn]=17;
		else weapontypes[client][robotIndexToSpawn] = GetRandomInt(0, L4D2Version ? WEAPONCOUNT-1 : 5);
	}	
	else
	{
		weapontypes[client][robotIndexToSpawn] = GetRandomInt(0, L4D2Version ? WEAPONCOUNT-1 : 5);
	}

	AddRobot(client, robotIndexToSpawn, true);
	return Plugin_Handled;
} 

public Action Cmd_RemoveRobot(int client, int args)
{
	if (!IsValidClient(client)) return Plugin_Handled;

	if (args < 1)
	{
		PrintToChat(client, "\x07[RobotGuns]\x01 Usage: sm_removerobot <1-%d> or sm_removerobot all", MAX_ROBOTS_PER_PLAYER);
		return Plugin_Handled;
	}

	static char arg_idx[24];
	GetCmdArg(1, arg_idx, sizeof(arg_idx));

	if (StrEqual(arg_idx, "all", false)) {
		int removedCount = 0;
		for (int i = 0; i < MAX_ROBOTS_PER_PLAYER; i++) {
			if (RealValidEntity(robots[client][i])) {
				ReleaseRobot(client, i);
				removedCount++;
			}
		}
		if (removedCount > 0) PrintToChat(client, "\x07[RobotGuns]\x01 All %d robots removed.", removedCount);
		else PrintToChat(client, "\x07[RobotGuns]\x01 You have no active robots to remove.");
		return Plugin_Handled;
	}

	int robotIndexToRemove = StringToInt(arg_idx) - 1;

	if (robotIndexToRemove < 0 || robotIndexToRemove >= MAX_ROBOTS_PER_PLAYER)
	{
		PrintToChat(client, "\x07[RobotGuns]\x01 Invalid robot index! Use <1-%d> or 'all'.", MAX_ROBOTS_PER_PLAYER);
		return Plugin_Handled;
	}

	if (!RealValidEntity(robots[client][robotIndexToRemove]))
	{
		PrintToChat(client, "\x07[RobotGuns]\x01 You don't have a robot at index %d!", robotIndexToRemove + 1);
		return Plugin_Handled;
	}

	ReleaseRobot(client, robotIndexToRemove);
	PrintToChat(client, "\x07[RobotGuns]\x01 Robot at index %d removed.", robotIndexToRemove + 1);
	return Plugin_Handled;
}

void AddRobot(int client, int robotIndex, bool showmsg = false)
{
    if (RealValidEntity(robots[client][robotIndex]))
    {
        ReleaseRobot(client, robotIndex);
    }
    
	float playerEyePos[3], playerAngles[3], spawnPos[3];
	GetClientEyePosition(client, playerEyePos);
	GetClientEyeAngles(client, playerAngles);
	float vForward[3];
	GetAngleVectors(playerAngles, vForward, NULL_VECTOR, NULL_VECTOR);
	for(int k=0; k<3; k++) spawnPos[k] = playerEyePos[k] + vForward[k] * 60.0;
	spawnPos[2] += 10.0;

	int temp_ent = CreateEntityByName(MODEL[weapontypes[client][robotIndex]]);
	if (!RealValidEntity(temp_ent)) return;
	DispatchSpawn(temp_ent);
	static char modelPath[128];
	GetEntPropString(temp_ent, Prop_Data, "m_ModelName", modelPath, sizeof(modelPath));
	AcceptEntityInput(temp_ent, "Kill");
	
	int ent = CreateEntityByName("prop_dynamic_override");
	if (!RealValidEntity(ent)) return;

	DispatchKeyValue(ent, "solid", "6");
	DispatchKeyValue(ent, "model", modelPath);
	DispatchKeyValue(ent, "glowcolor", robot_glow_cvar);
	DispatchKeyValue(ent, "glowstate", "2");
	DispatchSpawn(ent);
	
	TeleportEntity(ent, spawnPos, playerAngles, NULL_VECTOR);
	
    SetEntProp(ent, Prop_Send, "m_CollisionGroup", 4);
	SetEntityMoveType(ent, MOVETYPE_NOCLIP);

	SetVariantString("idle");
	AcceptEntityInput(ent, "DisableMotion");
	SetVariantString("idle");
	AcceptEntityInput(ent, "SetDefaultAnimation");
	
	g_robotTargets[client][robotIndex] = 0;
	bullet[client][robotIndex] = weaponclipsize[weapontypes[client][robotIndex]];
	reloading[client][robotIndex] = false;
	reloadtime[client][robotIndex] = 0.0;
	firetime[client][robotIndex] = 0.0;
	robots[client][robotIndex] = ent;

	if (showmsg && (robot_messages_cvar & BITFLAG_MESSAGE_INFO))
	{
		PrintToChat(client, "\x07[RobotGuns]\x01 You spawned a \x03%s\x01 robot (%d/%d).", MODEL[weapontypes[client][robotIndex]], robotIndex+1, MAX_ROBOTS_PER_PLAYER);
		PrintToChatAll("\x04%N\x01 turned on their \x03%s\x01 robot.", client, MODEL[weapontypes[client][robotIndex]]);
	}

	for (int axis = 0; axis < 3; axis++)
	{
	    lastRobotPos[client][robotIndex][axis] = spawnPos[axis];
	    targetRobotPos[client][robotIndex][axis] = spawnPos[axis];
	    g_robotCurrentAngles[client][robotIndex][axis] = playerAngles[axis];
        robotTargetAngles[client][robotIndex][axis] = playerAngles[axis];
	}

	char targetname[64];
	Format(targetname, sizeof(targetname), "robot_%d_%d", client, robotIndex);
	DispatchKeyValue(ent, "targetname", targetname);
	SetEntPropString(ent, Prop_Data, "m_iName", targetname);
	
	gamestart = true;
}

static float s_lastFrameTime = 0.0;

void DoRobotLogic(int client, float currenttime, float duration)
{
	// Array to keep track of targets claimed by this client's robots in this frame
    int frameClaimedTargets[MAX_ROBOTS_PER_PLAYER];
    int numFrameClaimedTargets = 0;

    // Reset actual g_robotTargets for this client's robots before re-evaluation
    for (int i = 0; i < MAX_ROBOTS_PER_PLAYER; i++) {
        g_robotTargets[client][i] = 0;
    }

	float currentRobotPos[3];
	float playerEyePosition[3]; GetClientEyePosition(client, playerEyePosition);
	float playerViewAngles[3]; GetClientEyeAngles(client, playerViewAngles);
	float pForward[3], pRight[3], pUp[3]; GetAngleVectors(playerViewAngles, pForward, pRight, pUp);

	for (int robotIdx = 0; robotIdx < MAX_ROBOTS_PER_PLAYER; robotIdx++)
	{
		if (RealValidEntity(robots[client][robotIdx]))
		{
			if (!IsPlayerAlive(client))
			{
				ReleaseRobot(client, robotIdx, true);
				continue;
			}

			if (robot_energy_cvar > -0.5) {
				// botenergy is already accumulated per client in OnGameFrame
			}

			int currentButtons = GetClientButtons(client);
			GetEntPropVector(robots[client][robotIdx], Prop_Send, "m_vecOrigin", currentRobotPos);

			if ((currentButtons & IN_USE) && (currentButtons & IN_SPEED) && !(keybuffer[client] & IN_USE))
			{
				ReleaseRobot(client, robotIdx, true);
				if (robot_messages_cvar & BITFLAG_MESSAGE_INFO)
				{
					PrintToChatAll("\x04%N\x01 turned off their robot.", client);
				}
				continue;
			}

            bool targetAcquired = false;
            float enemyAimingPosition[3];
            Robot_UpdateAimingAndTargeting(client, robotIdx, currentRobotPos, targetAcquired, enemyAimingPosition, frameClaimedTargets, numFrameClaimedTargets);

            Robot_HandleCombat(client, robotIdx, currenttime, targetAcquired, enemyAimingPosition, currentRobotPos);

            float finalTeleportPos[3];
            Robot_UpdateMovement(client, robotIdx, duration, currentRobotPos, playerEyePosition, pForward, pRight, pUp, finalTeleportPos);

			TeleportEntity(robots[client][robotIdx], finalTeleportPos, g_robotCurrentAngles[client][robotIdx], NULL_VECTOR);
		}
	}
	keybuffer[client] = GetClientButtons(client);

    int activeRobotsForClient = 0;
    for(int k=0; k < MAX_ROBOTS_PER_PLAYER; ++k) {
        if(RealValidEntity(robots[client][k])) activeRobotsForClient++;
    }

	if (activeRobotsForClient == 0 && robot_energy_cvar > -0.5)
	{
		botenergy[client] -= duration * 0.5;
		if (botenergy[client] < 0.0) botenergy[client] = 0.0;
	}
}

void CalculateRobotFormationOffset(int client, int robotIndex, float outOffset[3])
{
#pragma unused client
    float formationOffsets[MAX_ROBOTS_PER_PLAYER][3] = {
        { 50.0,   0.0,  5.0},
        { 40.0,  50.0,  0.0},
        { 40.0, -50.0,  0.0},
        {-60.0,   0.0, 15.0}
    };

    if (robotIndex < 0 || robotIndex >= MAX_ROBOTS_PER_PLAYER) {
        outOffset[0] = 50.0; outOffset[1] = 0.0; outOffset[2] = 5.0;
        return;
    }
    for(int i=0; i<3; i++) outOffset[i] = formationOffsets[robotIndex][i];
}

void Robot_UpdateMovement(int client, int robotIndex, float duration, const float currentRobotPos[3], const float playerEyePos[3], float pForward[3], float pRight[3], float pUp[3], float finalTeleportPos[3])
{
    float localFormationOffset[3];
    CalculateRobotFormationOffset(client, robotIndex, localFormationOffset);

    targetRobotPos[client][robotIndex][0] = playerEyePos[0] + pForward[0]*localFormationOffset[0] + pRight[0]*localFormationOffset[1] + pUp[0]*localFormationOffset[2];
    targetRobotPos[client][robotIndex][1] = playerEyePos[1] + pForward[1]*localFormationOffset[0] + pRight[1]*localFormationOffset[1] + pUp[1]*localFormationOffset[2];
    targetRobotPos[client][robotIndex][2] = playerEyePos[2] + pForward[2]*localFormationOffset[0] + pRight[2]*localFormationOffset[1] + pUp[2]*localFormationOffset[2];

    float distToPlayerActual = GetVectorDistance(currentRobotPos, playerEyePos);

    if (distToPlayerActual > ROBOT_SNAP_DISTANCE)
    {
        for(int k=0; k<3; k++) finalTeleportPos[k] = targetRobotPos[client][robotIndex][k];
        for(int k=0; k<3; k++) lastRobotPos[client][robotIndex][k] = finalTeleportPos[k];
    }
    else
    {
        for (int axis = 0; axis < 3; axis++)
        {
            finalTeleportPos[axis] = Lerp(currentRobotPos[axis], targetRobotPos[client][robotIndex][axis], ROBOT_LERP_FACTOR);
            float delta = finalTeleportPos[axis] - currentRobotPos[axis];
            float maxDelta = ROBOT_MAX_FOLLOW_SPEED * duration;
            if (delta > maxDelta) finalTeleportPos[axis] = currentRobotPos[axis] + maxDelta;
            else if (delta < -maxDelta) finalTeleportPos[axis] = currentRobotPos[axis] - maxDelta;
            lastRobotPos[client][robotIndex][axis] = finalTeleportPos[axis];
        }
    }
}

// Helper function for Robot Targeting and Aiming
// enemyAimPos is an out parameter
// frameClaimedTargets and numFrameClaimedTargets are used for unique target selection within a player's robots for this frame
void Robot_UpdateAimingAndTargeting(int client, int robotIndex, const float currentRobotPos[3], bool &targetAcquired, float enemyAimPos[3], int frameClaimedTargets[MAX_ROBOTS_PER_PLAYER], int &numFrameClaimedTargets)
{
    targetAcquired = false;
    // g_robotTargets[client][robotIndex] is set here if a target is found.
    // It's reset at the start of DoRobotLogic's loop for the client's robots.

    float tempEnemyPos[3];
    float tempInfectedEyePos[3], tempInfectedOrigin[3];
    int potentialTarget = 0;

    // Priority 1: Special Infected
    potentialTarget = g_playerMainSIenemy[client];
    if (IsValidClient(potentialTarget) && IsPlayerAlive(potentialTarget))
    {
        bool alreadyClaimedBySibling = false;
        for (int k = 0; k < numFrameClaimedTargets; k++) {
            if (frameClaimedTargets[k] == potentialTarget) {
                alreadyClaimedBySibling = true;
                break;
            }
        }

        if (!alreadyClaimedBySibling) {
            GetClientEyePosition(potentialTarget, tempInfectedEyePos);
            GetClientAbsOrigin(potentialTarget, tempInfectedOrigin);
            tempEnemyPos[0] = tempInfectedOrigin[0] * 0.4 + tempInfectedEyePos[0] * 0.6;
            tempEnemyPos[1] = tempInfectedOrigin[1] * 0.4 + tempInfectedEyePos[1] * 0.6;
            tempEnemyPos[2] = tempInfectedOrigin[2] * 0.4 + tempInfectedEyePos[2] * 0.6;

            if (HasLineOfSight(currentRobotPos, tempEnemyPos))
            {
                g_robotTargets[client][robotIndex] = potentialTarget;
                targetAcquired = true;
                for(int k=0; k<3; k++) enemyAimPos[k] = tempEnemyPos[k];
                if (numFrameClaimedTargets < MAX_ROBOTS_PER_PLAYER) {
                    frameClaimedTargets[numFrameClaimedTargets++] = potentialTarget;
                }
            }
        }
    }

    // Priority 2: Common Infected
    if (!targetAcquired) {
        potentialTarget = g_playerMainCIenemy[client];
        if (RealValidEntity(potentialTarget) && GetEntProp(potentialTarget, Prop_Data, "m_iHealth") > 0) {
            bool alreadyClaimedBySibling = false;
            for (int k = 0; k < numFrameClaimedTargets; k++) {
                if (frameClaimedTargets[k] == potentialTarget) {
                    alreadyClaimedBySibling = true;
                    break;
                }
            }

            if (!alreadyClaimedBySibling) {
                GetEntPropVector(potentialTarget, Prop_Send, "m_vecOrigin", tempEnemyPos);
                tempEnemyPos[2] += 20.0;
                if (HasLineOfSight(currentRobotPos, tempEnemyPos))
                {
                    g_robotTargets[client][robotIndex] = potentialTarget;
                    targetAcquired = true;
                    for(int k=0; k<3; k++) enemyAimPos[k] = tempEnemyPos[k];
                     if (numFrameClaimedTargets < MAX_ROBOTS_PER_PLAYER) {
                        frameClaimedTargets[numFrameClaimedTargets++] = potentialTarget;
                    }
                }
            }
        } else if (RealValidEntity(potentialTarget)) {
             g_playerMainCIenemy[client] = 0;
        }
    }

    // Fallback: If this robot still has no unique target, allow targeting an already claimed (by sibling) high-priority target.
    if (!targetAcquired) {
        potentialTarget = g_playerMainSIenemy[client];
        if (IsValidClient(potentialTarget) && IsPlayerAlive(potentialTarget)) {
            GetClientEyePosition(potentialTarget, tempInfectedEyePos);
            GetClientAbsOrigin(potentialTarget, tempInfectedOrigin);
            tempEnemyPos[0] = tempInfectedOrigin[0] * 0.4 + tempInfectedEyePos[0] * 0.6;
            tempEnemyPos[1] = tempInfectedOrigin[1] * 0.4 + tempInfectedEyePos[1] * 0.6;
            tempEnemyPos[2] = tempInfectedOrigin[2] * 0.4 + tempInfectedEyePos[2] * 0.6;
            if (HasLineOfSight(currentRobotPos, tempEnemyPos)) {
                g_robotTargets[client][robotIndex] = potentialTarget;
                targetAcquired = true;
                for(int k=0; k<3; k++) enemyAimPos[k] = tempEnemyPos[k];
            }
        }
        if (!targetAcquired) {
            potentialTarget = g_playerMainCIenemy[client];
            if (RealValidEntity(potentialTarget) && GetEntProp(potentialTarget, Prop_Data, "m_iHealth") > 0) {
                 GetEntPropVector(potentialTarget, Prop_Send, "m_vecOrigin", tempEnemyPos);
                 tempEnemyPos[2] += 20.0;
                 if (HasLineOfSight(currentRobotPos, tempEnemyPos)) {
                    g_robotTargets[client][robotIndex] = potentialTarget;
                    targetAcquired = true;
                    for(int k=0; k<3; k++) enemyAimPos[k] = tempEnemyPos[k];
                 }
            }
        }
    }

    if (targetAcquired)
    {
        SubtractVectors(enemyAimPos, currentRobotPos, robotTargetAngles[client][robotIndex]);
        GetVectorAngles(robotTargetAngles[client][robotIndex], robotTargetAngles[client][robotIndex]);
    }
    else
    {
        float playerEyeAngles[3];
        GetClientEyeAngles(client, playerEyeAngles);
        robotTargetAngles[client][robotIndex][0] = playerEyeAngles[0];
        robotTargetAngles[client][robotIndex][1] = playerEyeAngles[1];
        robotTargetAngles[client][robotIndex][2] = 0.0;
    }

    g_robotCurrentAngles[client][robotIndex][0] = LerpAngle(g_robotCurrentAngles[client][robotIndex][0], robotTargetAngles[client][robotIndex][0], 0.25);
    g_robotCurrentAngles[client][robotIndex][1] = LerpAngle(g_robotCurrentAngles[client][robotIndex][1], robotTargetAngles[client][robotIndex][1], 0.25);
    g_robotCurrentAngles[client][robotIndex][2] = 0.0;
}

void Robot_HandleCombat(int client, int robotIndex, float currenttime, bool targetAcquired, const float enemyTargetPos[3], const float currentRobotPos[3])
{
    if (reloading[client][robotIndex])
    {
        if (currenttime - reloadtime[client][robotIndex] > weaponloadtime[weapontypes[client][robotIndex]])
        {
            bullet[client][robotIndex] += weaponloadcount[weapontypes[client][robotIndex]];
            if (bullet[client][robotIndex] >= weaponclipsize[weapontypes[client][robotIndex]])
            {
                bullet[client][robotIndex] = weaponclipsize[weapontypes[client][robotIndex]];
                reloading[client][robotIndex] = false;
                EmitSoundToAll(SOUNDREADY, robots[client][robotIndex], SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, _, SNDVOL_NORMAL, _, _, currentRobotPos, NULL_VECTOR, true, 0.0);
            }
            else if (weaponloaddisrupt[weapontypes[client][robotIndex]])
            {
                EmitSoundToAll(SOUNDRELOAD, robots[client][robotIndex], SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, _, SNDVOL_NORMAL, _, _, currentRobotPos, NULL_VECTOR, true, 0.0);
                reloadtime[client][robotIndex] = currenttime;
            }
        }
    }
    else
    {
        if (bullet[client][robotIndex] <= 0)
        {
            reloading[client][robotIndex] = true;
            reloadtime[client][robotIndex] = currenttime;
            EmitSoundToAll(SOUNDCLIPEMPTY, robots[client][robotIndex], SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, _, SNDVOL_NORMAL, _, _, currentRobotPos, NULL_VECTOR, true, 0.0);
            if (!weaponloaddisrupt[weapontypes[client][robotIndex]]) bullet[client][robotIndex] = 0;
        }
    }

    float currentFireInterval = fireinterval[weapontypes[client][robotIndex]];
    if (!reloading[client][robotIndex] && targetAcquired && bullet[client][robotIndex] > 0 && (currenttime - firetime[client][robotIndex] > currentFireInterval))
    {
        FireBullet(client, robotIndex, enemyTargetPos, currentRobotPos);
        bullet[client][robotIndex]--;
        firetime[client][robotIndex] = currenttime;
    }
}

stock float Lerp(float current, float target, float fraction)
{
    return current + (target - current) * fraction;
}

public void OnGameFrame()
{
	if (!gamestart) return;

	float currenttime = GetEngineTime();
	float duration = currenttime - s_lastFrameTime;
	if (duration <= 0.0 || duration > 0.2) duration = 0.033;
	s_lastFrameTime = currenttime;

	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsValidClient(client)) continue;

		if (!IsPlayerAlive(client)) {
			CleanupAllRobots(client, true);
			continue;
		}

		if (robot_energy_cvar > -0.5) {
		    bool clientHasActiveRobots = false;
		    for(int k=0; k < MAX_ROBOTS_PER_PLAYER; ++k) {
		        if(RealValidEntity(robots[client][k])) {
		            clientHasActiveRobots = true;
		            break;
		        }
		    }
		    if(clientHasActiveRobots) {
		        botenergy[client] += duration;
		    }
		}

		if (currenttime - scantime[client] > (0.1 > robot_reactiontime_cvar ? 0.1 : robot_reactiontime_cvar))
		{
			scantime[client] = currenttime;
			float playerEyePos[3];
			GetClientEyePosition(client, playerEyePos);
			g_playerMainSIenemy[client] = ScanEnemy(client, playerEyePos, -1);
			g_playerMainCIenemy[client] = ScanCommon(client, playerEyePos, -1);
		}
	}

	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsPlayerAlive(client)) { // Ensure player is alive for DoRobotLogic
			DoRobotLogic(client, currenttime, duration);
		}
	}
}

int ScanCommon(int client, float rpos[3], int ignoredEntityForLOS)
{
#pragma unused client
    float infectedpos[3], vec[3], angle[3];
    int find = 0;
    float mindis = robot_scanrange_cvar;
    
    for (int i = MaxClients+1; i <= GetMaxEntities(); i++)
    {
        if (!RealValidEntity(i)) continue;
        static char classname[9];
        GetEntityClassname(i, classname, sizeof(classname));
        if (!StrEqual(classname, "infected")) continue;
        
        int health = GetEntProp(i, Prop_Data, "m_iHealth");
        if (health <= 0) continue;
        
        GetEntPropVector(i, Prop_Data, "m_vecOrigin", infectedpos);
        float dis = GetVectorDistance(rpos, infectedpos);
        
        if (dis < mindis)
        {
            SubtractVectors(infectedpos, rpos, vec);
            GetVectorAngles(vec, angle);
            TR_TraceRayFilter(rpos, infectedpos, MASK_SOLID|MASK_PLAYERSOLID, RayType_EndPoint, TraceRayDontHitSelfAndLive, ignoredEntityForLOS);
            
            if (!TR_DidHit())
            {
                find = i;
                mindis = dis;
            }
        }
    }
    return find;
}

int ScanEnemy(int client, float rpos[3], int ignoredEntityForLOS)
{
#pragma unused client
    float infectedpos[3], vec[3], angle[3];
    int find = 0;
    float mindis = robot_scanrange_cvar;
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && GetClientTeam(i) == 3 && IsPlayerAlive(i))
        {
            GetClientAbsOrigin(i, infectedpos);
            float dis = GetVectorDistance(rpos, infectedpos);
            
            if (dis < mindis)
            {
                SubtractVectors(infectedpos, rpos, vec);
                GetVectorAngles(vec, angle);
                TR_TraceRayFilter(rpos, infectedpos, MASK_SOLID|MASK_PLAYERSOLID, RayType_EndPoint, TraceRayDontHitSelfAndLive, ignoredEntityForLOS);
                
                if (!TR_DidHit())
                {
                    find = i;
                    mindis = dis;
                }
            }
        }
    }
    return find;
}

bool TraceRayDontHitSelfAndLive(int entity, int contentsMask, any data)
{
#pragma unused contentsMask
    if (data != -1 && entity == data) return false;

    if (IsValidClient(entity))
    {
        if(GetClientTeam(entity) == 2) return false;
    }
    return true;
}


bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
#pragma unused contentsMask
    return (entity > MaxClients || !entity);
}

bool IsValidClient(int client, bool replaycheck = true)
{
    if (client <= 0 || client > MaxClients) return false;
    if (!IsClientInGame(client)) return false;
    if (replaycheck && (IsClientSourceTV(client) || IsClientReplay(client))) return false;
    return true;
}

bool RealValidEntity(int entity)
{
    return (entity > 0 && IsValidEntity(entity));
}

public void OnClientDisconnect(int client)
{
    SavePlayerRobotConfig(client);
    CleanupAllRobots(client, true);
}

void SavePlayerRobotConfig(int client)
{
    if (!IsValidClient(client) || IsFakeClient(client)) return;
        
    g_bHasSavedConfig[client] = false;
    int robotCount = 0;
    for (int i = 0; i < MAX_ROBOTS_PER_PLAYER; i++)
    {
        if (RealValidEntity(robots[client][i]))
        {
            g_iSavedWeaponTypes[client][robotCount] = weapontypes[client][i];
            robotCount++;
        }
    }
    
    if (robotCount > 0)
    {
        g_iSavedRobotCount[client] = robotCount;
        g_bHasSavedConfig[client] = true;
    } else {
		g_iSavedRobotCount[client] = 0;
	}
}

void LoadPlayerRobotConfig(int client)
{
    if (!IsValidClient(client) || IsFakeClient(client) || !g_bHasSavedConfig[client]) return;
    
    CleanupAllRobots(client, true);
        
    for (int i = 0; i < g_iSavedRobotCount[client]; i++)
    {
		int robotIndexToSpawn = -1;
		for(int j=0; j < MAX_ROBOTS_PER_PLAYER; ++j) {
			if(!RealValidEntity(robots[client][j])) {
				robotIndexToSpawn = j;
				break;
			}
		}
        
        if (robotIndexToSpawn != -1)
        {
            weapontypes[client][robotIndexToSpawn] = g_iSavedWeaponTypes[client][i];
            AddRobot(client, robotIndexToSpawn, false);
        } else {
			PrintToServer("[RobotGuns] Error: Could not find slot to restore robot for client %d", client);
			break;
		}
    }
	g_bHasSavedConfig[client] = false;
}

void FireBullet(int client, int robotIndex, const float enemyTargetPos[3], const float botOrigin[3])
{
    if (!IsValidClient(client) || !RealValidEntity(robots[client][robotIndex])) return;
        
    float vAngles[3], vAngles2[3], firePos[3], endPos[3];
    float fwd[3], right[3], up[3];
    float spreadRange1, spreadRange2;

    float dirToEnemy[3];
    SubtractVectors(enemyTargetPos, botOrigin, dirToEnemy);
    GetVectorAngles(dirToEnemy, vAngles);
    
    GetAngleVectors(vAngles, fwd, right, up);
    
    for (int k = 0; k < 3; k++) firePos[k] = botOrigin[k] + (fwd[k] * 20.0) + (up[k] * 5.0);
     
    spreadRange1 = 0.0 - bulletaccuracy[weapontypes[client][robotIndex]];
    spreadRange2 = bulletaccuracy[weapontypes[client][robotIndex]];
    
    for (int c = 0; c < weaponbulletpershot[weapontypes[client][robotIndex]]; c++)
    {
        vAngles2[0] = vAngles[0] + GetRandomFloat(spreadRange1, spreadRange2);
        vAngles2[1] = vAngles[1] + GetRandomFloat(spreadRange1, spreadRange2);
        vAngles2[2] = vAngles[2];
        
        int hitTargetEnt = 0;
        float damageToDeal = StringToFloat(weaponbulletdamagestr[weapontypes[client][robotIndex]]);
        float traceStartPos[3]; for(int k=0; k<3; k++) traceStartPos[k] = firePos[k];
        
        int penetrations = 0;
        int maxPenetrations = weaponbulletpenetration[weapontypes[client][robotIndex]] ? 3 : 1;

        while(penetrations < maxPenetrations)
        {
            TR_TraceRayFilter(traceStartPos, vAngles2, MASK_SHOT_HULL, RayType_Infinite, TraceRayIgnoreSelfAndSurvivors, robots[client][robotIndex]);
            
            if (TR_DidHit())
            {
                TR_GetEndPosition(endPos);
                TE_SetupBeamPoints(traceStartPos, endPos, g_sprite, 0, 0, 0, 0.07, 0.1, 0.8, 1, 0.0, {200,200,200,230}, 0);
                TE_SendToAll();

                hitTargetEnt = TR_GetEntityIndex();
                
                float sparkDir[3]; sparkDir[0] = GetRandomFloat(-1.0, 1.0); sparkDir[1] = GetRandomFloat(-1.0, 1.0); sparkDir[2] = GetRandomFloat(-1.0, 1.0);
                TE_SetupSparks(endPos, sparkDir, 1, 1); TE_SendToAll();
                
                if (RealValidEntity(hitTargetEnt))
                {
                    char classname[64];
                    GetEdictClassname(hitTargetEnt, classname, sizeof(classname));
                    
                    if (StrEqual(classname, "infected") || StrEqual(classname, "witch") || (IsValidClient(hitTargetEnt) && GetClientTeam(hitTargetEnt) == 3))
                    {
                        SDKHooks_TakeDamage(hitTargetEnt, robots[client][robotIndex], client, damageToDeal, DMG_BULLET, -1, NULL_VECTOR, endPos);
                        
                        if (weaponbulletpenetration[weapontypes[client][robotIndex]])
                        {
                            penetrations++;
                            float hitDir[3];
                            GetAngleVectors(vAngles2, hitDir, NULL_VECTOR, NULL_VECTOR);
                            ScaleVector(hitDir, 1.0);
                            AddVectors(endPos, hitDir, traceStartPos);
                            damageToDeal *= 0.75;
                            if(damageToDeal < 5.0) break;
                            continue;
                        }
                    }
                }
                break;
            }
            else
            {
                float farEnd[3];
                float traceDir[3]; GetAngleVectors(vAngles2, traceDir, NULL_VECTOR, NULL_VECTOR);
                ScaleVector(traceDir, 3000.0);
                AddVectors(traceStartPos, traceDir, farEnd);
                TE_SetupBeamPoints(traceStartPos, farEnd, g_sprite, 0, 0, 0, 0.07, 0.1, 0.8, 1, 0.0, {200,200,200,230}, 0);
                TE_SendToAll();
                break;
            }
        }
    }
    EmitSoundToAll(SOUND[weapontypes[client][robotIndex]], robots[client][robotIndex], SNDCHAN_WEAPON, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, robots[client][robotIndex], botOrigin, NULL_VECTOR, true, 0.0);
}

float LerpAngle(float current, float target, float speed)
{
    float diff = target - current;
    while (diff > 180.0) diff -= 360.0;
    while (diff < -180.0) diff += 360.0;
    return current + diff * speed;
}

// HasLineOfSight: start and end are read-only.
bool HasLineOfSight(const float start[3], const float end[3])
{
    Handle trace = TR_TraceRayFilterEx(start, end, MASK_VISIBLE_AND_NPCS, RayType_EndPoint, TraceRayDontHitSelfAndLiveFilterForLOS, -1);
    bool didHit = TR_DidHit(trace);
    CloseHandle(trace);
    return !didHit;
}

// This filter is for general LOS checks from a point to another, data is usually -1
public bool TraceRayDontHitSelfAndLiveFilterForLOS(int entity, int contentsMask, any data)
{
#pragma unused data
#pragma unused contentsMask
    if (IsValidClient(entity)) {
        return false;
    }
    if (RealValidEntity(entity)) {
        char classname[32];
        GetEntityClassname(entity, classname, sizeof(classname));
        if (StrEqual(classname, "infected")) {
            return false;
        }
    }
    return true;
}

// This filter is used by ScanCommon/ScanEnemy. 'data' is ignoredEntityForLOS (the scanning robot or -1).
bool TraceRayDontHitSelfAndLive(int entity, int contentsMask, any data)
{
#pragma unused contentsMask
    if (data != -1 && entity == data) return false;

    if (IsValidClient(entity) && GetClientTeam(entity) == 2) return false;

    return true;
}


bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
#pragma unused contentsMask
    return (entity > MaxClients || !entity);
}

// Filter for FireBullet: 'data' is the firing robot's entity index.
bool TraceRayIgnoreSelfAndSurvivors(int entity, int contentsMask, any data)
{
#pragma unused contentsMask
    if (entity == data) return false;
    if (IsValidClient(entity) && GetClientTeam(entity) == 2) return false;
    return true;
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
#pragma unused name, dontBroadcast
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    int newTeam = GetEventInt(event, "team");
    int oldTeam = GetEventInt(event, "oldteam");
    
    if (!IsValidClient(client)) return;
        
    if (oldTeam == 2 && newTeam != 2)
    {
        SavePlayerRobotConfig(client);
        CleanupAllRobots(client, true);
    }
    else if (newTeam == 2 && oldTeam != 2 && IsPlayerAlive(client))
    {
        CleanupAllRobots(client, true);
        LoadPlayerRobotConfig(client);
    }
}

public void OnMapEnd()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsValidClient(client))
        {
            SavePlayerRobotConfig(client);
            CleanupAllRobots(client, true);
        }
    }
	gamestart = false;
}

public Action Timer_RestoreRobots(Handle timer)
{
#pragma unused timer
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
        {
            LoadPlayerRobotConfig(i);
        }
    }
    return Plugin_Stop;
}

void CleanupAllRobots(int client, bool deleteEntities)
{
    for (int i = 0; i < MAX_ROBOTS_PER_PLAYER; i++)
    {
        if (robots[client][i] != 0)
        {
            ReleaseRobot(client, i, deleteEntities);
        }
    }
    
    if(deleteEntities) {
        char targetname_check[64];
        char robot_search_name[32];
        Format(robot_search_name, sizeof(robot_search_name), "robot_%d_", client);

        int entity = -1;
        while ((entity = FindEntityByClassname(entity, "prop_dynamic_override")) != -1)
        {
            if (IsValidEntity(entity))
            {
                if (HasEntProp(entity, Prop_Data, "m_iName"))
                {
                    GetEntPropString(entity, Prop_Data, "m_iName", targetname_check, sizeof(targetname_check));
                    if (StrContains(targetname_check, robot_search_name, false) == 0)
                    {
                        char full_robot_name_pattern[40];
                        bool matches_a_robot_of_this_client = false;
                        for(int r_idx=0; r_idx < MAX_ROBOTS_PER_PLAYER; ++r_idx) {
                            Format(full_robot_name_pattern, sizeof(full_robot_name_pattern), "robot_%d_%d", client, r_idx);
                            if(StrEqual(targetname_check, full_robot_name_pattern)) {
                                matches_a_robot_of_this_client = true;
                                break;
                            }
                        }
                        if(matches_a_robot_of_this_client) {
                             AcceptEntityInput(entity, "Kill");
                        }
                    }
                }
            }
        }
    }
    
    for (int i = 0; i < MAX_ROBOTS_PER_PLAYER; i++)
    {
        robots[client][i] = 0;
        weapontypes[client][i] = 0;
        bullet[client][i] = 0;
        firetime[client][i] = 0.0;
        reloading[client][i] = false;
        reloadtime[client][i] = 0.0;
		g_robotTargets[client][i] = 0;
    }
}

[end of l4d_robot.sp]
