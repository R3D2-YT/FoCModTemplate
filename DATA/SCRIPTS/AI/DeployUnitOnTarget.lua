-- $Id: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/AI/DeployUnitOnTarget.lua#1 $
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
--              $File: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/AI/DeployUnitOnTarget.lua $
--
--    Original Author: Steve_Copeland
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

require("pgevents")


function Definitions()
	DebugMessage("%s -- In Definitions", tostring(Script))
	
	Category = "Remove_Smuggler"
	IgnoreTarget = true
	TaskForce = {
	{
		"MainForce",
		"DenyHeroAttach",
		"Bounty_Hunter_Team_E | Bounty_Hunter_Team_R = 1"
	}
	}

end

function MainForce_Thread()
	DebugMessage("%s -- In MainForce_Thread.", tostring(Script))
		
	BlockOnCommand(MainForce.Produce_Force(AITarget))

	-- Landing a hero deploys it, removing it from the game and killing the script.  So,
	-- we have to indicate success before we land the unit, even though she hasn't deployed.
	-- If a hero killer gets her before she deploys, the plan should die before setting itself successful.	
	MainForce.Set_Plan_Result(true)
	
	BlockOnCommand(LandUnits(MainForce))
	
	DebugMessage("%s -- Finished MainForce_Thread.", tostring(Script))
end

