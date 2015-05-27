-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
EXPNotifier = {}
 
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
EXPNotifier.name = "EXPNotifier"

EXPNotifier.Reasons = {{ "Quest", 1 }, {"Kill", 5} }
 
function EXPNotifier:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
 
  EXPNotifierIndicator:ClearAnchors()
  EXPNotifierIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end 


function EXPNotifier:parseNum(str, default)
	if str == nil then return default end
	local num = tonumber(str)
	return num == nil and default or num
end


-- Next we create a function that will initialize our addon
function EXPNotifier:Initialize()
  self.savedVariables = ZO_SavedVars:New("EXPNotifierAddonSavedVariables", 1, nil, {})
  self.exp = 0
   
  self:RestorePosition()
  EVENT_MANAGER:RegisterForEvent(EXPNotifier.name, EVENT_EXPERIENCE_GAIN, EXPNotifier.OnExperienceGain)
 end

function EXPNotifier.OnIndicatorMoveStop()
  EXPNotifier.savedVariables.left = EXPNotifierIndicator:GetLeft()
  EXPNotifier.savedVariables.top = EXPNotifierIndicator:GetTop()
end

function EXPNotifier.OnExperienceGain(event, reason, level, previousExperience, currentExperience)
   self.exp = currentExperience
   local increase = currentExperience - previousExperience
   local reasonText = ""
   
    for v in EXPNotifier.Reasons do
	     if v[2] == reason then
	        reasonText = v[1]
	     end
    end
   
   EXPNotifierIndicatorLabel:SetText(reasonText .. increase)
   
end
 
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function EXPNotifier.OnAddOnLoaded(event, addonName)
  if addonName == EXPNotifier.name then
    EXPNotifier:Initialize()
  end
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(EXPNotifier.name, EVENT_ADD_ON_LOADED, EXPNotifier.OnAddOnLoaded)