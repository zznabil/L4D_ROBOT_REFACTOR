#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

#define PLUGIN_NAME "[L4D1/2] Robot Guns"
#define PLUGIN_AUTHOR "Pan Xiaohai, Shadowysn (edit)"
#define PLUGIN_DESC "Use automatic robot guns to passively attack."
#define PLUGIN_VERSION "1.5b"
#define PLUGIN_URL "https://forums.alliedmods.net/showthread.php?t=130177"
#define PLUGIN_NAME_SHORT "Robot Guns"
#define PLUGIN_NAME_TECH "l4d_robot"

#define MAX_ROBOTS_PER_PLAYER 4  // Maximum number of robots a player can have

// Robot position offsets relative to player
#define ROBOT_1_OFFSET_X 0.0
#define ROBOT_1_OFFSET_Y 0.0
#define ROBOT_1_OFFSET_Z 15.0

#define ROBOT_2_OFFSET_X 40.0  // Right side
#define ROBOT_2_OFFSET_Y 0.0
#define ROBOT_2_OFFSET_Z 15.0

#define ROBOT_3_OFFSET_X -40.0  // Left side
#define ROBOT_3_OFFSET_Y 0.0
#define ROBOT_3_OFFSET_Z 15.0

#define ROBOT_4_OFFSET_X 0.0   // Behind
#define ROBOT_4_OFFSET_Y -40.0
#define ROBOT_4_OFFSET_Z 15.0

#define SOUNDCLIPEMPTY		   "weapons/ClipEmpty_Rifle.wav" 
#define SOUNDRELOAD			  "weapons/shotgun/gunother/shotgun_load_shell_2.wav" 
#define SOUNDREADY			 "weapons/shotgun/gunother/shotgun_pump_1.wav"

#define ORIGINAL_PAN 0

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

static int weaponclipsize[WEAPONCOUNT] =		{15,	50,		10,		8,		50,		30,		8,		40,		20,		50,		150,	8,		10,		30,		15,		20,		50,		50		};

static int weaponbulletpershot[WEAPONCOUNT] =	{1,		1,		7,		7,		1,		1,		1,		1,		1,		1,		1,		7,		7,		1,		1,		1,		1,		1		};

static float weaponloadtime[WEAPONCOUNT] =		{2.0,	1.5,	0.3,	0.3,	1.5,	1.5,	1.9,	1.5,	1.5,	1.6,	0.0,	0.3,	0.3,	2.0,	2.0,	2.0,	1.5,	1.5		};

static int weaponloadcount[WEAPONCOUNT] =		{15,	50,		1,		1,		50,		30,		8,		40,		60,		50,		1,		1,		1,		30,		15,		20,		50,		50		};

static bool weaponloaddisrupt[WEAPONCOUNT] =	{false,	false,	true,	true,	false,	false,	false,	false,	false,	true,	true,	true,	false,	false,	false,	false,	false,	false	};

static int robots[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];
static int keybuffer[MAXPLAYERS+1];
static int weapontypes[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];
static int bullet[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];
static float firetime[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];
static bool reloading[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];
static float reloadtime[MAXPLAYERS+1][MAX_ROBOTS_PER_PLAYER];
static float scantime[MAXPLAYERS+1];
static float walktime[MAXPLAYERS+1];
static float botenergy[MAXPLAYERS+1];

static int SIenemy[MAXPLAYERS+1];
static int CIenemy[MAXPLAYERS+1];

static float robotangle[MAXPLAYERS+1][3];

ConVar l4d_robot_limit;
ConVar l4d_robot_reactiontime;
ConVar l4d_robot_scanrange; 
ConVar l4d_robot_energy; 
ConVar l4d_robot_damagefactor; 
ConVar l4d_robot_messages;
ConVar l4d_robot_glow; 

#define BITFLAG_MESSAGE_INFO (1 << 0)
#define BITFLAG_MESSAGE_STEAL (1 << 1)

static float robot_reactiontime;
static float robot_scanrange; 
static float robot_energy;
static float robot_damagefactor;
static int robot_messages;
static char robot_glow[12];

static int g_sprite;
 
static bool L4D2Version = false;
static int GameMode=0;

static bool gamestart = false;

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
}

