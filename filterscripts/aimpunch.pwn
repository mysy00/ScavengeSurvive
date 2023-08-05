#include <a_samp>


static PlayerAimPunch[MAX_PLAYERS] = {0, ...};


#if !defined BULLET_HIT_TYPE
	#define BULLET_HIT_TYPE: _:
#endif
#if !defined WEAPON
	#define WEAPON: _:
#endif
public OnPlayerWeaponShot(playerid, WEAPON:weaponid, BULLET_HIT_TYPE:hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(PlayerAimPunch[playerid] == 0)
		PlayerAimPunch[playerid] = 1000;

	SetPlayerDrunkLevel(playerid, PlayerAimPunch[playerid]);
	PlayerAimPunch[playerid] += 100;

	return 1;
}

#if !defined KEY
	#define KEY: _:
#endif
public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
	if(!(oldkeys & KEY_FIRE))
	{
		SetPlayerDrunkLevel(playerid, 0);
		PlayerAimPunch[playerid] = 0;
	}

	return 1;
}
