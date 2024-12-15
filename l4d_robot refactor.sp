//TODO: implement plans and code refactor to ALLOW UNLIMITED ROBOT GUNS PER PLAYER/CLIENT, comment out any ROBOT limiting code
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

#define MODEL_PATH0 "models/w_models/weapons/w_sniper_mini14.mdl"
#define MODEL_PATH1 "models/w_models/weapons/w_rifle_m16a2.mdl"
#define MODEL_PATH2 "models/w_models/weapons/w_autoshot_m4super.mdl"
#define MODEL_PATH3 "models/w_models/weapons/w_shotgun.mdl"
#define MODEL_PATH4 "models/w_models/weapons/w_smg_uzi.mdl"
#define MODEL_PATH5 "models/w_models/weapons/w_pistol_a.mdl"
#define MODEL_PATH6 "models/w_models/weapons/w_desert_eagle.mdl"
#define MODEL_PATH7 "models/w_models/weapons/w_rifle_ak47.mdl"
#define MODEL_PATH8 "models/w_models/weapons/w_desert_rifle.mdl"
#define MODEL_PATH9 "models/w_models/weapons/w_rifle_sg552.mdl"
#define MODEL_PATH10 "models/w_models/weapons/w_m60.mdl"
#define MODEL_PATH11 "models/w_models/weapons/w_pumpshotgun_a.mdl"
#define MODEL_PATH12 "models/w_models/weapons/w_shotgun_spas.mdl"
#define MODEL_PATH13 "models/w_models/weapons/w_sniper_military.mdl"
#define MODEL_PATH14 "models/w_models/weapons/w_sniper_scout.mdl"
#define MODEL_PATH15 "models/w_models/weapons/w_sniper_awp.mdl"
#define MODEL_PATH16 "models/w_models/weapons/w_smg_mp5.mdl"
#define MODEL_PATH17 "models/w_models/weapons/w_smg_a.mdl"

static char SOUND[WEAPONCOUNT+3][70]=
{												SOUND0,	SOUND1,	SOUND2,	SOUND3,	SOUND4,	SOUND5,	SOUND6,	SOUND7,	SOUND8,	SOUND9,	SOUND10,SOUND11,SOUND12,SOUND13,SOUND14,SOUND15,SOUND16,SOUND17,SOUNDCLIPEMPTY,	SOUNDRELOAD,	SOUNDREADY};

static char MODEL[WEAPONCOUNT][32]=
{												MODEL0,	MODEL1,	MODEL2,	MODEL3,	MODEL4,	MODEL5,	MODEL6,	MODEL7,	MODEL8,	MODEL9,	MODEL10,MODEL11,MODEL12,MODEL13,MODEL14,MODEL15,MODEL16,MODEL17};

static char MODEL_PATHS[WEAPONCOUNT][64]=
{												MODEL_PATH0,	MODEL_PATH1,	MODEL_PATH2,	MODEL_PATH3,	MODEL_PATH4,	MODEL_PATH5,	MODEL_PATH6,	MODEL_PATH7,	MODEL_PATH8,	MODEL_PATH9,	MODEL_PATH10,MODEL_PATH11,MODEL_PATH12,MODEL_PATH13,MODEL_PATH14,MODEL_PATH15,MODEL_PATH16,MODEL_PATH17};

