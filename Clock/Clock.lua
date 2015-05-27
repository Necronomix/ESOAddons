-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
Clock = {}
 
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
Clock.name = "Clock"
 
function Clock:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
 
  ClockIndicator:ClearAnchors()
  ClockIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
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

function Clock.RandomizeColor(extra)
	local newColor = {}
	if extra == ""
	 then
		newColor = Clock:GetNewRandomColor()
	 else
	    local options = {}
		local searchResult = mysplit(extra, "%s")
		for k, v in pairs(searchResult) do
			if (v ~= nil and v ~= "") then
				options[k] = v
			end
		end
		newColor.r = Clock:parseNum(options[1], 0)
		newColor.g = Clock:parseNum(options[2], 0)
		newColor.b = Clock:parseNum(options[3], 0)
	end
	Clock:SetLabelColor(newColor)
	
end


function Clock:parseNum(str, default)
	if str == nil then return default end
	local num = tonumber(str)
	return num == nil and default or num
end


function Clock:GetNewRandomColor()
	local colorPack = {}
	colorPack.r = math.random(0, 255)
	colorPack.g = math.random(0, 255)
	colorPack.b = math.random(0, 255)
	return colorPack
end

function Clock:SetLabelColor(colorSet)
	self.savedVariables.color = colorSet
	ClockIndicatorLabel:SetColor(colorSet.r > 1 and colorSet.r / 255 or colorSet.r,
								 colorSet.g > 1 and colorSet.g / 255 or colorSet.g,
								 colorSet.b > 1 and colorSet.b / 255 or colorSet.b)
end

-- Next we create a function that will initialize our addon
function Clock:Initialize()
  self.savedVariables = ZO_SavedVars:New("ClockAddonSavedVariables", 1, nil, {})
 
  self:RestorePosition()
  local colorSet = self.savedVariables.color
  if colorSet ~= nil then
	self:SetLabelColor(colorSet)
  end
  SLASH_COMMANDS["/colorize"] = Clock.RandomizeColor
end

function Clock.OnIndicatorMoveStop()
  Clock.savedVariables.left = ClockIndicator:GetLeft()
  Clock.savedVariables.top = ClockIndicator:GetTop()
end
 
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function Clock.OnAddOnLoaded(event, addonName)
  if addonName == Clock.name then
    Clock:Initialize()
  end
end
 
function Clock.DoUpdate(event, inCombat)
  ClockIndicatorLabel:SetText(GetTimeString())
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(Clock.name, EVENT_ADD_ON_LOADED, Clock.OnAddOnLoaded)