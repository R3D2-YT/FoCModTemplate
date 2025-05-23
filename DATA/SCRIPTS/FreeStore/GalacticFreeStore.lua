-- $Id: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/FreeStore/GalacticFreeStore.lua#1 $
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
--              $File: //depot/Projects/StarWars_Steam/FOC/Run/Data/Scripts/FreeStore/GalacticFreeStore.lua $
--
--    Original Author: Brian Hayes
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

require("pgcommands")
require("GalacticHeroFreeStore")

function Base_Definitions()
	DebugMessage("%s -- In Base_Definitions", tostring(Script))

	-- how often does this script get serviced?
	ServiceRate = 8
	UnitServciceRate = 8
	
	Common_Base_Definitions()
	
	-- Percentage of units to move on each service.
	SpaceMovePercent = 0.10
	GroundMovePercent = 0.10

	if Definitions then
		Definitions()
	end
end

function main()

	DebugMessage("%s -- In main for %s", tostring(Script), tostring(FreeStore))
	
	if FreeStoreService then
		while 1 do
			FreeStoreService()
			PumpEvents()
		end
	end
	
	ScriptExit()
end

function MoveUnit(object)

	dest_target = nil
	object_type = object.Get_Type()
	if object_type.Is_Hero() then
		dest_target = Find_Custom_Target(object)
	end
	
	if not TestValid(dest_target) then
		if object.Is_Transport() then
			dest_target = Find_Ground_Unit_Target(object)
		else
			dest_target = Find_Space_Unit_Target(object)
		end
	end

	if dest_target then
		FreeStore.Move_Object(object, dest_target)
		return true
	else
		DebugMessage("%s -- Object: %s, unable to find a suitable destination for this object.", tostring(Script), tostring(object))
		return false
	end
end

function On_Unit_Service(object)

	-- If this unit isn't in a safe spot move him regardless of the MovedUnitsThisService
	-- Also, Heroes need to be where they most want to be asap
	if (FreeStore.Is_Unit_Safe(object) == false) or (object.Get_Type().Is_Hero()) then
		MoveUnit(object)
		return
	end
		
	if object.Is_Transport() then
		if GameRandom.Get_Float() < GroundAvailablePercent and GroundUnitsMoved < GroundUnitsToMove then
			if FreeStore.Is_Unit_In_Transit(object) == false then
				DebugMessage("%s -- Object: %s service move order issued", tostring(Script), tostring(object))
				if MoveUnit(object) then
					GroundUnitsMoved = GroundUnitsMoved + 1
				end
			end
		end
	else
		if GameRandom.Get_Float() < SpaceAvailablePercent and SpaceUnitsMoved < SpaceUnitsToMove then
			if FreeStore.Is_Unit_In_Transit(object) == false then
				DebugMessage("%s -- Object: %s service move order issued", tostring(Script), tostring(object))
				if MoveUnit(object) then
					SpaceUnitsMoved = SpaceUnitsMoved + 1
				end
			end
		end
	end
end

--	// param 1: playerwrapper.
--	// param 2: perception function name
--	// param 3: goal application type string
--	// param 4: reachability type string
--	// param 5: The probability of selecting the target with highest desire
--	// param 6: The source from which the find target should search for relative targets.
--	// param 7: The maximum distance from source to target.
function On_Unit_Added(object)
	DebugMessage("%s -- Object: %s added to freestore", tostring(Script), tostring(object))

	obj_type = object.Get_Type()
	if obj_type.Is_Hero() then
		DebugMessage("%s -- Hero Object: %s added to freestore", tostring(Script), obj_type.Get_Name())
	end

	MoveUnit(object)
	
end


function FreeStoreService()

	if PlayerObject.Get_Faction_Name() == "REBEL" then
		leader_object = Find_First_Object("MON_MOTHMA")
	elseif PlayerObject.Get_Faction_Name() == "EMPIRE" then
		leader_object = Find_First_Object("EMPEROR_PALPATINE")
	end

	MovedUnitsThisService = 0
	GroundUnitsMoved = 0
	GroundUnitsToMove = 0
	SpaceUnitsMoved = 0
	SpaceUnitsToMove = 0
	SpaceAvailablePercent = 0
	GroundAvailablePercent = 0

	object_count = FreeStore.Get_Object_Count()
	
	if object_count ~= 0 then
		-- get the count of space force in the freestore
		scnt = FreeStore.Get_Object_Count(true)
		-- get the count of ground force in the freestore
		gcnt = FreeStore.Get_Object_Count(false)
		
		SpaceAvailablePercent = scnt / object_count
		GroundAvailablePercent = gcnt / object_count
		SpaceUnitsToMove = SpaceMovePercent * scnt
		GroundUnitsToMove = GroundMovePercent * gcnt
		DebugMessage("%s -- SpaceAvailablePercent: %f, GroundAvailablePercent: %f, SpaceUnitsToMove: %f, GroundUnitsToMove: %f, scnt: %f, gcnt: %f",
			tostring(Script), SpaceAvailablePercent, GroundAvailablePercent, SpaceUnitsToMove, GroundUnitsToMove, scnt, gcnt)
	end
	
end