static char weaponbulletdamagestr[WEAPONCOUNT][10]={"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""};

//weapon data
// Removed unused legacy weapon arrays since we now use WeaponInfo struct

static int robot[MAXPLAYERS+1];
static int keybuffer[MAXPLAYERS+1];
static int weapontype[MAXPLAYERS+1];
static int bullet[MAXPLAYERS+1];
static float firetime[MAXPLAYERS+1];
static bool reloading[MAXPLAYERS+1];
static float reloadtime[MAXPLAYERS+1];
static float scantime[MAXPLAYERS+1];
static float walktime[MAXPLAYERS+1];
static float botenergy[MAXPLAYERS+1];

static int SIenemy[MAXPLAYERS+1];
static int CIenemy[MAXPLAYERS+1];
//static float CIenemyTime[MAXPLAYERS+1];

static float robotangle[MAXPLAYERS+1][3];

// ConVar Handles
static ConVar g_cvRobotLimit;
static ConVar g_cvReactionTime;
static ConVar g_cvScanRange;
static ConVar g_cvEnergy;
static ConVar g_cvDamageFactor;
static ConVar g_cvMessages;
static ConVar g_cvGlowColor;

// Global Variables
static bool g_bL4D2Version = false;
static int g_iGameMode = 0;
static bool g_bGameStarted = false;
static int g_iLaserSprite = 0;

// Message Flags
#define ROBOT_MESSAGE_INFO      (1 << 0)
#define ROBOT_MESSAGE_STEAL     (1 << 1)

static float g_fReactionTime;
static float g_fScanRange; 
static float g_fEnergy;
static float g_fDamageFactor;
static int g_iMessages;
static char g_szGlowColor[12];

// Weapon Types
/**
 * Enumerates all available weapon types that can be used by robots
 */
enum WeaponType
{
    WEAPON_HUNTING_RIFLE = 0,    // Hunting Rifle (L4D1 & L4D2)
    WEAPON_RIFLE,               // M16 Assault Rifle
    WEAPON_AUTO_SHOTGUN,        // Auto Shotgun
    WEAPON_PUMP_SHOTGUN,        // Pump Shotgun
    WEAPON_SMG,                 // Submachine Gun
    WEAPON_PISTOL,              // Pistol
    WEAPON_MAGNUM,              // Magnum (L4D2 only)
    WEAPON_AK47,               // AK47 (L4D2 only)
    WEAPON_DESERT_RIFLE,        // Desert Rifle (L4D2 only)
    WEAPON_SG552,              // SG552 (L4D2 only)
    WEAPON_M60,                // M60 (L4D2 only)
    WEAPON_CHROME_SHOTGUN,      // Chrome Shotgun (L4D2 only)
    WEAPON_SPAS_SHOTGUN,        // SPAS Shotgun (L4D2 only)
    WEAPON_SNIPER_MILITARY,     // Military Sniper (L4D2 only)
    WEAPON_SCOUT,              // Scout Sniper (L4D2 only)
    WEAPON_AWP,                // AWP Sniper (L4D2 only)
    WEAPON_MP5,                // MP5 (L4D2 only)
    WEAPON_SILENCED_SMG,        // Silenced SMG (L4D2 only)
    WEAPON_MAX
}

// Weapon Configuration
/**
 * Stores configuration data for each weapon type
 */
enum struct WeaponInfo
{
    char model[32];             // Weapon model path
    char sound[70];            // Firing sound path
    float fireInterval;        // Time between shots
    float bulletAccuracy;      // Bullet spread (lower = more accurate)
    float bulletDamage;        // Base damage per bullet
    int clipSize;             // Magazine capacity
    int bulletsPerShot;       // Number of pellets per shot (e.g., for shotguns)
    float loadTime;           // Time to reload one unit
    int loadCount;            // Number of bullets loaded per reload action
    bool loadDisrupt;         // Whether reloading can be interrupted
}

// Global weapon configurations
static WeaponInfo g_WeaponInfo[WEAPONCOUNT];

/**
 * Initializes weapon configurations with default values
 * Called during plugin start to set up all weapon properties
 */
void InitializeWeaponConfigurations()
{
    // Initialize each weapon with its specific properties
    InitializeWeapon(WEAPON_HUNTING_RIFLE, MODEL_PATH0, SOUND0, 0.25, 1.15, 90.0, 15, 1, 2.0, 15, false);
    InitializeWeapon(WEAPON_RIFLE, MODEL_PATH1, SOUND1, 0.068, 1.4, 30.0, 50, 1, 1.5, 50, false);
    InitializeWeapon(WEAPON_AUTO_SHOTGUN, MODEL_PATH2, SOUND2, 0.30, 3.5, 25.0, 10, 7, 0.3, 1, true);
    InitializeWeapon(WEAPON_PUMP_SHOTGUN, MODEL_PATH3, SOUND3, 0.65, 3.5, 30.0, 8, 7, 0.3, 1, true);
    InitializeWeapon(WEAPON_SMG, MODEL_PATH4, SOUND4, 0.060, 1.6, 20.0, 50, 1, 1.5, 50, false);
    InitializeWeapon(WEAPON_PISTOL, MODEL_PATH5, SOUND5, 0.20, 1.7, 30.0, 30, 1, 1.5, 30, false);
    InitializeWeapon(WEAPON_MAGNUM, MODEL_PATH6, SOUND6, 0.33, 1.7, 60.0, 8, 1, 1.9, 8, false);
    InitializeWeapon(WEAPON_AK47, MODEL_PATH7, SOUND7, 0.145, 1.5, 70.0, 40, 1, 1.5, 40, false);
    InitializeWeapon(WEAPON_DESERT_RIFLE, MODEL_PATH8, SOUND8, 0.14, 1.6, 40.0, 20, 1, 1.5, 20, false);
    InitializeWeapon(WEAPON_SG552, MODEL_PATH9, SOUND9, 0.14, 1.5, 40.0, 50, 1, 1.6, 50, true);
    InitializeWeapon(WEAPON_M60, MODEL_PATH10, SOUND10, 0.068, 1.5, 50.0, 150, 1, 0.0, 1, true);
    InitializeWeapon(WEAPON_CHROME_SHOTGUN, MODEL_PATH11, SOUND11, 0.65, 3.5, 30.0, 8, 7, 0.3, 1, true);
    InitializeWeapon(WEAPON_SPAS_SHOTGUN, MODEL_PATH12, SOUND12, 0.30, 3.5, 30.0, 10, 7, 0.3, 1, false);
    InitializeWeapon(WEAPON_SNIPER_MILITARY, MODEL_PATH13, SOUND13, 0.265, 1.15, 90.0, 30, 1, 2.0, 30, false);
    InitializeWeapon(WEAPON_SCOUT, MODEL_PATH14, SOUND14, 0.9, 1.00, 100.0, 15, 1, 2.0, 15, false);
    InitializeWeapon(WEAPON_AWP, MODEL_PATH15, SOUND15, 1.25, 0.8, 150.0, 20, 1, 2.0, 20, false);
    InitializeWeapon(WEAPON_MP5, MODEL_PATH16, SOUND16, 0.065, 1.6, 35.0, 50, 1, 1.5, 50, false);
    InitializeWeapon(WEAPON_SILENCED_SMG, MODEL_PATH17, SOUND17, 0.055, 1.6, 35.0, 50, 1, 1.5, 50, false);
}

/**
 * Helper function to initialize a single weapon's configuration
 *
 * @param type            Weapon type to initialize
 * @param model          Model path for the weapon
 * @param sound          Sound path for weapon firing
 * @param fireInterval   Time between shots
 * @param accuracy       Bullet spread (lower = more accurate)
 * @param damage         Base damage per bullet
 * @param clipSize       Magazine capacity
 * @param bulletsPerShot Number of pellets per shot
 * @param loadTime       Time to reload one unit
 * @param loadCount      Number of bullets loaded per reload
 * @param loadDisrupt    Whether reloading can be interrupted
 */
void InitializeWeapon(WeaponType type, const char[] model, const char[] sound, 
    float fireInterval, float accuracy, float damage, int clipSize, 
    int bulletsPerShot, float loadTime, int loadCount, bool loadDisrupt)
{
    strcopy(g_WeaponInfo[type].model, sizeof(WeaponInfo::model), model);
    strcopy(g_WeaponInfo[type].sound, sizeof(WeaponInfo::sound), sound);
    g_WeaponInfo[type].fireInterval = fireInterval;
    g_WeaponInfo[type].bulletAccuracy = accuracy;
    g_WeaponInfo[type].bulletDamage = damage;
    g_WeaponInfo[type].clipSize = clipSize;
    g_WeaponInfo[type].bulletsPerShot = bulletsPerShot;
    g_WeaponInfo[type].loadTime = loadTime;
    g_WeaponInfo[type].loadCount = loadCount;
    g_WeaponInfo[type].loadDisrupt = loadDisrupt;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() == Engine_Left4Dead2)
	{
		g_bL4D2Version = true;
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
	g_cvRobotLimit = CreateConVar(
		"l4d_robot_limit", "2",
		"Number of Robots [0-3]",
		FCVAR_NONE
	);
	
	g_cvReactionTime = CreateConVar(
		"l4d_robot_reactiontime", "2.0",
		"Robot reaction time [0.5, 5.0]",
		FCVAR_NONE
	);
	
	g_cvScanRange = CreateConVar(
		"l4d_robot_scanrange", "600.0",
		"Scan enemy range [100.0, 10000.0]",
		FCVAR_NONE
	);
 	
	g_cvEnergy = CreateConVar(
		"l4d_robot_energy", "5.0",
		"Time limit of a robot for a player (minutes) [0.0, 100.0]",
		FCVAR_NONE
	);
	
	g_cvDamageFactor = CreateConVar(
		"l4d_robot_damagefactor", "0.5",
		"Damage factor [0.2, 1.0]",
		FCVAR_NONE
	);
	
	g_cvMessages = CreateConVar(
		"l4d_robot_messages", "3",
		"Which messages to enable, as bitflags [1 = Info, 2 = Steal]",
		FCVAR_NONE
	);
	
	g_cvGlowColor = CreateConVar(
		"l4d_robot_glow", "0 127 127",
		"The glow color to use for robots [R, G, B]",
		FCVAR_NONE
	);

	g_cvReactionTime.AddChangeHook(OnConVarChanged);
	g_cvScanRange.AddChangeHook(OnConVarChanged);
	g_cvEnergy.AddChangeHook(OnConVarChanged);
	g_cvDamageFactor.AddChangeHook(OnConVarChanged);
	g_cvMessages.AddChangeHook(OnConVarChanged);
	g_cvGlowColor.AddChangeHook(OnConVarChanged);

	AutoExecConfig(true, "l4d_robot_12");
	
	static char GameName[13];
	GetConVarString(FindConVar("mp_gamemode"), GameName, sizeof(GameName));
	
	if (strncmp(GameName, "survival", 8, false) == 0)
		g_iGameMode = 3;
	else if (strncmp(GameName, "versus", 6, false) == 0 || strncmp(GameName, "teamversus", 10, false) == 0 || strncmp(GameName, "scavenge", 8, false) == 0 || strcmp(GameName, "teamscavenge", false) == 0)
		g_iGameMode = 2;
	else if (strncmp(GameName, "coop", 4, false) == 0 || strncmp(GameName, "realism", 7, false) == 0)
		g_iGameMode = 1;
	else
		g_iGameMode = 0;
 
 	RegConsoleCmd("sm_robot", sm_robot);
	//HookEvent("player_use", player_use, EventHookMode_Post);
	HookEvent("round_start", RoundStart, EventHookMode_Post);
	//HookEvent("map_transition", map_transition, EventHookMode_PostNoCopy);
	
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
	
	HookEvent("round_end", RoundEnd, EventHookMode_Post);
	HookEvent("finale_win", RoundEnd, EventHookMode_Post);
	HookEvent("mission_lost", RoundEnd, EventHookMode_Post);
	HookEvent("map_transition", RoundEnd, EventHookMode_Post);
	HookEvent("player_spawn", Event_Spawn, EventHookMode_Post);	 
 	g_bGameStarted = false;
    InitializeWeaponConfigurations();
}

public void OnPluginEnd()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (RealValidEntity(robot[i]))
		{
			Release(i);	 
 		}
	}
}