public void OnPluginStart()
{
	static char temp_str[32];
	
	Format(temp_str, sizeof(temp_str), "%s_limit", PLUGIN_NAME_TECH);
 	l4d_robot_limit = CreateConVar(temp_str, "8", "Number of total Robots [0-32]", FCVAR_NONE);
	
	Format(temp_str, sizeof(temp_str), "%s_reactiontime", PLUGIN_NAME_TECH);
	l4d_robot_reactiontime = CreateConVar(temp_str, "2.0", "Robot reaction time [0.5, 5.0]", FCVAR_NONE);
	
	Format(temp_str, sizeof(temp_str), "%s_scanrange", PLUGIN_NAME_TECH);
	l4d_robot_scanrange = CreateConVar(temp_str, "600.0", "Scan enemy range [100.0, 10000.0]", FCVAR_NONE);
 	
	Format(temp_str, sizeof(temp_str), "%s_energy", PLUGIN_NAME_TECH);
	l4d_robot_energy = CreateConVar(temp_str, "5.0", "Time limit of a robot for a player (minutes) [0.0, 100.0]", FCVAR_NONE);
	
	Format(temp_str, sizeof(temp_str), "%s_damagefactor", PLUGIN_NAME_TECH);
	l4d_robot_damagefactor = CreateConVar(temp_str, "0.5", "Damage factor [0.2, 1.0]", FCVAR_NONE);
	
	Format(temp_str, sizeof(temp_str), "%s_messages", PLUGIN_NAME_TECH);
	l4d_robot_messages = CreateConVar(temp_str, "3", "Which messages to enable, as bitflags [1 = Info, 2 = Steal (UNUSED)]", FCVAR_NONE);

	Format(temp_str, sizeof(temp_str), "%s_glow", PLUGIN_NAME_TECH);
	l4d_robot_glow = CreateConVar(temp_str, "0 127 127", "The glow color to use for robots [R, G, B]", FCVAR_NONE);

	AutoExecConfig(true, "l4d_robot_12");
	HookConVarChange(l4d_robot_reactiontime, ConVarChange);
	HookConVarChange(l4d_robot_scanrange, ConVarChange); 
	HookConVarChange(l4d_robot_energy, ConVarChange);
	HookConVarChange(l4d_robot_damagefactor, ConVarChange);
	HookConVarChange(l4d_robot_messages, ConVarChange);
	HookConVarChange(l4d_robot_glow, ConVarChange);
	GetConVar();

	static char GameName[13];
	GetConVarString(FindConVar("mp_gamemode"), GameName, sizeof(GameName));
	
	if (strncmp(GameName, "survival", 8, false) == 0)
		GameMode = 3;
	else if (strncmp(GameName, "versus", 6, false) == 0 || strncmp(GameName, "teamversus", 10, false) == 0 || strncmp(GameName, "scavenge", 8, false) == 0 || strcmp(GameName, "teamscavenge", false) == 0)
		GameMode = 2;
	else if (strncmp(GameName, "coop", 4, false) == 0 || strncmp(GameName, "realism", 7, false) == 0)
		GameMode = 1;
	else
		GameMode = 0;
 
 	RegConsoleCmd("sm_robot", sm_robot);
	RegConsoleCmd("sm_removerobot", sm_removerobot);
	HookEvent("round_start", RoundStart, EventHookMode_Post);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
	HookEvent("round_end", RoundEnd, EventHookMode_Post);
	HookEvent("finale_win", RoundEnd, EventHookMode_Post);
	HookEvent("mission_lost", RoundEnd, EventHookMode_Post);
	HookEvent("map_transition", RoundEnd, EventHookMode_Post);
	HookEvent("player_spawn", Event_Spawn, EventHookMode_Post);	 
 	gamestart = false;
}

public void OnPluginEnd()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		for (int j = 0; j < MAX_ROBOTS_PER_PLAYER; j++)
		{
			if (RealValidEntity(robots[i][j]))
			{
				Release(i, j);	 
 			}
		}
	}
}

void GetConVar()
{
	robot_reactiontime = GetConVarFloat(l4d_robot_reactiontime );
	robot_scanrange = GetConVarFloat(l4d_robot_scanrange );
 	robot_energy = GetConVarFloat(l4d_robot_energy ) * 60.0;
 	robot_damagefactor = GetConVarFloat(l4d_robot_damagefactor);
	robot_messages = GetConVarInt(l4d_robot_messages);
	GetConVarString(l4d_robot_glow, robot_glow, sizeof(robot_glow));
	static char str[10];
	for (int i = 0; i < WEAPONCOUNT; i++)
	{
		Format(str, sizeof(str), "%d", RoundFloat(weaponbulletdamage[i] * robot_damagefactor));
		weaponbulletdamagestr[i] = str;
	}
}
void ConVarChange(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetConVar();
}

