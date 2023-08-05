/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


/*
	Anti "ninja-jack" (or anj)
*/


static
	anj_CurrentlyEntering[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};


hook OnPlayerConnect(playerid)
{
	anj_CurrentlyEntering[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(!ispassenger)
	{
		anj_CurrentlyEntering[playerid] = vehicleid;
		defer CurrentlyEnteringCheck(playerid);
	}

	return 1;
}

timer CurrentlyEnteringCheck[3000](playerid)
{
	if(!IsPlayerInAnyVehicle(playerid))
		anj_CurrentlyEntering[playerid] = INVALID_VEHICLE_ID;
}

#if !defined PLAYER_STATE
	#define PLAYER_STATE: _:
#endif
hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
	if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
	{
		anj_CurrentlyEntering[playerid] = INVALID_VEHICLE_ID;
	}
	return 1;
}

#if !defined KEY
	#define KEY: _:
#endif
hook OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
	if(newkeys & 8 || newkeys & 32)
	{
		if(anj_CurrentlyEntering[playerid] != INVALID_VEHICLE_ID)
		{
			new
				targetid = INVALID_PLAYER_ID,
				Float:x,
				Float:y,
				Float:z,
				Float:a;

			GetVehiclePos(anj_CurrentlyEntering[playerid], x, y, z);
			GetVehicleZAngle(anj_CurrentlyEntering[playerid], a);

			foreach(new i : Player)
			{
				if(IsPlayerInVehicle(i, anj_CurrentlyEntering[playerid]) && GetPlayerState(targetid) == PLAYER_STATE_DRIVER)
				{
					targetid = i;
					break;
				}
			}

			if(targetid != INVALID_PLAYER_ID)
			{
				RemovePlayerFromVehicle(targetid);
				SetPlayerPos(targetid, x + floatsin(-a + 90.0, degrees), y + floatcos(-a + 90.0, degrees), z);
			}

			anj_CurrentlyEntering[playerid] = INVALID_VEHICLE_ID;
		}
	}
	return 1;
}

stock IsPlayerBeingHijacked(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	foreach(new i : Player)
	{
		if(anj_CurrentlyEntering[i] == GetPlayerVehicleID(playerid))
			return 1;
	}

	return 0;
}
