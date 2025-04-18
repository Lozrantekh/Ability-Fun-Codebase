function TableHasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function TableMerge(t1, t2)
	for k,v in ipairs(t2) do
	   table.insert(t1, v)
	end 
  
	return t1
end

function TableCompare(a,b)
    return a[1] < b[1]
end

function TableSortBy(a, b, key, desc)
	if not a[key] or not b[key] then
		return false
	end

	if desc then
		return a[key] > b[key]
	end

	return a[key] < b[key]
end

function IsTableMapEmpty(tab)
	local counter = 0

	for key, _ in pairs(tab) do
		if key ~= nil then
			counter = counter + 1
		end
	end

	if counter > 0 then
		return false
	end

	return true
end

---------------------------------------------------------------------------
-- shallowcopy
---------------------------------------------------------------------------
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

---------------------------------------------------------------------------
-- deepcopy
---------------------------------------------------------------------------
function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end

	return copy
end

---------------------------------------------------------------------------
-- ShuffledList
---------------------------------------------------------------------------
function shuffleTable( orig_list )
	local list = shallowcopy( orig_list )
	local result = {}
	local count = #list
	for i = 1, count do
		local pick = RandomInt( 1, #list )
		result[ #result + 1 ] = list[ pick ]
		table.remove( list, pick )
	end
	return result
end

---------------------------------------------------------------------------
-- shuffle
---------------------------------------------------------------------------
function shuffleTable2(orig)
	local copy = deepcopy(orig)

	for i = #copy, 2, -1 do
	  local j = RandomInt(1, i)
	  copy[i], copy[j] = copy[j], copy[i]
	end

	return copy
end