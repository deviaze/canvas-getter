--!strict
-- can't decide on whether Array or List so why not ArrayList fml


--- Parent class for custom typed Arrays and List datatypes 
local ArrayList = {}
      ArrayList.__index = ArrayList
      ArrayList.List = {}

local List = ArrayList.List
      List.__index = List
      
      function List.newNode(value : any) : Node 
            return {
                  value = value,
                  next = nil :: Node?,
            }
      end
      export type Node = typeof(List.newNode(...))
      function List.newList()
            return {
                  head = nil :: Node?,
                  is_empty = true :: boolean,
                  first = nil :: any?,
                  last = nil :: any?,
                  length = 0 :: number,
            }
      end

      List.ListInstance = {}

      --[=[
            LinkedList default constructor
            ### Usage:
            ```lua
            local List = require("@/path_to/Lists")
            type List = List.List

            local newListy = List.new(1, 2, 3, "red", "blue", Instance.new("braincell"))
            ```
      ]=]
      function List.new(...)
            local newList = setmetatable(List.newList(), List.ListInstance) :: any
            newList.is_empty = true
            newList.length = 0 -- somehow need these for type inference? 
            for _, arg in {...} do
                  newList:append(arg) -- please ignore the type error im tired
            end
            return newList :: typeof(setmetatable(List.newList(), List.ListInstance)) -- average typehacks :cries: 
      end

      export type List = typeof(List.new(...))

      --- Constructs LinkedList from `{array-like-table}`
      function List.from(basic_array : {any})
            return List.new(unpack(basic_array))
      end

      --- new `LinkedList` from dictionary table
      function List.frompairs(dictionary: {[any]: any})
            local newPairedList = List.new() 
            for key, value in dictionary do 
                  newPairedList:append({key, value})
            end
            return newPairedList
      end

      function List.mapped<K,V>(dictionary: {[K]:V}, mapper: (key: K, value: V) -> (any?, any?))
            return List.frompairs(dictionary):mappairs(function(key: K, value: V)
                  local newK, newV = mapper(key, value)
                  if newK and newV then
                        return newK, newV
                  end
                  return nil
            end)
      end
      
      --[=[
            Creates a new dictionary by mapping keys and values from an existing dictionary.
            ### Usage:
            ```lua
            local old_table = {
                  grandpa = "Jimothy",
                  grandma = "Samantha",
            }
            local new_table = List.mappairs(old_table, function(title, name)
                return title:match("[..]$"), name.chars(1, 3)
            end)
            --- output --> new_table = {pa = "Jim", ma = "Sam"}
            ```
      ]=]
      function List.mappairs<K, V, newKey, newVal>(dictionary: {[K]: V}, breakup: (key : K, value : V) -> (newKey, newVal)) : {[newKey]: newVal}
            return List.frompairs(dictionary):table(breakup)
      end