void GetConVar()
{
	g_fReactionTime = GetConVarFloat(g_cvReactionTime );
	g_fScanRange = GetConVarFloat(g_cvScanRange );
 	g_fEnergy = GetConVarFloat(g_cvEnergy ) * 60.0;
 	g_fDamageFactor = GetConVarFloat(g_cvDamageFactor);
	g_iMessages = GetConVarInt(g_cvMessages);
	GetConVarString(g_cvGlowColor, g_szGlowColor, sizeof(g_szGlowColor));
	for (int i = 0; i < WEAPONCOUNT; i++)
	{
		static char str[10];
		Format(str, sizeof(str), "%d", RoundFloat(g_WeaponInfo[i].bulletDamage * g_fDamageFactor));
		weaponbulletdamagestr[i] = str;
	}
}

void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetConVar();
}

public void OnMapStart()
{
    for (int i = 0; i < WEAPONCOUNT; i++)
    {
        PrecacheModel(MODEL_PATHS[i], true);
    }
    
    PrecacheSound(SOUND[0], true);
    PrecacheSound(SOUND[1], true);
    PrecacheSound(SOUND[2], true);
    PrecacheSound(SOUND[3], true);
    PrecacheSound(SOUND[4], true);
    PrecacheSound(SOUND[5], true);
	
	PrecacheSound(SOUNDCLIPEMPTY, true);
	PrecacheSound(SOUNDRELOAD, true);
	PrecacheSound(SOUNDREADY, true);
	
	if (g_bL4D2Version)
	{
		g_iLaserSprite = PrecacheModel("materials/sprites/laserbeam.vmt");	
		
		for (int i = 6; i < WEAPONCOUNT; i++)
		{
			PrecacheSound(g_WeaponInfo[i].sound, true) ;
		}
	}
	else
	{
		g_iLaserSprite = PrecacheModel("materials/sprites/laser.vmt");	
 
	}
	g_bGameStarted = false;
}

void RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (RealValidEntity(robot[i]))
		{
			Release(i, false);	 
 		}
		botenergy[i] = 0.0;
	}
	//g_PointHurt = 0;
}

void RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (RealValidEntity(robot[i]))
		{
			Release(i);	 
 		}
	}
	g_bGameStarted = false;
}
/*void player_use(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int entity = GetEventInt(event, "targetid");
	for (int i = 1; i <= MaxClients; i++)
	{
		if (RealValidEntity(robot[i]) && robot[i] == entity)
		{
			//RemovePlayerItem(client, entity);
			if (client == i && (g_iMessages & ROBOT_MESSAGE_INFO))
			{
				PrintHintText(client, "Press WALK+USE to turn your robot off", client);
			}
			else
			{
				if (g_iMessages & ROBOT_MESSAGE_STEAL)
				{
					PrintHintText(i, "%N tried to steal your robot", client);
					PrintHintText(client, "You tried to steal %N's robot", i);
				}
				if (RealValidEntity(GetEntPropEnt(robot[i], Prop_Data, "m_hOwnerEntity")))
				{
					Release(i);	
					AddRobot(i);
				}
			}
 		}
		else if (robot[i] > 0)
		{
			Release(i);	
			AddRobot(i);
		}
	}
}*/
/*void Output_OnUse(const char[] output, int entity, int client, float delay)
{
	
}*/
void Event_Spawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	robot[client] = 0;
}

