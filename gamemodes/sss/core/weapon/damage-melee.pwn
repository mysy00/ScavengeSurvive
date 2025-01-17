/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static
		// Always for targetid
Float:	dmg_ReturnBleedrate[MAX_PLAYERS],
Float:	dmg_ReturnKnockMult[MAX_PLAYERS];


new
			anm_AttackTick[MAX_PLAYERS],
			anm_CurrentAnim[MAX_PLAYERS];


forward OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, Float:knockmult);


#if !defined KEY
	#define KEY: _:
#endif
hook OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
	if(newkeys & KEY_FIRE)
	{
		_HandleCustomMelee(playerid, GetItemType(GetPlayerItem(playerid)));
	}

	return 1;
}

_HandleCustomMelee(playerid, ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(IsPlayerInAnyVehicle(playerid))
		return 0;

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
		return 0;

	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(IsPlayerKnockedOut(playerid))
		return 0;

	if(GetPlayerAnimationIndex(playerid) == 1381)
		return 0;

	if(_hd_IsPlayerInWater(playerid))
		return 0;

	if(GetTickCountDifference(GetTickCount(), anm_AttackTick[playerid]) < 800)
		return 0;

	new weapontype = GetItemTypeWeapon(itemtype);

	if(weapontype == -1)
		return 0;

	if(GetItemWeaponBaseWeapon(weapontype) != 0)
		return 0;

	new
		animset = GetItemTypeWeaponAnimSet(itemtype),
		lib[32],
		anim[32];

	if(animset == -1)
		return 0;

	if(anm_CurrentAnim[playerid] >= GetAnimSetSize(animset) || GetTickCountDifference(GetTickCount(), anm_AttackTick[playerid]) > 1000)
		anm_CurrentAnim[playerid] = 0;

	GetAnimationName(GetAnimSetAnimationIdx(animset, anm_CurrentAnim[playerid]), lib, 32, anim, 32);
	ApplyAnimation(playerid, lib, anim, 4.1, 0, 1, 1, 0, 0, SYNC_ALL);

	anm_CurrentAnim[playerid]++;
	anm_AttackTick[playerid] = GetTickCount();

	new
		Float:px,
		Float:py,
		Float:pz,
		Float:pa,
		Float:ix,
		Float:iy,
		Float:iz,
		Float:angle;

	GetPlayerPos(playerid, px, py, pz);

	foreach(new i : Player)
	{
		if(playerid == i)
			continue;

		GetPlayerPos(i, ix, iy, iz);

		if(Distance(px, py, pz, ix, iy, iz) < 2.0)
		{
			GetPlayerFacingAngle(playerid, pa);
			angle = absoluteangle(pa - GetAngleToPoint(px, py, ix, iy));

			if(angle > 315.0 || angle < 45.0)
			{
				GetPlayerFacingAngle(i, pa);
				angle = absoluteangle(pa - GetAngleToPoint(ix, iy, px, py));

				if(angle > 135.0 || angle < 225.0)
					ApplyAnimation(i, "PED", "DAM_stomach_frmBK", 4.1, 0, 1, 1, 0, 0, SYNC_ALL); // FROM BACK

				if(angle > 315.0 || angle < 45.0)
					ApplyAnimation(i, "PED", "DAM_stomach_frmFT", 4.1, 0, 1, 1, 0, 0, SYNC_ALL); // FROM FRONT

				if(angle > 45.0 || angle < 135.0)
					ApplyAnimation(i, "PED", "DAM_stomach_frmLT", 4.1, 0, 1, 1, 0, 0, SYNC_ALL); // FROM LEFT

				if(angle > 225.0 || angle < 315.0)
					ApplyAnimation(i, "PED", "DAM_stomach_frmRT", 4.1, 0, 1, 1, 0, 0, SYNC_ALL); // FROM RIGHT

				_DoMeleeDamage(playerid, i, GetItemTypeWeaponMuzzVelocity(itemtype), Float:GetItemTypeWeaponMagSize(itemtype));
			}
		}
	}

	return 1;
}

#if !defined WEAPON
	#define WEAPON: _:
#endif
hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart)
{
	if(weaponid == 0)
		return _DoMeleeDamage(playerid, damagedid, 0.001, 0.5);

	return _HandleStandardMelee(playerid, damagedid);
}

_HandleStandardMelee(playerid, targetid)
{
	new
		Item:itemid,
		ItemType:itemtype,
		weapontype,
		baseweapon;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);
	weapontype = GetItemTypeWeapon(itemtype);
	baseweapon = GetItemWeaponBaseWeapon(weapontype);

	if(!IsBaseWeaponMelee(baseweapon))
		return 0;

	return _DoMeleeDamage(playerid, targetid, GetItemTypeWeaponMuzzVelocity(itemtype), Float:GetItemTypeWeaponMagSize(itemtype));
}

_DoMeleeDamage(playerid, targetid, Float:bleedrate, Float:knockmult)
{
	if(IsPlayerOnAdminDuty(playerid) || IsPlayerOnAdminDuty(targetid))
		return 0;

	dmg_ReturnBleedrate[targetid] = bleedrate;
	dmg_ReturnKnockMult[targetid] = knockmult;

	if(CallLocalFunction("OnPlayerMeleePlayer", "ddff", playerid, targetid, bleedrate, knockmult))
		return 0;

	if(dmg_ReturnBleedrate[targetid] != bleedrate)
		bleedrate = dmg_ReturnBleedrate[targetid];

	if(dmg_ReturnKnockMult[targetid] != knockmult)
		knockmult = dmg_ReturnKnockMult[targetid];

	PlayerInflictWound(playerid, targetid, E_WOUND_MELEE, bleedrate, knockmult, NO_CALIBRE, random(2) ? BODY_PART_TORSO : BODY_PART_HEAD, "Melee");
	ShowHitMarker(playerid, 0);

	return 1;
}

stock DMG_MELEE_SetBleedRate(targetid, Float:bleedrate)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	dmg_ReturnBleedrate[targetid] = bleedrate;

	return 1;
}

stock DMG_MELEE_SetKnockMult(targetid, Float:knockmult)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	dmg_ReturnKnockMult[targetid] = knockmult;

	return 1;
}