public void OnMapStart()
{
	PrecacheModel(MODEL[0], true);
	PrecacheModel(MODEL[1], true);
	PrecacheModel(MODEL[2], true);
	PrecacheModel(MODEL[3], true);
	PrecacheModel(MODEL[4], true);
	PrecacheModel(MODEL[5], true);

	PrecacheSound(SOUND[0], true);
	PrecacheSound(SOUND[1], true);
	PrecacheSound(SOUND[2], true);
	PrecacheSound(SOUND[3], true);
	PrecacheSound(SOUND[4], true);
	PrecacheSound(SOUND[5], true);
	
	PrecacheSound(SOUNDCLIPEMPTY, true);
	PrecacheSound(SOUNDRELOAD, true);
	PrecacheSound(SOUNDREADY, true);
	
	if (L4D2Version)
	{
		g_sprite = PrecacheModel("materials/sprites/laserbeam.vmt");	
		
		for (int i = 6; i < WEAPONCOUNT; i++)
		{
			PrecacheModel( MODEL[i] , true );
			PrecacheSound(SOUND[i], true) ;
		}
	}
	else
	{
		g_sprite = PrecacheModel("materials/sprites/laser.vmt");	
 
	}
	gamestart = false;
}

void RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		for (int j = 0; j < MAX_ROBOTS_PER_PLAYER; j++)
		{
			if (RealValidEntity(robots[i][j]))
			{
				Release(i, j);	 
 			}
		}
		botenergy[i] = 0.0;
	}
	gamestart = false;
}

void RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		for (int j = 0; j < MAX_ROBOTS_PER_PLAYER; j++)
		{
			if (RealValidEntity(robots[i][j]))
			{
				Release(i, j);	 
 			}
		}
	}
	gamestart = false;
}

void Event_Spawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	for (int i = 0; i < MAX_ROBOTS_PER_PLAYER; i++)
	{
		robots[client][i] = 0;
	}
}

void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if (!gamestart) return;
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsValidClient(attacker))
	{	
		if (attacker != victim && GetClientTeam(attacker) == 3)
		{
			scantime[victim] = GetEngineTime();
			SIenemy[victim] = attacker;
		}
	}
	else
	{
		int ent = GetEventInt(event, "attackerentid");	
		CIenemy[victim] = ent;
	}
}

void DelRobot(int ent)
{
	if (!RealValidEntity(ent)) return;
	
	AcceptEntityInput(ent, "Kill");
}

void Release(int controller, int robotIndex, bool del = true)
{
	int r = robots[controller][robotIndex];
	if (RealValidEntity(r))
	{
		robots[controller][robotIndex] = 0;
	 
		if (del) DelRobot(r);
	}
	if (gamestart)
	{
		int count = 0;
		for (int i = 1; i <= MaxClients; i++)
		{
			for (int j = 0; j < MAX_ROBOTS_PER_PLAYER; j++)
			{
				if (RealValidEntity(robots[i][j]))
				{
					count++; 
				}
			}
		}
		if (count == 0) gamestart = false;
	}
}

