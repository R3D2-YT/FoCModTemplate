-- $Id: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/AI/UnrestrictedGrabSpace.lua#1 $
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
--              $File: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/AI/UnrestrictedGrabSpace.lua $
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

--A plan to rapidly grab space control that bypasses timing restrictions on AI attacks.

require("pgtaskforce")

-- Tell the script pooling system to pre-cache this number of scripts.
ScriptPoolCount = 4

function Definitions()	
	MinContrastScale = 1.1
	MaxContrastScale = 1.25
		
	Category = "Unrestricted_Grab_Space"
	TaskForce = {
	{
		"MainForce"						
		, "Fighter | Bomber | Corvette | Frigate | Super | Capital = 100%"
	}
	}
	
end

function MainForce_Thread()
	
	-- Since we're using plan failure to adjust contrast, we're 
	-- only concerned with failures in battle. Default the 
	-- plan to successful and then 
	-- only on the event of our task force being killed is the
	-- plan set to a failed state.
	MainForce.Set_Plan_Result(true)	
	
	--For fast execution, build and attack in one plan rather than having the first few iterations
	--feed the freestore
	AssembleForce(MainForce)

	BlockOnCommand(MainForce.Move_To(Target))
	if MainForce.Get_Force_Count() == 0 then
		MainForce.Set_Plan_Result(false)	
		ScriptExit()
	end
	
	--Sit and blockade the planet
	Sleep(300)
		
	ScriptExit()
end

function MainForce_Production_Failed(failed_object_type)
	ScriptExit()
end

function MainForce_Original_Target_Owner_Changed(tf, old_owner, new_owner)	
	--If we take control of this planet than we'll release our blockading units
	if new_owner == PlayerObject then
		ScriptExit()
	end
end