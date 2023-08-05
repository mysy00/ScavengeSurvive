/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>



#if !defined WEAPON
	#define WEAPON: _:
#endif
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, WEAPON:weaponid, bodypart)
{
	new str[128];
	format(str, 128, "Amount: %f weaponid: %d bodypard: %d", amount, weaponid, bodypart);
	SendClientMessage(playerid, -1, str);
	return 1;
}