Action sm_robot(int client, int args)
{  
	if (GameMode == 2) return Plugin_Handled;
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Handled;

	int playerRobotCount = 0;
	for (int i = 0; i < MAX_ROBOTS_PER_PLAYER; i++)
	{
		if (RealValidEntity(robots[client][i]))
		{
			playerRobotCount++;
		}
	}

	if (playerRobotCount >= MAX_ROBOTS_PER_PLAYER)
	{
		PrintToChat(client, "You already have maximum number of robots! Use !removerobot <1-%d> to remove a specific robot.", MAX_ROBOTS_PER_PLAYER);
		return Plugin_Handled;
	}
	
	int robotIndex = -1;
	for (int i = 0; i < MAX_ROBOTS_PER_PLAYER; i++)
	{
		if (!RealValidEntity(robots[client][i]))
		{
			robotIndex = i;
			break;
		}
	}

	if (robotIndex == -1)
	{
		PrintToChat(client, "Error finding available robot slot!");
		return Plugin_Handled;
	}

	int totalRobots = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			for (int j = 0; j < MAX_ROBOTS_PER_PLAYER; j++)
			{
				if (RealValidEntity(robots[i][j]))
				{
					totalRobots++;
				}
			}
		}
	}
	
	if (totalRobots + 1 > GetConVarInt(l4d_robot_limit))
	{
		PrintToChat(client, "No more robots available! Server limit reached.");
		return Plugin_Handled;
	}

	if (args >= 1)
	{
		static char arg[24];
		GetCmdArg(1, arg, sizeof(arg));
		if (strncmp(arg, "hunting", 7, false) == 0) weapontypes[client][robotIndex]=0;
		else if (strncmp(arg, "rifle", 5, false) == 0) weapontypes[client][robotIndex]=1;
		else if (strncmp(arg, "auto", 4, false) == 0) weapontypes[client][robotIndex]=2;
		else if (strncmp(arg, "pump", 4, false) == 0) weapontypes[client][robotIndex]=3;
		else if (strncmp(arg, "smg", 3, false) == 0) weapontypes[client][robotIndex]=4;
		else if (strncmp(arg, "pistol", 6, false) == 0) weapontypes[client][robotIndex]=5;
		else if (strncmp(arg, "magnum", 6, false) == 0 && L4D2Version) weapontypes[client][robotIndex]=6;
		else if (strncmp(arg, "ak47", 4, false) == 0 && L4D2Version) weapontypes[client][robotIndex]=7;
		else if (strncmp(arg, "desert", 6, false) == 0 && L4D2Version) weapontypes[client][robotIndex]=8;
		else if (strncmp(arg, "sg552", 5, false) == 0 && L4D2Version) weapontypes[client][robotIndex]=9;
		else if (strncmp(arg, "m60", 3, false) == 0 && L4D2Version) weapontypes[client][robotIndex]=10;
		else if (strncmp(arg, "chrome", 6, false) == 0 && L4D2Version) weapontypes[client][robotIndex]=11;
		else if (strncmp(arg, "spas", 4, false) == 0 && L4D2Version) weapontypes[client][robotIndex]=12;
		else if (strncmp(arg, "military", 8, false) == 0 && L4D2Version) weapontypes[client][robotIndex]=13;
		else if (strncmp(arg, "scout", 5, false) == 0 && L4D2Version) weapontypes[client][robotIndex]=14;
		else if (strncmp(arg, "awp", 3, false) == 0 && L4D2Version) weapontypes[client][robotIndex]=15;
		else if (strncmp(arg, "mp5", 3, false) == 0 && L4D2Version) weapontypes[client][robotIndex]=16;
		else if (strncmp(arg, "silenced", 8, false) == 0 && L4D2Version) weapontypes[client][robotIndex]=17;
		else
		{
			if (L4D2Version)
			{ weapontypes[client][robotIndex] = GetRandomInt(0, WEAPONCOUNT-1); }
			else
			{ weapontypes[client][robotIndex] = GetRandomInt(0, 5); }
		}
	}	
	else
	{
		if (L4D2Version)
		{ weapontypes[client][robotIndex] = GetRandomInt(0, WEAPONCOUNT-1); }
		else
		{ weapontypes[client][robotIndex] = GetRandomInt(0, 5); }
	}
	AddRobot(client, robotIndex, true);
	return Plugin_Handled;
} 

Action sm_removerobot(int client, int args)
{
	if (GameMode == 2) return Plugin_Handled;
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Handled;

	if (args < 1)
	{
		PrintToChat(client, "Usage: sm_removerobot <1-%d>", MAX_ROBOTS_PER_PLAYER);
		return Plugin_Handled;
	}

	static char arg[24];
	GetCmdArg(1, arg, sizeof(arg));
	int robotIndex = StringToInt(arg) - 1;

	if (robotIndex < 0 || robotIndex >= MAX_ROBOTS_PER_PLAYER)
	{
		PrintToChat(client, "Invalid robot index! Use !removerobot <1-%d>", MAX_ROBOTS_PER_PLAYER);
		return Plugin_Handled;
	}

	if (!RealValidEntity(robots[client][robotIndex]))
	{
		PrintToChat(client, "You don't have a robot at index %d!", robotIndex + 1);
		return Plugin_Handled;
	}

	Release(client, robotIndex);
	PrintToChat(client, "Robot at index %d removed!", robotIndex + 1);
	return Plugin_Handled;
}