void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bGameStarted) return;
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
	
	/*static char item[7];
	GetEntityClassname(ent, item, sizeof(item));
	if (strcmp(item, "weapon") == 0)
	{*/
	AcceptEntityInput(ent, "Kill");
	//}
}

void Release(int controller, bool del = true)
{
	int r = robot[controller];
	if (RealValidEntity(r))
	{
		robot[controller] = 0;
	 
		if (del) DelRobot(r);
	}
	if (g_bGameStarted)
	{
		int count = 0;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (RealValidEntity(robot[i]))
			{
				count++; 
			}
		}
		if (count == 0) g_bGameStarted = false;
	}
}

Action sm_robot(int client, int args)
{  
	if (g_iGameMode == 2) return Plugin_Handled;
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Handled;
	if (RealValidEntity(robot[client]))
	{
		PrintToChat(client, "You already have a robot! Press WALK+USE to remove the old one.");
		return Plugin_Handled;
	}
	
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (RealValidEntity(robot[i]))
		{
			count++; 
 		}
	}
	
	if (count + 1 > GetConVarInt(g_cvRobotLimit))
	{
		PrintToChat(client, "No more robots to use!");
		return Plugin_Handled;
	}

	if (args >= 1)
	{
		static char arg[24];
		GetCmdArg(1, arg, sizeof(arg));
		if (strncmp(arg, "hunting", 7, false) == 0) weapontype[client]=0;
		else if (strncmp(arg, "rifle", 5, false) == 0) weapontype[client]=1;
		else if (strncmp(arg, "auto", 4, false) == 0) weapontype[client]=2;
		else if (strncmp(arg, "pump", 4, false) == 0) weapontype[client]=3;
		else if (strncmp(arg, "smg", 3, false) == 0) weapontype[client]=4;
		else if (strncmp(arg, "pistol", 6, false) == 0) weapontype[client]=5;
		else if (strncmp(arg, "magnum", 6, false) == 0 && g_bL4D2Version) weapontype[client]=6;
		else if (strncmp(arg, "ak47", 4, false) == 0 && g_bL4D2Version) weapontype[client]=7;
		else if (strncmp(arg, "desert", 6, false) == 0 && g_bL4D2Version) weapontype[client]=8;
		else if (strncmp(arg, "sg552", 5, false) == 0 && g_bL4D2Version) weapontype[client]=9;
		else if (strncmp(arg, "m60", 3, false) == 0 && g_bL4D2Version) weapontype[client]=10;
		else if (strncmp(arg, "chrome", 6, false) == 0 && g_bL4D2Version) weapontype[client]=11;
		else if (strncmp(arg, "spas", 4, false) == 0 && g_bL4D2Version) weapontype[client]=12;
		else if (strncmp(arg, "military", 8, false) == 0 && g_bL4D2Version) weapontype[client]=13;
		else if (strncmp(arg, "scout", 5, false) == 0 && g_bL4D2Version) weapontype[client]=14;
		else if (strncmp(arg, "awp", 3, false) == 0 && g_bL4D2Version) weapontype[client]=15;
		else if (strncmp(arg, "mp5", 3, false) == 0 && g_bL4D2Version) weapontype[client]=16;
		else if (strncmp(arg, "silenced", 8, false) == 0 && g_bL4D2Version) weapontype[client]=17;
		else
		{
			if (g_bL4D2Version)
			{ weapontype[client] = GetRandomInt(0, WEAPONCOUNT-1); }
			else
			{ weapontype[client] = GetRandomInt(0, 5); }
		}
	}	
	else
	{
		if (g_bL4D2Version)
		{ weapontype[client] = GetRandomInt(0, WEAPONCOUNT-1); }
		else
		{ weapontype[client] = GetRandomInt(0, 5); }
	}
	AddRobot(client, true);
	return Plugin_Handled;
} 
void AddRobot(int client, bool showmsg = false)
{
	bullet[client] = g_WeaponInfo[weapontype[client]].clipSize;
	float vAngles[3], vOrigin[3], pos[3];

	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);

	TR_TraceRayFilter(vOrigin, vAngles, MASK_SOLID,  RayType_Infinite, TraceEntityFilterPlayer, robot[client]);

	if (TR_DidHit())
	{
		TR_GetEndPosition(pos);
	}

	float v1[3], v2[3];
	 
	SubtractVectors(vOrigin, pos, v1);
	NormalizeVector(v1, v2);

	ScaleVector(v2, 50.0);

	AddVectors(pos, v2, v1);  // v1 explode taget
	
	int temp_ent = CreateEntityByName(MODEL[weapontype[client]]);
	if (!RealValidEntity(temp_ent)) return;
	DispatchSpawn(temp_ent);
	
	int ent = CreateEntityByName("prop_dynamic_override");
	//int ent = CreateEntityByName("prop_physics_override");
	//DispatchKeyValue(ent, "spawnflags", "4");
	DispatchKeyValue(ent, "solid", "6");
	DispatchKeyValue(ent, "model", MODEL_PATHS[weapontype[client]]);
	DispatchKeyValue(ent, "glowcolor", g_szGlowColor);
	DispatchKeyValue(ent, "glowstate", "2");
	//DispatchKeyValue(ent, "targetname", MODEL[weapontype[client]]);
	DispatchSpawn(ent);
	TeleportEntity(ent, v1, NULL_VECTOR, NULL_VECTOR);
	
	SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1);
	SetEntityMoveType(ent, MOVETYPE_FLY);
	
	SetVariantString("idle");
	AcceptEntityInput(ent, "SetAnimation");
	SetVariantString("idle");
	AcceptEntityInput(ent, "SetDefaultAnimation");
	// Setting the robots to do the idle animation is vital for them to actually move
	
	SIenemy[client] = 0;
	CIenemy[client] = 0;
	scantime[client] = 0.0;
	keybuffer[client] = 0;
	bullet[client] = 0;
	reloading[client] = false;
	reloadtime[client] = 0.0;
	firetime[client] = 0.0;
	robot[client] = ent;
	if (showmsg && (g_iMessages & ROBOT_MESSAGE_INFO))
	{
		PrintHintText(client, "You have spawned a robot. Press WALK+USE to remove it anytime.");
		PrintToChatAll("\x04%N\x03 turned on their robot.", client);
	}
	
	//SetVariantString("function InputUse() {return false}");
	//AcceptEntityInput(ent, "RunScriptCode");
	
	//HookSingleEntityOutput(ent, "OnUsed", Output_OnUse);
	
	g_bGameStarted = true;
}