local ListInstance = List.ListInstance
      ListInstance.__index = ListInstance

      --[=[
            Appends one or many elements to `LinkedList`.
            ```lua
            newListy.append("tortoise")
            ```
      ]=]
      function ListInstance.append(self : List, ... : any | {any})
            if not self.length then
                  error(`LinkedList TypeError: expected self, got ({self}). Did you use a dot .append instead of :append ?`)
            end
            for _, value in {...} do
                  local newNode = List.newNode(value)
                  if self.is_empty then
                        self.head = newNode
                        self.first = newNode.value
                        self.last = newNode.value
                        self.is_empty = false
                  else
                        local last_node = self:__get_node(self.length - 1)
                        assert(last_node)
                        last_node.next = newNode
                        self.last = newNode.value
                  end
                  if not self.length then
                        print(self)
                  end
                  self.length += 1
            end
            return self
      end

      --[=[
            retreive value at index *(starts at 0)*
            ```lua
            local one = newList:get(0) -- gets the number 1 (0th index of array)
            local one = newList:at(0) -- same 
            local one = newList(0) -- same
            local last = newList(-1) -- negative indexes welcome
            ```
      ]=]
      function ListInstance.get(self: List, target_index)
            if target_index < 0 then
                  target_index = self.length + target_index -- turn our negatives upside-down :p
            end
            local node_at_index = self:__get_node(target_index)
            if node_at_index then 
                  return node_at_index.value
            else
                  return nil
            end
      end

      --- alias for Linkedlist:get(index: number)
      function ListInstance.at(self: List, ...: number)
            return self:get(...)
      end

      function ListInstance.__call(self: List, target_index : number)
            return self:get(target_index)
      end

      function ListInstance.__get_node(self : List, target_index : number) : Node?
            if target_index >= self.length then
                  return nil -- index out-of-bounds
            end
            local index_current = 0
            local node_current = self.head :: Node
            while index_current < target_index do
                  index_current += 1
                  if node_current.next then
                        node_current = node_current.next
                  else
                        return nil
                  end
            end
            return node_current
      end

      --- check if value in LinkedList
      function ListInstance.has(self: List, value: any) : boolean
            return self:search(function(v)
                  return v == value
            end) :: boolean
      end

      function ListInstance.print(self: List) : List
            print(self:__tostring())
            return self
      end

      --- pretty print for pretty Lists
      function ListInstance.pp(self: List): List
            local output = "[LinkedList:\n"
            local middle = self:collect("", function(v, i)
                  local number_padding = if i < 10 then "0" else ""
                  return `  [{number_padding}{i}]: {v}\n`
            end) .. "]"
            print(output .. middle)
            return self
      end

      function ListInstance.__tostring(self: List)
            return `[LinkedList: {self:collect("", function(element, i)
                  return `{element}{
                        if i < self.length - 1 then ", " else ""
                  }` end)
            }]`
      end

      --- Conversions
      --- String representation with brackets
      function ListInstance.string(self : List)
            return tostring(self):gsub("LinkedList: ", "")
      end

      --- Converts LinkedList into regular {Array-Like-Table}. Alias for LinkedList:collect({})
      function ListInstance.array(self: List)
            return self:collect({})
      end

      --- remove node at index and return value
      function ListInstance.remove(self: List, target_index: number)
            local cached_node = nil :: Node?
            if target_index == 0 then
                  if self.head then
                        cached_node = self.head
                        if self.head.next then
                              self.head = self.head.next
                              self.first = self.head.value
                        end
                  end
            elseif target_index == self.length - 1 then
                  cached_node = self:__get_node(self.length - 1)
                  local last_node = self:__get_node(self.length - 2)
                  if last_node then last_node.next = nil end
                  assert(last_node)
                  self.last = last_node.value
            else
                  cached_node = self:__get_node(target_index)
                  local prev_node = self:__get_node(target_index - 1)
                  local next_node = self:__get_node(target_index + 1)
                  if prev_node then
                        prev_node.next = next_node
                  end
            end
            if cached_node then
                  self.length -= 1
                  if self.length == 0 then
                        self.is_empty = true
                  end
                  return cached_node.value
            else
                  return nil
            end
      end

      --[=[
            Removes and returns the first value in the LinkedList
            ```lua
            local popcorn = List.new("pop", "corn")
            local pop = popcorn:shift()
            ```
      ]=]
      function ListInstance.shift(self: List)
            return self:remove(0)
      end
      
      --[=[
            Removes and returns the last value in the LinkedList
            ```lua
            local popcorn = List.new("pop", "corn")
            local corn = popcorn:pop()
            ```
      ]=]
      function ListInstance.pop(self: List)
            return self:remove(self.length - 1)
      end

      --[=[
            ### Iterate through a LinkedList:
            note that LinkedLists start at index 0, not 1!
            ```lua
            local list = List.new("zeroth", "first", "second", "third")

            list:each(function(value, index) 
                  print(index .. value)
                  --> "0 .. zeroth" ...
            end)
            ```
      ]=]
      function ListInstance.each(self: List, onEach: (value : any, index : number?) -> (), range : {number?}?)
            local min_index, max_index = 0, self.length
            if range then
                  if #range == 2 then
                        min_index, max_index = range[1] :: number, range[2] :: number
                  elseif #range == 1 then
                        max_index = range[1] :: number
                  end
            end
            local count = min_index
            while count < max_index do
                  onEach(self:get(count), count)
                  count += 1
            end
            return self
      end

      function ListInstance.search(self: List, query: (value: any, index: number?) -> (any), range: {number?}?): (any?, number?)
            local min_index, max_index = 0, self.length
            if range then
                  if #range == 2 then
                        min_index, max_index = range[1] :: number, range[2] :: number
                  elseif #range == 1 then
                        max_index = range[1] :: number
                  end
            end
            local count = min_index
            while count < max_index do
                  local response = query(self:get(count), count)
                  if response then
                        return response
                  end
                  count += 1
            end
            return nil
      end

      --[=[
            Equivalent to a map + filter. Generates a new `LinkedList` from your function `map`. Filtered by & including all truthy returns. 

            ```lua
            -- examples:
             -- subtract 1 from all (in new list)
                  local list = List.new(11, 21, 31, 41, 51, 61)

                  local list_one_less = list:map(function(value: number)
                        return value - 1
                  end):print()

             ---> output: "[LinkedList: 10, 20, 30, 40, 50, 60]"

             -- select only evens, subtract 10 from them, and then choose only those < 25
                  local numbers = List.new(1, 2, 5, 7, 8, 56, 21, 20, 40, 24, 489, 29, 28)

                  local evens_under_25 = numbers:map(function(n: number)
                        return n % 2 == 0 and (n - 10)
                  end):map(function(n)
                        return n < 25 and n
                  end):print()

             ---> output: "[LinkedList: -8, -2, 10, 14, 18]"

            ```
      ]=]
      function ListInstance.map(self: List, map: ((value: any, index: number?) -> (any))?) : List
            local mappedList = List.new()
            map = map or function(v,i)
                  if not v then return false
                  elseif typeof(v) == "string" and v:gsub(" ", "") == "" then
                        return false
                  elseif v == {} then
                        return false
                  end
                  return v
            end
            assert(map, " is a valid function")

            self:each(function(v, i)
                  local result = map(v, i)
                  if result then
                        mappedList:append(result)
                  end
            end)
            return mappedList
      end

      function ListInstance.match(self: List, matcher: string | (term : string) -> (boolean, string?), ... : string)
            if typeof(matcher) == "string" then
                  local matchers = {matcher, ...}
                  return self:map(function(value: string, index: number?)
                        for _, m in matchers do 
                              if value:match(m) then
                                    return value
                              end
                        end
                        return false
                  end)
            elseif typeof(matcher) == "function" then
                  return self:map(function(value: string, index: number?)
                        local filter, remapped_string = matcher(value)
                        if filter then
                              return if remapped_string then remapped_string else filter
                        end
                        return false
                  end)
            end
            error("LinkedList: provided matcher must be a string (string pattern) or function")
      end

      type yourFilterFunction <RType> = (value: any, index: number?, result_object: RType?) -> (any)

      --- Combines or reduces all values in your List into a single value--you decide. default operations: string: `..=`, number: `+=`, {array}: append `v`
      function ListInstance.collect <ReturnType> (self: List, into: ReturnType, reducer: yourFilterFunction <ReturnType>? ) : ReturnType
            reducer = reducer or function(v)
                  return v
            end
            assert(reducer, "LinkedList TypeError: invalid reduction/collection function.")

            self:each(function(v, index)
                  local result = reducer(v, index, into)
                  if not result then return end 

                  if typeof(into) == "string" then
                        into  ..= result
                  elseif typeof(into) == "number" then
                        into += result
                  elseif typeof(into) == "table" then
                        into[#into + 1] = result
                  end
            end)
            
            return into
      end
      --- returns sum of all elements. Assumes LinkedList[numbers]
      function ListInstance.sum(self: List): number
            return self:collect(0)
      end

      -- note, this is a sort in place!
      function ListInstance.sort(self: List, sort_by : ((a: any, b: any) -> (boolean))?): List
            local default_sort = function(a: number, b: number) return b > a end
            sort_by = sort_by or default_sort
            assert(sort_by, "")
            local prev : Node?
            
            -- just your average overnegineered recursive sort alg
            local changes = 0
            local curr_index, succ_index = 0, 1
            while succ_index < self.length do
                  local curr, succ = self:__get_node(curr_index), self:__get_node(succ_index)
                  assert(curr, self:string())
                  assert(succ, self:string())
                  if curr.value ~= succ.value and not sort_by(curr.value, succ.value) then
                        -- print(curr.value, "switching with", succ.value)
                        if prev then
                              prev.next = succ
                              curr.next = succ.next
                              succ.next = curr
                        else
                              self.head = succ
                              self.first = succ.value
                              curr.next = succ.next
                              succ.next = curr
                        end
                        changes += 1
                  end
                  prev = self:__get_node(curr_index)
                  curr_index += 1; succ_index += 1
            end
           
            if changes > 0 then
                  return self:sort(sort_by)
            else
                  return self
            end
      end

      --- maps an array of [key, value] pairs into a dictionary
      function ListInstance.table(self: List, breakup: ((key : any, value : any) -> (any, any))?)
            local result = {}
            breakup = breakup or function(k, v)
                  return k, v
            end
            assert(breakup, "splitting function must be provided")
            self:each(function(pair, index)
                  local new_key, new_value = breakup(pair[1], pair[2])
                  result[new_key] = new_value
            end)
            return result
      end

      function ListInstance.mappairs(self: List, map: (key: any, value: any) -> (any?, any?))
            return self:map(function(value, index)
                  local new_key, new_value = map(value[1], value[2])
                  if new_key and new_value then
                        return {new_key, new_value}
                  end
                  return nil
            end)
      end

      function ListInstance.map_values(self: List, map: (key: any, value: any) -> (any))
            return self:map(function(value, index)
                  local k, v = unpack(value)
                  local new_v = map(k, v)
                  if new_v then
                        return {k, map(k, v)}
                  end
                  return nil
            end)
      end

      --[=[
            Allows you to remap the array values in a `LinkedList[key, array]`.
            ```lua
            local arrays_by_key = {
                  part1 = {0, 1, 2, 3, 4},
                  part2 = {5, 5, 6, 9}
            }
            local remapped = List.frompairs(arrays_by_key):remap_array_values(function(v, array_index, key)
                  return v + 2
            end)
            ```

            the array portion can be a regular {array} or another LinkedList!
      ]=]
      function ListInstance.remap_array_values(self: List, map: (value_in_value: any, inner_key: any, outer_key: any) -> (any)) : List
            return self:map(function(value, index)
                  local key, vals = unpack(value)
                  assert(vals, `vals nil, key {key}, {value}, {index}`)
                  if vals["length"] == nil then -- is an {arraylike} 
                        local new_value = {}
                        for inner_key, val_in_vals in vals do
                              local remapped_val = map(val_in_vals, inner_key, key)
                              if remapped_val then
                                    table.insert(new_value, remapped_val)
                                    -- new_value[inner_key] = remapped_val
                              end
                        end
                        return {key, new_value}
                  else
                        local new_value : List = vals 
                        return {key, new_value:map(function(val_in_val, inner_key)
                              return map(val_in_val, inner_key, key)
                        end)}
                  end
            end)
      end


      -- function ListInstance.__index(self, target_index)
      --       ListInstance.__index = ListInstance
      --       return ListInstance
      -- end

      -- function ListInstance.__index(self : List, target_index : string | number | {number}) : any
      --       if typeof(target_index) == "number" then
      --             print(self)
      --             if target_index >= self.length then
      --                   return nil -- index out-of-bounds
      --             end
      --             local index_current = 0
      --             local node_current = self.head :: Node
      --             while index_current < target_index do
      --                   index_current += 1
      --                   if node_current.next then
      --                         node_current = node_current.next
      --                   else
      --                         return nil
      --                   end
      --             end
      --             return node_current.value
      --       elseif typeof(target_index) == "table" then
      --             print("LinkedList[{number}] not implemented yet")
      --       end
      --       return rawget(getmetatable(self), target_index)
      -- end
      function ListInstance.__len(self : List)
            return self.length
      end

return List