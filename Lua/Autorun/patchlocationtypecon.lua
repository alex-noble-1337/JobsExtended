local jobidtoadd = "assistant"
-- must be float
local jobcommonness = 5.0

-- Hook.Patch(
--    "Barotrauma.LocationType",
--    "LocationType",
--    {
--      "Barotrauma.element",
--       "Barotrauma.LocationTypesFile"
--    },
--    function(instance, ptable)
--      -- we still want whole thiuteng to exec 
--      ptable.PreventExecution = false
--      -- we want to append our thing
--      table.insert(ptable["hireableJobs"], {jobidtoadd, jobcommonness})
--      -- function does not return anything, its a constructor
--      return nil
--     --  shoudnt be after?
--    end, Hook.HookMethodType.Before)

-- Hook.Patch("Barotrauma.LocationType", "GetRandomHireable", function(instance, ptable)
--     if math.random() > 0.5 then
--         -- all lua variables are float point, 
--         local totalHireableWeight = instance.totalHireableWeight + jobcommonness
--         local randFloat = ptable["randFloat"] + jobcommonness
--         if randFloat > instance.totalHireableWeight then
--             ptable.ReturnValue = JobPrefab.Get("somecustomjob")
--         end
--     end
--  end, Hook.HookMethodType.After)

Hook.Patch("Barotrauma.LocationType", "GetRandomHireable", function(instance, ptable)
    local commoness = jobcommonness / 20
    print(commoness)
    if math.random() > commoness then
        print("Adding " .. jobidtoadd .. " to hireables")
        ptable.ReturnValue = JobPrefab.Get(jobidtoadd)
    end
 end, Hook.HookMethodType.After)