void AddRobot(int client, int robotIndex, bool showmsg = false)
{
	bullet[client][robotIndex] = weaponclipsize[weapontypes[client][robotIndex]];
	float vAngles[3], vOrigin[3], pos[3];

	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);

	TR_TraceRayFilter(vOrigin, vAngles, MASK_SOLID,  RayType_Infinite, TraceEntityFilterPlayer);

	if (TR_DidHit())
	{
		TR_GetEndPosition(pos);
	}

	float v1[3], v2[3];
	 
	SubtractVectors(vOrigin, pos, v1);
	NormalizeVector(v1, v2);

	ScaleVector(v2, 50.0);

	AddVectors(pos, v2, v1);  // v1 explode taget
	
	int temp_ent = CreateEntityByName(MODEL[weapontypes[client][robotIndex]]);
	if (!RealValidEntity(temp_ent)) return;
	DispatchSpawn(temp_ent);
	static char temp_str[128];
	GetEntPropString(temp_ent, Prop_Data, "m_ModelName", temp_str, sizeof(temp_str));
	AcceptEntityInput(temp_ent, "Kill");
	
	int ent = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(ent, "solid", "6");
	DispatchKeyValue(ent, "model", temp_str);
	DispatchKeyValue(ent, "glowcolor", robot_glow);
	DispatchKeyValue(ent, "glowstate", "2");
	DispatchSpawn(ent);
	
	// Apply robot position offset
	switch (robotIndex)
	{
		case 0:
		{
			pos[0] += ROBOT_1_OFFSET_X;
			pos[1] += ROBOT_1_OFFSET_Y;
			pos[2] += ROBOT_1_OFFSET_Z;
		}
		case 1:
		{
			pos[0] += ROBOT_2_OFFSET_X;
			pos[1] += ROBOT_2_OFFSET_Y;
			pos[2] += ROBOT_2_OFFSET_Z;
		}
		case 2:
		{
			pos[0] += ROBOT_3_OFFSET_X;
			pos[1] += ROBOT_3_OFFSET_Y;
			pos[2] += ROBOT_3_OFFSET_Z;
		}
		case 3:
		{
			pos[0] += ROBOT_4_OFFSET_X;
			pos[1] += ROBOT_4_OFFSET_Y;
			pos[2] += ROBOT_4_OFFSET_Z;
		}
	}
	
	TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
	
	SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1);
	SetEntityMoveType(ent, MOVETYPE_FLY);
	
	SetVariantString("idle");
	AcceptEntityInput(ent, "SetAnimation");
	SetVariantString("idle");
	AcceptEntityInput(ent, "SetDefaultAnimation");
	
	SIenemy[client] = 0;
	CIenemy[client] = 0;
	scantime[client] = 0.0;
	keybuffer[client] = 0;
	bullet[client][robotIndex] = 0;
	reloading[client][robotIndex] = false;
	reloadtime[client][robotIndex] = 0.0;
	firetime[client][robotIndex] = 0.0;
	robots[client][robotIndex] = ent;
	if (showmsg && (robot_messages & BITFLAG_MESSAGE_INFO))
	{
		PrintHintText(client, "You have spawned a robot. Press WALK+USE to remove it anytime.");
		PrintToChatAll("\x04%N\x03 turned on their robot.", client);
	}
	
	gamestart = true;
}

static float lasttime=0.0;

static int button;

static float robotpos[3], robotvec[3];

static float clienteyepos[3];

static float clientangle[3], enemypos[3], infectedorigin[3], infectedeyepos[3];
 
static float chargetime;

