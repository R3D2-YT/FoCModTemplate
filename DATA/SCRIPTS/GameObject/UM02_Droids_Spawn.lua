-- $Id: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/GameObject/UM02_Droids_Spawn.lua#1 $
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, Inc.
--
--
--  *****           **                          *                   *
--  *   **          *                           *                   *
--  *    *          *                           *                   *
--  *    *          *     *                 *   *          *        *
--  *   *     *** ******  * **  ****      ***   * *      * *****    * ***
--  *  **    *  *   *     **   *   **   **  *   *  *    * **   **   **   *
--  ***     *****   *     *   *     *  *    *   *  *   **  *    *   *    *
--  *       *       *     *   *     *  *    *   *   *  *   *    *   *    *
--  *       *       *     *   *     *  *    *   *   * **   *   *    *    *
--  *       **       *    *   **   *   **   *   *    **    *  *     *   *
-- **        ****     **  *    ****     *****   *    **    ***      *   *
--                                          *        *     *
--                                          *        *     *
--                                          *       *      *
--                                      *  *        *      *
--                                      ****       *       *
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
-- C O N F I D E N T I A L   S O U R C E   C O D E -- D O   N O T   D I S T R I B U T E
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
--              $File: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/GameObject/UM02_Droids_Spawn.lua $
--
--    Original Author: Jeff_Stewart
--
--            $Author: Brian_Hayes $
--
--            $Change: 637819 $
--
--          $DateTime: 2017/03/22 10:16:16 $
--
--          $Revision: #1 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")
require("PGSpawnUnits")
require("JGS_FunctionLib") -- added library of commonly used functions

function Definitions()

   -- Object isn't valid at this point so don't do any operations that
   -- would require it.  State_Init is the first chance you have to do
   -- operations on Object
   
	DebugMessage("%s -- In Definitions", tostring(Script))
	Define_State("State_Init", State_Init);
end


function State_Init(message)
		if message == OnEnter then
			-- Register a prox event that looks for any nearby units
			empire_player = Find_Player("Empire")
			underworld_player = Find_Player("Underworld")
			random_var = GameRandom(2,10)
			Register_Timer(Respawn, random_var)
			last_droid = nil
		elseif message == OnUpdate then
			--Do Nothing
		elseif message == OnExit then 
			--Do Nothing
		end
end

function Respawn()
	-- respawns destroyer droids from the production lines until deleted by script
	if not TestValid(last_droid) then
		unit_list = Find_All_Objects_Of_Type("Destroyer_Droid")
		if table.getn(unit_list) < 20 then 
			Object.Play_SFX_Event("Unit_AT_AT_Rope_Drop")
			last_droid = Create_Generic_Object("Destroyer_Droid",Object.Get_Position(),underworld_player)
			Register_Timer(Respawn, 60)
		else
			Register_Timer(Respawn, 10)
		end
	else
		Register_Timer(Respawn, 10)
	end
end


