/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static
Text:HitMark_centre = Text:INVALID_TEXT_DRAW,
Text:HitMark_offset = Text:INVALID_TEXT_DRAW;


#if !defined WEAPON
	#define WEAPON: _:
#endif
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, WEAPON:weaponid, bodypart)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(!IsPlayerSpawned(playerid))
		return 0;

	if(IsPlayerOnAdminDuty(issuerid))
		return 0;

	if(!IsPlayerSpawned(issuerid))
		return 0;

	switch(weaponid)
	{
		case 31:
		{
			new model = GetVehicleModel(GetPlayerVehicleID(playerid));

			if(model == 447 || model == 476)
				_DoFirearmDamage(issuerid, playerid, INVALID_ITEM_ID, item_VehicleWeapon, bodypart);
		}
		case 38:
		{
			if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 425)
				_DoFirearmDamage(issuerid, playerid, INVALID_ITEM_ID, item_VehicleWeapon, bodypart);
		}
	}

	return 1;
}

GivePlayerHP(playerid, Float:hp)
{
	SetPlayerHP(playerid, (GetPlayerHP(playerid) + hp));
}

ShowHitMarker(playerid, weapon)
{
	if(weapon == 34 || weapon == 35)
	{
		TextDrawShowForPlayer(playerid, HitMark_centre);
		defer HideHitMark(playerid, HitMark_centre);
	}
	else
	{
		TextDrawShowForPlayer(playerid, HitMark_offset);
		defer HideHitMark(playerid, HitMark_offset);
	}
}
timer HideHitMark[500](playerid, Text:hitmark)
{
	TextDrawHideForPlayer(playerid, hitmark);
}

hook OnGameModeInit()
{
	new hm[14];
	hm[0] =92,	hm[1] =' ',hm[2] ='/',hm[3] ='~',hm[4] ='n',hm[5] ='~',	hm[6] =' ',
	hm[7] ='~',	hm[8] ='n',hm[9] ='~',hm[10]='/',hm[11]=' ',hm[12]=92,  hm[13]=EOS;
	//"\ /~n~ ~n~/ \"

	HitMark_centre			=TextDrawCreate(305.500000, 208.500000, hm);
	TextDrawBackgroundColour	(HitMark_centre, -1);
	TextDrawFont(HitMark_centre, TEXT_DRAW_FONT_1);
	TextDrawLetterSize		(HitMark_centre, 0.500000, 1.000000);
	TextDrawColour			(HitMark_centre, -1);
	TextDrawSetProportional	(HitMark_centre, 1);
	TextDrawSetOutline		(HitMark_centre, 0);
	TextDrawSetShadow		(HitMark_centre, 0);

	HitMark_offset			=TextDrawCreate(325.500000, 165.500000, hm);
	TextDrawBackgroundColour	(HitMark_offset, -1);
	TextDrawFont(HitMark_offset, TEXT_DRAW_FONT_1);
	TextDrawLetterSize		(HitMark_offset, 0.520000, 1.000000);
	TextDrawColour			(HitMark_offset, -1);
	TextDrawSetProportional	(HitMark_offset, 1);
	TextDrawSetOutline		(HitMark_offset, 0);
	TextDrawSetShadow		(HitMark_offset, 0);
}