static float lasttime=0.0;

static int button;

static float robotpos[3], robotvec[3];

static float clienteyepos[3];

static float clientangle[3], enemypos[3], infectedorigin[3], infectedeyepos[3];
 
static float chargetime;

void Do(int client, float currenttime, float duration)
{
	if (RealValidEntity(robot[client]))
	{
		if (IsFakeClient(client) || !IsValidClient(client) || !IsPlayerAlive(client))
		{
			Release(client);
		}
		else  
		{			
			botenergy[client] += duration;
			if (g_fEnergy > -1.0 && botenergy[client] > g_fEnergy)
			{
				Release(client);
				PrintHintText(client, "Your bot energy is not enough.");
				return;
			}
			
			button = GetClientButtons(client);
 		 	GetEntPropVector(robot[client], Prop_Send, "m_vecOrigin", robotpos);	
	 		 
			if ((button & IN_USE) && (button & IN_SPEED) && !(keybuffer[client] & IN_USE))
			{
				Release(client);
				if (g_iMessages & ROBOT_MESSAGE_INFO)
				{ PrintToChatAll("\x04%N\x03 turned off their robot.", client); }
				return;
			}
			if (currenttime - scantime[client] > g_fReactionTime)
			{
				scantime[client] = currenttime;
				SIenemy[client] = ScanEnemy(client, robotpos);
				#if ORIGINAL_PAN
					CIenemy[client] = 0;
				#else
					CIenemy[client] = ScanCommon(client, robotpos);
				#endif
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
			if (reloading[client])
			{
				//PrintToChatAll("%f", reloadtime[client]);
				if (bullet[client] >= g_WeaponInfo[weapontype[client]].clipSize && currenttime - reloadtime[client] > g_WeaponInfo[weapontype[client]].loadTime)
				{
					reloading[client] = false;	
					reloadtime[client] = currenttime;
					EmitSoundToAll(SOUNDREADY, 0, SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, robotpos, NULL_VECTOR, false, 0.0);
					//PrintHintText(client, " ");
				}
				else if (currenttime - reloadtime[client] > g_WeaponInfo[weapontype[client]].loadTime)
				{
					reloadtime[client] = currenttime;
					bullet[client] += g_WeaponInfo[weapontype[client]].loadCount;
					EmitSoundToAll(SOUNDRELOAD, 0, SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, robotpos, NULL_VECTOR, false, 0.0);
					//PrintHintText(client, "Reloading %d", bullet[client]);
				}
			}
			if (!reloading[client])
			{
				if (!targetok) 
				{
					if (bullet[client] < g_WeaponInfo[weapontype[client]].clipSize)					
					{
						reloading[client] = true;	
						reloadtime[client] = 0.0;
						if (!g_WeaponInfo[weapontype[client]].loadDisrupt)
						{
							bullet[client] = 0;
						}
					}
				}	
			}
			chargetime = g_WeaponInfo[weapontype[client]].fireInterval;
			 
			if (!reloading[client])
			{
				if (currenttime - firetime[client] > chargetime)
				{
					if (targetok) 
					{
						if (bullet[client] > 0)
						{
							bullet[client] = bullet[client] - 1;
							
							FireBullet(client, robot[client], enemypos, robotpos);
						 
							firetime[client] = currenttime;	
						 	reloading[client] = false;
						}
						else
						{
							firetime[client] = currenttime;
						 	EmitSoundToAll(SOUNDCLIPEMPTY, 0, SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, robotpos, NULL_VECTOR, false, 0.0);
							reloading[client] = true;	
							reloadtime[client] = currenttime;
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
				TeleportEntity(robot[client], clienteyepos, robotangle[client], NULL_VECTOR);
			}
			else if (distance > 100.0)		
			{
				MakeVectorFromPoints( robotpos, clienteyepos, robotvec);
				NormalizeVector(robotvec,robotvec);
				ScaleVector(robotvec, 5*distance);
				if (!targetok )
				{
					GetVectorAngles(robotvec, robotangle[client]);
				}
				TeleportEntity(robot[client], NULL_VECTOR, robotangle[client] ,robotvec);
				walktime[client]=currenttime;
			}
			else 
			{
				robotvec[0] = robotvec[1] = robotvec[2] = 0.0;
				if (!targetok && currenttime-firetime[client] > 4.0 && currenttime-walktime[client] > 1.0 )
				{ robotangle[client][1] += 5.0; }
				TeleportEntity(robot[client], NULL_VECTOR, robotangle[client], robotvec);
			}
		 	keybuffer[client] = button;
		}
	}
	else 
	{
		botenergy[client] = botenergy[client] - duration * 0.5;
		if (botenergy[client] < 0.0)
			botenergy[client] = 0.0;
	}
}
public void OnGameFrame()
{
	if (!g_bGameStarted) return;
	
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
#if !ORIGINAL_PAN
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
		if (dis < g_fScanRange && dis <= mindis)
		{
			SubtractVectors(infectedpos, rpos, vec);
			GetVectorAngles(vec, angle);
			TR_TraceRayFilter(infectedpos, rpos, MASK_SOLID, RayType_EndPoint, TraceRayDontHitSelfAndLive, robot[client]);
		
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
#endif
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
			dis = GetVectorDistance(rpos, infectedpos);
			//PrintToChatAll("%f %N" ,dis, i);
			if (dis < g_fScanRange && dis <= mindis)
			{
				SubtractVectors(infectedpos, rpos, vec);
				GetVectorAngles(vec, angle);
				TR_TraceRayFilter(infectedpos, rpos, MASK_SOLID, RayType_EndPoint, TraceRayDontHitSelfAndLive, robot[client]);
			
				if (!TR_DidHit())
				{
					find = i;
					mindis = dis;
					return find;
				}
			}
		}
	}
 
	return find;
}
void FireBullet(int controller, int bot, float infectedpos[3], float botorigin[3])
{
	float vAngles[3], vAngles2[3], pos[3];
	
	SubtractVectors(infectedpos, botorigin, infectedpos);
	GetVectorAngles(infectedpos, vAngles);
	 
	float arr1, arr2;
	arr1 = 0.0 - g_WeaponInfo[weapontype[controller]].bulletAccuracy;	
	arr2 = g_WeaponInfo[weapontype[controller]].bulletAccuracy;
	
	float v1[3], v2[3];
	//PrintToChatAll("%f %f",arr1, arr2);
	for (int c = 0; c < g_WeaponInfo[weapontype[controller]].bulletsPerShot; c++)
	{
		//PrintToChatAll("fire");
		vAngles2[0] = vAngles[0] + GetRandomFloat(arr1, arr2);	
		vAngles2[1] = vAngles[1] + GetRandomFloat(arr1, arr2);	
		vAngles2[2] = vAngles[2] + GetRandomFloat(arr1, arr2);
		
		int hittarget = 0;
		TR_TraceRayFilter(botorigin, vAngles2, MASK_SOLID, RayType_Infinite, TraceRayDontHitSelfAndSurvivor, bot);
		
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
			DoDamage(weapontype[controller], hittarget, controller);
		}
		
		SubtractVectors(botorigin, pos, v1);
		NormalizeVector(v1, v2);	
		ScaleVector(v2, 36.0);
		SubtractVectors(botorigin, v2, infectedorigin);
	 
		int color[4];
		color[0] = 200; 
		color[1] = 200;
		color[2] = 200;
		color[3] = 230;
		
		float life = 0.06, width1 = 0.01, width2 = 0.3;		
		if (g_bL4D2Version)
			width2 = 0.08;
  
		TE_SetupBeamPoints(infectedorigin, pos, g_iLaserSprite, 0, 0, 0, life, width1, width2, 1, 0.0, color, 0);
		TE_SendToAll();
 
		//EmitAmbientSound(SOUND[weapontype[controller]], vOrigin, controller, SNDLEVEL_RAIDSIREN);
		EmitSoundToAll(g_WeaponInfo[weapontype[controller]].sound, 0, SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, botorigin, NULL_VECTOR, false, 0.0);
	}
}

/*CreatePointHurt()
{
	new pointHurt=CreateEntityByName("point_hurt");
	if (pointHurt)
	{

		DispatchKeyValue(pointHurt,"Damage","10");
		DispatchKeyValue(pointHurt,"DamageType","2");
		DispatchSpawn(pointHurt);
	}
	return pointHurt;
}
static char N[10];
void DoPointHurtForInfected(int wtype, int victim, int attacker = 0)
{
	if (!RealValidEntity(g_PointHurt))
	{
		g_PointHurt = CreatePointHurt();
	}
	if (!RealValidEntity(g_PointHurt)) return;
	
	if (RealValidEntity(victim))
	{
		Format(N, 20, "target%d", victim);
		DispatchKeyValue(victim, "targetname", N);
		DispatchKeyValue(g_PointHurt, "DamageTarget", N);
		DispatchKeyValue(g_PointHurt, "classname", MODEL[wtype]);
		DispatchKeyValue(g_PointHurt, "Damage", weaponbulletdamagestr[wtype]);
		AcceptEntityInput(g_PointHurt, "Hurt", (attacker>0) ? attacker : -1);
	}
}*/

void DoDamage(int wtype, int target, int sender)
{
	if (!RealValidEntity(target)) return;
	if (!RealValidEntity(sender)) return;
	
	int robot_var = sender;
	if (RealValidEntity(robot[sender]))
		robot_var = robot[sender];
	
	SDKHooks_TakeDamage(target, robot_var, sender, StringToInt(weaponbulletdamagestr[wtype])+0.0, 2, robot_var);
	
	/*float spos[3];
	if (RealValidEntity(sender) && HasEntProp(sender, Prop_Data, "m_vecOrigin"))
	{ GetEntPropVector(sender, Prop_Data, "m_vecOrigin", spos); }
	
	int iDmgEntity = CreateEntityByName("point_hurt");
	if (!RealValidEntity(iDmgEntity))
	{ return -1; }
	TeleportEntity(iDmgEntity, spos, NULL_VECTOR, NULL_VECTOR);
	
	DispatchKeyValue(iDmgEntity, "DamageTarget", "!activator");
	
	DispatchKeyValue(iDmgEntity, "classname", MODEL[wtype]);
	DispatchKeyValue(iDmgEntity, "Damage", weaponbulletdamagestr[wtype]);
	DispatchKeyValue(iDmgEntity, "DamageType", "2");
	
	DispatchSpawn(iDmgEntity);
	ActivateEntity(iDmgEntity);
	AcceptEntityInput(iDmgEntity, "Hurt", target, sender);
	AcceptEntityInput(iDmgEntity, "Kill");
	return iDmgEntity;*/
}

/*bool TraceRayDontHitSelf(int entity, int mask, any data)
{
	if (entity == data) 
	{
		return false; 
	}
	return true;
}*/
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

//fix
public void OnClientDisconnect(int client)
{
    Release(client);
}