void Do(int client, float currenttime, float duration)
{
	for (int i = 0; i < MAX_ROBOTS_PER_PLAYER; i++)
	{
		if (RealValidEntity(robots[client][i]))
		{
			if (IsFakeClient(client) || !IsValidClient(client) || !IsPlayerAlive(client))
			{
				Release(client, i);
			}
			else  
			{			
				botenergy[client] += duration;
				if (robot_energy > -1.0 && botenergy[client] > robot_energy)
				{
					Release(client, i);
					PrintHintText(client, "Your bot energy is not enough.");
					return;
				}
				
				button = GetClientButtons(client);
				GetEntPropVector(robots[client][i], Prop_Send, "m_vecOrigin", robotpos);	
				
				if ((button & IN_USE) && (button & IN_SPEED) && !(keybuffer[client] & IN_USE))
				{
					Release(client, i);
					if (robot_messages & BITFLAG_MESSAGE_INFO)
					{
						PrintToChatAll("\x04%N\x03 turned off their robot.", client);
					}
					return;
				}
				
				if (currenttime - scantime[client] > robot_reactiontime)
				{
					scantime[client] = currenttime;
					SIenemy[client] = ScanEnemy(client, robotpos);
					CIenemy[client] = ScanCommon(client, robotpos);
				}
				
				bool targetok = false;
				if (IsValidClient(SIenemy[client]) && IsPlayerAlive(SIenemy[client]))
				{
					GetClientEyePosition(SIenemy[client], infectedeyepos);
					GetClientAbsOrigin(SIenemy[client], infectedorigin);	
					enemypos[0] = infectedorigin[0] * 0.4 + infectedeyepos[0] * 0.6;
					enemypos[1] = infectedorigin[1] * 0.4 + infectedeyepos[1] * 0.6;
					enemypos[2] = infectedorigin[2] * 0.4 + infectedeyepos[2] * 0.6;
					
					SubtractVectors(enemypos, robotpos, robotangle[client]);
					GetVectorAngles(robotangle[client], robotangle[client]);
					targetok = true;
				}
				else 
				{
					SIenemy[client] = 0;
				}
				
				if (!targetok)
				{
					if (RealValidEntity(CIenemy[client]))
					{
						GetEntPropVector(CIenemy[client], Prop_Send, "m_vecOrigin", enemypos);	
						enemypos[2] += 40.0;
						SubtractVectors(enemypos, robotpos, robotangle[client]);
						GetVectorAngles(robotangle[client], robotangle[client]);
						targetok = true;
					}
					else
					{
						CIenemy[client] = 0;
					}
				}
				
				if (reloading[client][i])
				{
					if (bullet[client][i] >= weaponclipsize[weapontypes[client][i]] && currenttime - reloadtime[client][i] > weaponloadtime[weapontypes[client][i]])
					{
						reloading[client][i] = false;	
						reloadtime[client][i] = currenttime;
						EmitSoundToAll(SOUNDREADY, 0, SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, robotpos, NULL_VECTOR, false, 0.0);
					}
					else if (currenttime - reloadtime[client][i] > weaponloadtime[weapontypes[client][i]])
					{
						reloadtime[client][i] = currenttime;
						bullet[client][i] += weaponloadcount[weapontypes[client][i]];
						EmitSoundToAll(SOUNDRELOAD, 0, SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, robotpos, NULL_VECTOR, false, 0.0);
					}
				}
				
				if (!reloading[client][i])
				{
					if (!targetok) 
					{
						if (bullet[client][i] < weaponclipsize[weapontypes[client][i]])					
						{
							reloading[client][i] = true;	
							reloadtime[client][i] = 0.0;
							if (!weaponloaddisrupt[weapontypes[client][i]])
							{
								bullet[client][i] = 0;
							}
						}
					}	
				}
				
				chargetime = fireinterval[weapontypes[client][i]];
				
				if (!reloading[client][i])
				{
					if (currenttime - firetime[client][i] > chargetime)
					{
						if (targetok) 
						{
							if (bullet[client][i] > 0)
							{
								bullet[client][i] = bullet[client][i] - 1;
								FireBullet(client, i, enemypos, robotpos);
								firetime[client][i] = currenttime;	
								reloading[client][i] = false;
							}
							else
							{
								firetime[client][i] = currenttime;
								EmitSoundToAll(SOUNDCLIPEMPTY, 0, SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, robotpos, NULL_VECTOR, false, 0.0);
								reloading[client][i] = true;	
								reloadtime[client][i] = currenttime;
							}
						}
					}
				}
				
				GetClientEyePosition(client, clienteyepos);
				clienteyepos[2] += 30.0;
				GetClientEyeAngles(client, clientangle);
				float distance = GetVectorDistance(robotpos, clienteyepos);

				if (distance > 500.0)
				{
					float offsetPos[3];
					offsetPos = clienteyepos;
					
					// Apply position offset based on robot index
					switch (i)
					{
						case 0:
						{
							offsetPos[0] += ROBOT_1_OFFSET_X;
							offsetPos[1] += ROBOT_1_OFFSET_Y;
							offsetPos[2] += ROBOT_1_OFFSET_Z;
						}
						case 1:
						{
							offsetPos[0] += ROBOT_2_OFFSET_X;
							offsetPos[1] += ROBOT_2_OFFSET_Y;
							offsetPos[2] += ROBOT_2_OFFSET_Z;
						}
						case 2:
						{
							offsetPos[0] += ROBOT_3_OFFSET_X;
							offsetPos[1] += ROBOT_3_OFFSET_Y;
							offsetPos[2] += ROBOT_3_OFFSET_Z;
						}
						case 3:
						{
							offsetPos[0] += ROBOT_4_OFFSET_X;
							offsetPos[1] += ROBOT_4_OFFSET_Y;
							offsetPos[2] += ROBOT_4_OFFSET_Z;
						}
					}
					
					TeleportEntity(robots[client][i], offsetPos, robotangle[client], NULL_VECTOR);
				}
				else if (distance > 100.0)		
				{
					float targetPos[3];
					targetPos = clienteyepos;
					
					// Apply position offset based on robot index
					switch (i)
					{
						case 0:
						{
							targetPos[0] += ROBOT_1_OFFSET_X;
							targetPos[1] += ROBOT_1_OFFSET_Y;
							targetPos[2] += ROBOT_1_OFFSET_Z;
						}
						case 1:
						{
							targetPos[0] += ROBOT_2_OFFSET_X;
							targetPos[1] += ROBOT_2_OFFSET_Y;
							targetPos[2] += ROBOT_2_OFFSET_Z;
						}
						case 2:
						{
							targetPos[0] += ROBOT_3_OFFSET_X;
							targetPos[1] += ROBOT_3_OFFSET_Y;
							targetPos[2] += ROBOT_3_OFFSET_Z;
						}
						case 3:
						{
							targetPos[0] += ROBOT_4_OFFSET_X;
							targetPos[1] += ROBOT_4_OFFSET_Y;
							targetPos[2] += ROBOT_4_OFFSET_Z;
						}
					}
					
					MakeVectorFromPoints(robotpos, targetPos, robotvec);
					NormalizeVector(robotvec, robotvec);
					ScaleVector(robotvec, 5*distance);
					if (!targetok)
					{
						GetVectorAngles(robotvec, robotangle[client]);
					}
					TeleportEntity(robots[client][i], NULL_VECTOR, robotangle[client], robotvec);
					walktime[client] = currenttime;
				}
				else 
				{
					robotvec[0] = robotvec[1] = robotvec[2] = 0.0;
					if (!targetok && currenttime-firetime[client][i] > 4.0 && currenttime-walktime[client] > 1.0)
					{
						robotangle[client][1] += 5.0;
					}
					TeleportEntity(robots[client][i], NULL_VECTOR, robotangle[client], robotvec);
				}
				keybuffer[client] = button;
			}
		}
	}
	
	if (!RealValidEntity(robots[client][0]))
	{
		botenergy[client] = botenergy[client] - duration * 0.5;
		if (botenergy[client] < 0.0)
		{
			botenergy[client] = 0.0;
		}
	}
}

