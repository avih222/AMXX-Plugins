/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
//#include <CC_ColorChat>
//#include <fcs>

#define PLUGIN "FCS Winteam Rewards"
#define VERSION "1.0"

#define FCS_TEAM_FURIEN 	CS_TEAM_T
#define FCS_TEAM_ANTIFURIEN	CS_TEAM_CT


enum Color
{
	NORMAL = 1, 		// Culoarea care o are jucatorul setata in cvar-ul scr_concolor.
	GREEN, 			// Culoare Verde.
	TEAM_COLOR, 		// Culoare Rosu, Albastru, Gri.
	GREY, 			// Culoarea Gri.
	RED, 			// Culoarea Rosu.
	BLUE, 			// Culoarea Albastru.
}

new TeamName[  ][  ] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}





//--| Furien Credits System .inc file
/*
 * Returns a players credits
 * 
 * @param		client - The player index to get points of
 * 
 * @return		The credits client
 * 
 */

native fcs_get_user_credits(client);

/*
 * Sets <credits> to client
 * 
 * @param		client - The player index to set points to
 * @param		credits - The amount of credits to set to client
 * 
 * @return		The credits of client
 * 
 */

native fcs_set_user_credits(client, credits);

/*
 * Adds <credits> points to client
 * 
 * @param		client - The player index to add points to
 * @param		credits - The amount of credits to add to client
 * 
 * @return		The credits of client
 * 
 */

stock fcs_add_user_credits(client, credits)
{
	return fcs_set_user_credits(client, fcs_get_user_credits(client) + credits);
}

/*
 * Subtracts <credits>  from client
 * 
 * @param		client - The player index to subtract points from
 * @param		credits - The amount of credits to substract from client
 * 
 * @return		The credits of client
 * 
 */

stock fcs_sub_user_credits(client, credits)
{
	return fcs_set_user_credits(client, fcs_get_user_credits(client) - credits);
}

//--| End of Furien Credits System .inc file

new const g_szTag[ ] = "[Furien Credits]";

new g_iCvarEnable;
new g_iCvarWinteamFurien;
new g_iCvarWinteamAnti;

new g_iMaxPlayers;

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, "Askhanar" );
	
	g_iCvarEnable = register_cvar( "fcs_wtr_enable", "1" );
	g_iCvarWinteamFurien = register_cvar( "fcs_wtr_furien", "12" );
	g_iCvarWinteamAnti = register_cvar( "fcs_wtr_antifurien", "20" );
	
	register_event( "SendAudio", "ev_SendAudioTerWin", "a", "2=%!MRAD_terwin" );
	register_event( "SendAudio", "ev_SendAudioCtWin", "a", "2=%!MRAD_ctwin" );
	
	g_iMaxPlayers = get_maxplayers( );
	// Add your code here...
}



public ev_SendAudioTerWin( )
{
	static iCvarEnable, iCvarFurienReward;
	iCvarEnable = get_pcvar_num( g_iCvarEnable );
	iCvarFurienReward = get_pcvar_num( g_iCvarWinteamFurien );
	
	if( iCvarEnable != 1 || iCvarFurienReward == 0 )
		return;
		
	GiveTeamReward( FCS_TEAM_FURIEN, iCvarFurienReward );
	
}


public ev_SendAudioCtWin( )
{
	
	static iCvarEnable, iCvarAntiReward;
	iCvarEnable = get_pcvar_num( g_iCvarEnable );
	iCvarAntiReward = get_pcvar_num( g_iCvarWinteamAnti );
	
	if( iCvarEnable != 1 || iCvarAntiReward == 0 )
		return;
		
	GiveTeamReward( FCS_TEAM_ANTIFURIEN, iCvarAntiReward );
}

public GiveTeamReward( const CsTeams:iTeam, iCredits )
{
	
	for(  new id = 1;  id <= g_iMaxPlayers;  id++   )
	{
		if( cs_get_user_team( id ) == iTeam )
		{
			ColorChat( id, RED, "^x04%s^x01 Ai primit^x03 %i^x01 credit%s pentru castigarea rundei!", g_szTag, iCredits, iCredits == 1 ? "" : "e" );
			fcs_add_user_credits( id, iCredits );
		}
	}
}

ColorChat(  id, Color:iType, const msg[  ], { Float, Sql, Result, _}:...  )
{
	
	// Daca nu se afla nici un jucator pe server oprim TOT. Altfel dam de erori..
	if( !get_playersnum( ) ) return;
	
	new szMessage[ 256 ];

	switch( iType )
	{
		 // Culoarea care o are jucatorul setata in cvar-ul scr_concolor.
		case NORMAL:	szMessage[ 0 ] = 0x01;
		
		// Culoare Verde.
		case GREEN:	szMessage[ 0 ] = 0x04;
		
		// Alb, Rosu, Albastru.
		default: 	szMessage[ 0 ] = 0x03;
	}

	vformat(  szMessage[ 1 ], 251, msg, 4  );

	// Ne asiguram ca mesajul nu este mai lung de 192 de caractere.Altfel pica server-ul.
	szMessage[ 192 ] = '^0';
	

	new iTeam, iColorChange, iPlayerIndex, MSG_Type;
	
	if( id )
	{
		MSG_Type  =  MSG_ONE_UNRELIABLE;
		iPlayerIndex  =  id;
	}
	else
	{
		iPlayerIndex  =  CC_FindPlayer(  );
		MSG_Type = MSG_ALL;
	}
	
	iTeam  =  get_user_team( iPlayerIndex );
	iColorChange  =  CC_ColorSelection(  iPlayerIndex,  MSG_Type, iType);

	CC_ShowColorMessage(  iPlayerIndex, MSG_Type, szMessage  );
		
	if(  iColorChange  )	CC_Team_Info(  iPlayerIndex, MSG_Type,  TeamName[ iTeam ]  );

}

CC_ShowColorMessage(  id, const iType, const szMessage[  ]  )
{
	
	static bool:bSayTextUsed;
	static iMsgSayText;
	
	if(  !bSayTextUsed  )
	{
		iMsgSayText  =  get_user_msgid( "SayText" );
		bSayTextUsed  =  true;
	}
	
	message_begin( iType, iMsgSayText, _, id  );
	write_byte(  id  )		
	write_string(  szMessage  );
	message_end(  );
}

CC_Team_Info( id, const iType, const szTeam[  ] )
{
	static bool:bTeamInfoUsed;
	static iMsgTeamInfo;
	if(  !bTeamInfoUsed  )
	{
		iMsgTeamInfo  =  get_user_msgid( "TeamInfo" );
		bTeamInfoUsed  =  true;
	}
	
	message_begin( iType, iMsgTeamInfo, _, id  );
	write_byte(  id  );
	write_string(  szTeam  );
	message_end(  );

	return 1;
}

CC_ColorSelection(  id, const iType, Color:iColorType)
{
	switch(  iColorType  )
	{
		
		case RED:	return CC_Team_Info(  id, iType, TeamName[ 1 ]  );
		case BLUE:	return CC_Team_Info(  id, iType, TeamName[ 2 ]  );
		case GREY:	return CC_Team_Info(  id, iType, TeamName[ 0 ]  );

	}

	return 0;
}

CC_FindPlayer(  )
{
	new iMaxPlayers  =  get_maxplayers(  );
	
	for( new i = 1; i <= iMaxPlayers; i++ )
		if(  is_user_connected( i )  )
			return i;
	
	return -1;
}