function Find_Ground_Unit_Target(object)

	my_planet = object.Get_Planet_Location()

	if FreeStore.Is_Unit_Safe(object) == false then
		my_planet = nil
	end	
	
	if leader_object then
		leader_planet = leader_object.Get_Planet_Location()
	end	
	
	max_force_target = 1000 * (PlayerObject.Get_Tech_Level() + 1)
	force_target = EvaluatePerception("Friendly_Global_Land_Unit_Raw_Total", PlayerObject)
	if not force_target then
		return nil
	end
	force_target = force_target / 4.0
	if force_target > max_force_target then
		force_target = max_force_target
	end	
		
	if leader_planet then
		if leader_planet == my_planet then
			return nil	
		elseif leader_planet.Get_Is_Planet_AI_Usable() and object.Can_Land_On_Planet(leader_planet) then
			if EvaluatePerception("Friendly_Land_Unit_Raw_Total", PlayerObject, leader_planet) < force_target then
				return leader_planet
			end
		end
	end
	
	priority_planet = FindTarget.Reachable_Target(PlayerObject, "Ground_Priority_Defense_Score", "Friendly", "Friendly_Only", 0.1, object)
	if priority_planet then
		priority_planet = priority_planet.Get_Game_Object()
	end
		
	if priority_planet then
		if priority_planet == my_planet then
			return nil
		elseif priority_planet.Get_Is_Planet_AI_Usable() and object.Can_Land_On_Planet(priority_planet)	then
			if EvaluatePerception("Friendly_Land_Unit_Raw_Total", PlayerObject, priority_planet) < force_target then
				return priority_planet
			end
		end
	end
	
	if my_planet and EvaluatePerception("Low_Ground_Defense_Score", PlayerObject, my_planet) > 0.5 then
		return nil
	end
	
	poorly_defended_planet = FindTarget.Reachable_Target(PlayerObject, "Low_Ground_Defense_Score", "Friendly", "Friendly_Only", 1.0, object)
	if poorly_defended_planet then
		poorly_defended_planet = poorly_defended_planet.Get_Game_Object()
	end
	
	if poorly_defended_planet and poorly_defended_planet.Get_Is_Planet_AI_Usable() and object.Can_Land_On_Planet(poorly_defended_planet) then
		return poorly_defended_planet
	end	
	
	if not my_planet then
		fallback_planet = FindTarget.Reachable_Target(PlayerObject, "One", "Friendly", "Friendly_Only", 0.1, object)
		if fallback_planet then
			return fallback_planet.Get_Game_Object()
		end
	end
	
	return nil
end

function Find_Space_Unit_Target(object)

	my_planet = object.Get_Planet_Location()

	if not my_planet then
		return nil
	end		
	
	if leader_object then
		leader_planet = leader_object.Get_Planet_Location()
	end
		
	max_force_target = 3000 * (PlayerObject.Get_Tech_Level() + 1)
	force_target = EvaluatePerception("Friendly_Global_Space_Unit_Raw_Total", PlayerObject)
	if not force_target then
		return nil
	end
	force_target = force_target / 4.0
	if force_target > max_force_target then
		force_target = max_force_target
	end
		
	if leader_planet and leader_planet.Get_Is_Planet_AI_Usable() then
		if leader_planet == my_planet then
			if EvaluatePerception("Friendly_Space_Unit_Raw_Total", PlayerObject, leader_planet) < 1.5 * force_target then
				return leader_planet
			end		
		elseif EvaluatePerception("Friendly_Space_Unit_Raw_Total", PlayerObject, leader_planet) < force_target then
			if EvaluatePerception("Enemy_Present", PlayerObject, leader_planet) == 0.0 then
				return leader_planet
			end
		end
	end
	
	priority_planet = FindTarget.Reachable_Target(PlayerObject, "Space_Priority_Defense_Score", "Friendly", "Friendly_Only", 0.1, object)
	if priority_planet then
		priority_planet = priority_planet.Get_Game_Object()
	end
	
	if priority_planet and priority_planet.Get_Is_Planet_AI_Usable() then
		if priority_planet == my_planet then
			if EvaluatePerception("Friendly_Space_Unit_Raw_Total", PlayerObject, priority_planet) < 1.5 * force_target then
				return priority_planet
			end				
		elseif EvaluatePerception("Friendly_Space_Unit_Raw_Total", PlayerObject, priority_planet) < force_target then
			if EvaluatePerception("Enemy_Present", PlayerObject, priority_planet) == 0.0 then
				return priority_planet
			end
		end
	end
	
	if my_planet and EvaluatePerception("Low_Space_Defense_Score", PlayerObject, my_planet) > 0.5 then
		return nil
	end	
	
	poorly_defended_planet = FindTarget.Reachable_Target(PlayerObject, "Low_Space_Defense_Score", "Friendly", "Friendly_Only", 1.0, object)
	if poorly_defended_planet then
		poorly_defended_planet = poorly_defended_planet.Get_Game_Object()
	end
	
	if poorly_defended_planet and poorly_defended_planet.Get_Is_Planet_AI_Usable() then
		if EvaluatePerception("Friendly_Space_Unit_Raw_Total", PlayerObject, poorly_defended_planet) < force_target then
			if EvaluatePerception("Enemy_Present", PlayerObject, poorly_defended_planet) == 0.0 then
				return poorly_defended_planet
			end
		end
	end	
	
	return nil
end
