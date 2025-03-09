api_version = 3

Set = require('lib/set')
Sequence = require('lib/sequence')
Handlers = require("lib/way_handlers")
Relations = require("lib/relations")
require("handlers");

function WayHandlers.skiaerialway(profile,way,result,data)
	if is_empty(data.aerialway) then 
		return;
	end

	result.forward_speed=15;
	result.forward_rate=15;
	result.backward_mode = mode.inaccessible;

	-- duration of gondolas
	local duration  = way:get_value_by_key("duration")
	if duration and durationIsValid(duration) then
		result.duration = math.max( parseDuration(duration), 1 )
	end
	
	-- station, goods
	if in_array(data.aerialway, {'gondola', 'cable_car', 'mixed_lift'}) then
		result.forward_classes['gondola'] = true;
		result.backward_classes['gondola'] = true;
		result.backward_mode = mode.ferry;
		result.backward_speed=result.forward_speed;
		result.backward_rate=result.forward_rate/10;
	elseif in_array(data.aerialway, {'chair_lift'}) then
		result.forward_classes['chairlift'] = true;
	elseif in_array(data.aerialway, {'t-bar', 'j-bar', 'platter', 'drag_lift'}) then
		result.forward_classes['platter'] = true;
		result.forward_rate=result.forward_speed/4;
	elseif in_array(data.aerialway, {'rope_tow', 'zip_line', 'magic_carpet'})  then 
		result.forward_classes['child'] = true;
		result.forward_rate=result.forward_speed/4;
	else 
		-- remaining: goods, station, pilon, yes
		result.forward_mode = mode.inaccessible;
		return false;
	end
	result.forward_mode = mode.ferry;
	result.name = result.name .. ' 🚡';
	
    return result;
end

function WayHandlers.skipiste(profile,way,result,data)
	-- piste: downhill, foot (for foot transfer between stations)
	if is_empty(data.piste) then
		return;
	end
    
	-- remove piste that are areas, ususally not good for routing
	if way:get_value_by_key('area') == 'yes' or  way:get_value_by_key('leisure') == 'sports_centre' then
		return false;
	end

	if data.piste == 'foot' or data.piste=='connection' then
		result.forward_speed=3;
		result.forward_rate=3;
		result.backward_speed=3;
		result.backward_rate=3;
		result.backward_mode = mode.walking;
		result.forward_mode = mode.walking;
		result.name = result.name .. ' 🚶';
		return result;
	end
	if data.piste == 'downhill' then
		result.forward_speed=30;
		result.forward_rate=30;
		result.forward_mode = mode.driving;
		result.name = result.name .. ' ⛷';
		result.backward_ref = '🚶';
		result.backward_speed = 1/10;
		result.backward_rate = 1/100;
		result.backward_mode = mode.inaccessible;
		-- todo: class dificulty
		return result;
	end
end

function WayHandlers.foot(profile,way,result,data)
	-- authorize foot only across areas and the Airelles bridge
	local isArea = (not is_empty(data.piste)) and way:get_value_by_key('area') == 'yes'
	local isAirellesBridge = way:get_value_by_key('name') == 'Passerelle Airelles Express'
	if not isArea and not isAirellesBridge then
		return;
	end

    result.forward_speed=3;
    result.forward_rate=3;
    result.backward_speed=3;
    result.backward_rate=3;
    result.backward_mode = mode.walking;
    result.forward_mode = mode.walking;
    result.name = result.name .. ' 🚶';
    return result;
end

function setup()
  return {
    properties = {
		weight_name = 'routability',
    }, 
    default_mode = mode.ferry,
    default_speed = 1,
    classes = Sequence {
        'gondola', 'chairlift', 'platter', 'child'
    },
    -- classes to support for exclude flags
    excludable = Sequence {
        Set {'gondola'},
        Set {'chairlift'},
        Set {'platter'},
		Set {'child'},
		Set {'gondola','chairlift','platter','child'},
    },
    relation_types = Sequence {
      "route", "piste:type"
    }
  }
end

function process_way(profile, way, result, relations)
    local data = {
		aerialway = way:get_value_by_key('aerialway'),
		piste = way:get_value_by_key('piste:type')
    }

	if way:get_value_by_key('railway') == 'funicular' then
		data.aerialway = 'gondola'
	end

	handlers = Sequence {
		WayHandlers.default_mode,
		WayHandlers.names,
        WayHandlers.foot,
		WayHandlers.skiaerialway,
        WayHandlers.skipiste,
	}
	WayHandlers.run(profile, way, result, data, handlers, relations)
end

return {
  setup = setup,
  process_way = process_way
}
