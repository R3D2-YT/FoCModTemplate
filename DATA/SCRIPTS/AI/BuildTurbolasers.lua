-- $Id: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/AI/BuildTurbolasers.lua#1 $
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
--              $File: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/AI/BuildTurbolasers.lua $
--
--    Original Author: James Yarrow
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
	Category = "Build_Turbolasers"
	IgnoreTarget = true
	TaskForce = {
	{
		"StructureForce",
		"E_Galactic_Turbolaser_Tower_Defenses | R_Galactic_Turbolaser_Tower_Defenses = 1"
	}
	}
end

function StructureForce_Thread()
	
	Sleep(1)
	
	StructureForce.Set_As_Goal_System_Removable(false)
	AssembleForce(StructureForce)
	
	StructureForce.Set_Plan_Result(true)
	ScriptExit()
end

function StructureForce_Production_Failed(tf, failed_object_type)
	DebugMessage("%s -- Abandonning plan owing to production failure.", tostring(Script))
	ScriptExit()
end