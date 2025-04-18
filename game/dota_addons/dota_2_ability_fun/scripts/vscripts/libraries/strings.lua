---------------------------------------------------------------------------
-- string.starts
---------------------------------------------------------------------------
function string.starts( string, start )
    return string.sub( string, 1, string.len( start ) ) == start
 end
 
 function string.ends( String, End )
    return End=='' or string.sub(String,-string.len(End))==End
 end

 ---------------------------------------------------------------------------
-- string.split
---------------------------------------------------------------------------
function string.split( str, sep )
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   str:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end