public void OnGameFrame()
{
	if (!gamestart) return;
	
	float currenttime = GetEngineTime();
	float duration = currenttime - lasttime;
	if (duration < 0.0 || duration > 1.0)
	{ duration = 0.0; }
	for (int client = 1; client <= MaxClients; client++)
	{
		Do(client, currenttime, duration);
	}
	lasttime = currenttime;
	return;
}

int ScanCommon(int client, float rpos[3])
{
	float infectedpos[3], vec[3], angle[3];
 	int find = 0;
	float mindis = 100000.0, dis = 0.0;
	for (int i = MaxClients+1; i <= GetMaxEntities(); i++)
	{
		if (!RealValidEntity(i)) continue;
		static char classname[9];
		GetEntityClassname(i, classname, sizeof(classname));
		if (strcmp(classname, "infected", false) != 0) continue;
		
		int health = GetEntProp(i, Prop_Data, "m_iHealth");
		if (health <= 0) continue;
		
		GetEntPropVector(i, Prop_Data, "m_vecOrigin", infectedpos);	
		//infectedpos[2] += 40.0;
		dis = GetVectorDistance(rpos, infectedpos);
		//PrintToChatAll("%f %N" ,dis, i);
		if (dis < robot_scanrange && dis <= mindis)
		{
			SubtractVectors(infectedpos, rpos, vec);
			GetVectorAngles(vec, angle);
			TR_TraceRayFilter(infectedpos, rpos, MASK_SOLID, RayType_EndPoint, TraceRayDontHitSelfAndLive, robots[client][0]);
		
			if (!TR_DidHit())
			{
				find = i;
				mindis = dis;
				return find;
			}
		}
	}
 
	return find;
}

int ScanEnemy(int client, float rpos[3])
{
	float infectedpos[3], vec[3], angle[3];
 	int find = 0;
	float mindis = 100000.0, dis = 0.0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) == 3 && IsPlayerAlive(i))
		{
			GetClientEyePosition(i, infectedpos);
			SubtractVectors(infectedpos, rpos, vec);
			GetVectorAngles(vec, angle);
			dis = GetVectorDistance(rpos, infectedpos);
			
			if (dis < robot_scanrange && dis <= mindis)
			{
				// Check if we have line of sight using calculated angles
				Handle trace = TR_TraceRayFilterEx(rpos, angle, MASK_SHOT, RayType_Infinite, TraceFilter, client);
				if (!TR_DidHit(trace))
				{
					mindis = dis;
					find = i;
				}
				delete trace;
			}
		}
	}
 
	return find;
}

