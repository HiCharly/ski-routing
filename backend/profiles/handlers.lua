function get_from_rel(relations, way, key, value, ret, forward)
        -- if any of way's relation have key=value, return tag ret; else return NULL
        if not forward then forward = 'forward'; end -- ignored at the moment
        local rel_id_list = relations:get_relations(way)
        for i, rel_id in ipairs(rel_id_list) do
                local rel = relations:relation(rel_id);
                local p = rel:get_value_by_key(key);
                if value == '*' and p then return rel:get_value_by_key(ret); end
                if p == value then return rel:get_value_by_key(ret); end
        end
        return nil;
end

function is_empty(s)
        return s == nil or s == ''
end
      

function in_array(needle, tab)
        for index, value in ipairs(tab) do
                if value == needle then
                        return true
                end
        end

        return false
end