bool TraceRayDontHitSelfAndLive(int entity, int mask, any data)
{
	if (entity == data) 
	{
		return false; 
	}
	else if (IsValidClient(entity))
	{
		return false;
	}
	else if (RealValidEntity(entity))
	{
		static char classname[9];
		GetEntityClassname(entity, classname, sizeof(classname));
		if (strcmp(classname, "infected", false) == 0)
		{
			return false;
		}
	}
	return true;
}

bool TraceRayDontHitSelfAndSurvivor(int entity, int mask, any data)
{
	if (entity == data) 
	{
		return false; 
	}
	else if (IsValidClient(entity) && (GetClientTeam(entity) == 2 || GetClientTeam(entity) == 4))
	{
		return false;
	}
	return true;
}

bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return (entity > MaxClients || !entity);
}

bool IsValidClient(int client, bool replaycheck = true)
{
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	if (replaycheck)
	{
		if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
	}
	return true;
}

bool RealValidEntity(int entity)
{
	if (entity <= 0 || !IsValidEntity(entity)) return false;
	return true;
}

public void OnClientDisconnect(int client)
{
    for (int i = 0; i < MAX_ROBOTS_PER_PLAYER; i++)
    {
        Release(client, i);
    }
}

void FireBullet(int client, int robotIndex, float infectedpos[3], float botorigin[3])
{
    if (!IsValidClient(client) || !IsValidEntity(robots[client][robotIndex]))
        return;
        
    float vAngles[3], vAngles2[3], pos[3];
    
    SubtractVectors(infectedpos, botorigin, infectedpos);
    GetVectorAngles(infectedpos, vAngles);
     
    float arr1, arr2;
    arr1 = 0.0 - bulletaccuracy[weapontypes[client][robotIndex]];    
    arr2 = bulletaccuracy[weapontypes[client][robotIndex]];
    
    float v1[3], v2[3];
    
    for (int c = 0; c < weaponbulletpershot[weapontypes[client][robotIndex]]; c++)
    {
        vAngles2[0] = vAngles[0] + GetRandomFloat(arr1, arr2);    
        vAngles2[1] = vAngles[1] + GetRandomFloat(arr1, arr2);    
        vAngles2[2] = vAngles[2] + GetRandomFloat(arr1, arr2);
        
        int hittarget = 0;
        TR_TraceRayFilter(botorigin, vAngles2, MASK_SOLID, RayType_Infinite, TraceRayDontHitSelfAndSurvivor, robots[client][robotIndex]);
        
        if (TR_DidHit())
        {
            TR_GetEndPosition(pos);
            hittarget = TR_GetEntityIndex();
            
            float Direction[3];
            Direction[0] = GetRandomFloat(-1.0, 1.0);
            Direction[1] = GetRandomFloat(-1.0, 1.0);
            Direction[2] = GetRandomFloat(-1.0, 1.0);
            TE_SetupSparks(pos, Direction, 1, 3);
            TE_SendToAll();
        }

        if (hittarget > 0)        
        {
            SDKHooks_TakeDamage(hittarget, robots[client][robotIndex], client, StringToFloat(weaponbulletdamagestr[weapontypes[client][robotIndex]]), DMG_BULLET, -1, NULL_VECTOR, NULL_VECTOR);
        }
        
        SubtractVectors(botorigin, pos, v1);
        NormalizeVector(v1, v2);    
        ScaleVector(v2, 36.0);
        float bulletOrigin[3];
        SubtractVectors(botorigin, v2, bulletOrigin);
     
        int color[4];
        color[0] = 200; 
        color[1] = 200;
        color[2] = 200;
        color[3] = 230;
        
        float life = 0.06, width1 = 0.01, width2 = 0.3;        
        if (L4D2Version)
            width2 = 0.08;
  
        TE_SetupBeamPoints(bulletOrigin, pos, g_sprite, 0, 0, 0, life, width1, width2, 1, 0.0, color, 0);
        TE_SendToAll();
 
        EmitSoundToAll(SOUND[weapontypes[client][robotIndex]], robots[client][robotIndex], SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, botorigin, NULL_VECTOR, false, 0.0);
    }
    
    firetime[client][robotIndex] = GetGameTime();
}

public bool TraceFilter(int entity, int contentsMask, any data)
{
	if (entity == data || (entity >= 1 && entity <= MaxClients))
		return false;
	return true;
}