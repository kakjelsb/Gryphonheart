﻿local __Foreach = function(obj)
    if type(obj) == 'table' and obj.GetEnumerator then
        return obj.GetEnumerator();
    end
    return pairs(obj);
end
local function SetAddMeta(f)
    local mt = { __add = function(self, b) return f(self[1], b) end }
    return setmetatable({}, { __add = function(a, _) return setmetatable({ a }, mt) end })
end
local add = SetAddMeta(function(a, b)
    assert(a and b, "Add called on a nil value.");
    if type(a) == "number" and type(b) == "number" then return a + b; end
    return tostring(a)..tostring(b);
end);

local __not = setmetatable({}, { __add = function(_, value)
    return not(value);
end});

local __GetByFullName = function(s)
    local n = {string.split(".",s)};
    local o = _G[n[1]];
    assert(o,"Could not find global "..s)
    for i=2,#(n) do
        o = o[n[i]];
        assert(o,"Could not find global "..s)
    end
    return o;
end
local __IsType = function(obj, t)
    if type(obj) == "table" then
        if obj.__IsType then
            return obj.__IsType(t);
        elseif type(obj.GetType) == "function" then
            return obj:GetType() == t;
        end
    end
    if type(obj) == "boolean" then
        return "bool" == t;
    elseif type(obj) == "function" then
        return "Action" == t;
    elseif type(obj) == "number" then
        return "double" == t or "int" == t;
    elseif type(obj) == "string" then
        return t == "string";
    elseif type(obj) == "nil" then
        return true;
    end
    return error("Unknown type handling "..type(obj));
end
local __AmbiguousFunction = function(...)
    local t = {...};
    local i = 1;
    local funcs = {};

    while (i + 1 <= #(t)) do
        table.insert(funcs,{
            types = t[i],
            func = t[i + 1]
        });
        i = i + 2;
    end
            
    return function(...)
        local argCount = select('#', ...);
        local types = {};
        local matches = funcs;
                
        for i=1, argCount do
            local newMatches = {};
            local obj = select(i, ...);

            for _,match in ipairs(matches) do
                if (match.types[i] and __IsType(obj, match.types[i])) then
                    table.insert(newMatches, match);
                end 
            end
            matches = newMatches;

            if (#(matches) == 1) then
                return matches[1].func(...);
            end
        end
        local matchingNumberOfArgs = {};
        for _,func in ipairs(funcs) do
            if (#(func.types) == argCount) then
                table.insert(matchingNumberOfArgs, func);
            end
        end

        if (#(matchingNumberOfArgs) == 1) then
            return matchingNumberOfArgs[1].func(...);
        end
                
        error("No match found for ambiguous function matching the "..argCount.." given arguments.");
    end

end

local __Throw = function(exception)
    __CurrentException = exception;
    error(exception.ToString(), 2);
end
-- TODO: Try Catch Finaly func

local __EnumParse = function(typeName, value)
    local enumTable = __GetByFullName(typeName);
    for i,v in pairs(enumTable) do
        if string.lower(value) == string.lower(i) then
            return v;
        end
    end
    __Throw(CsLua.CsException("Could not parse enum value " .. tostring(value) .. " into " .. typeName));
end

local __CreateClass = function(info) -- fullName, name, getElements, inherits, implements, isStatic, isIndexer, isDictionary, isSerializable
    local staticValues;

    local initializeStaticElements = function()
        if staticValues then
            return;
        end

        staticValues = {};
        local elements = info.getElements(staticValues);

        for _, element in pairs(elements) do
            if (element.static) then
                staticValues[element.name] = element.value;
            end
        end
    end

    local initializeClass = function(generic, overridingClass)
        local class = {};
        local _, inheritiedClass, populateOverride;
        if info.inherits then
            _, inheritiedClass, populateOverride = __GetByFullName(info.inherits)(generic);
            if _ and not(inheritiedClass) then
               inheritiedClass = _;
            end
        end

        local indexerValues, dictionaryValues;
        if info.isIndexer then indexerValues = {}; end
        if info.isDictionary then dictionaryValues = {}; end
        local nonStaticValues = {};

        local elements = info.getElements(overridingClass or class);
        
        local generics;
        local methods, nonStaticVariables, staticVariables, staticGetters, nonStaticGetters, staticSetters, nonStaticSetters = {}, {}, {}, {}, {}, {}, {};
        local constructor, serialize, deserialize;
        local overrides = {};
        
        for _, element in pairs(elements) do
            if (element.type == "Method") then
                methods[element.name] = element;
                if (element.override == true) and inheritiedClass then
                    overrides[element.name] = element.value;
                end
            elseif (element.type == "Variable") then
                if (element.static) then
                    staticVariables[element.name] = element;
                else
                    nonStaticVariables[element.name] = element;
                end
            elseif (element.type == "PropertyGet") then
                if (element.static) then
                    staticGetters[element.name] = element;
                else
                    nonStaticGetters[element.name] = element;
                end
            elseif (element.type == "PropertySet") then
                if (element.static) then
                    staticSetters[element.name] = element;
                else
                    nonStaticSetters[element.name] = element;
                end
            elseif (element.type == "Serialization") then
                if (element.name == "serialize") then
                    serialize = element;
                elseif (element.name == "deserialize") then
                    deserialize = element;
                else
                    error("Unknown Serialization element: "..tostring(element.name));
                end
            elseif (element.type == "Constructor") then
                constructor = element;
            else
                error("Unhandled element type: "..tostring(element.type));
            end
        end
        
        local meta = {};
        meta.__Initialize = function(t) for i, v in pairs(t) do class[i] = v; end  return class; end
        meta.__type = info.name;
        if (serialize) then
            meta.serialize = serialize.value;
        end
        meta.__fullTypeName = info.fullName;
        meta.__IsType = function(t) 
            if t == info.name or t == info.fullName then
                return true;
            end
            for _,v in pairs(info.implements or {}) do
                if t == v then
                    return true;
                end
            end
            if inheritiedClass then
                return inheritiedClass.__IsType(t);
            end
            return false;
        end;
        meta.__GetOverrides = function()
            return overrides;
        end

        if not(staticValues) then
            staticValues = {}
            for i, v in pairs(staticVariables) do
                staticValues[i] = v.value;
            end
        end
        for i,v in pairs(nonStaticVariables) do
            nonStaticValues[i] = v.value;
        end
        for i,v in pairs(nonStaticGetters) do
            if not(type(v.value) == "function") then
                nonStaticValues[i] = v.value;
            end
        end        

        meta.__Cstor = function(...)
            local args = {...};
            if #(args) == 1 and (args[1]) == "table" and args[1].GetValue then
                if (inheritiedClass) then
                    inheritiedClass.__Cstor(args[1]);
                end
                deserialize.value(args[1]);
            else
                if constructor then
                    constructor.value(...);
                elseif inheritiedClass then
                    inheritiedClass.__Cstor(...);
                end
            end
            return class;
        end

        setmetatable(class, {
            __index = function(_, key)
                if type(key) == "number" and info.isIndexer then
                    return indexerValues[key];
                elseif meta[key] then
                    return meta[key];
                elseif key == "__base" then
                    return inheritiedClass;
                elseif methods[key] then 
                    return methods[key].value;
                elseif nonStaticVariables[key] then 
                    return nonStaticValues[key];
                elseif staticVariables[key] then 
                    return staticValues[key];
                elseif staticGetters[key] then 
                    if type(staticGetters[key].value) == "function" then
                        return staticGetters[key].value();
                    end
                    return staticValues[key];
                elseif nonStaticGetters[key] then 
                    if type(nonStaticGetters[key].value) == "function" then
                        return nonStaticGetters[key].value();
                    end
                    return nonStaticValues[key];
                elseif not(inheritiedClass) and (nonStaticSetters[key] or staticSetters[key]) then
                    error("Cannot get value for setter that is defined without a getter");
                elseif info.isDictionary then
                    return dictionaryValues[key];
                elseif inheritiedClass then
                    return inheritiedClass[key];
                end
            end,
            __newindex = function(_, key, value)
                if type(key) == "number" and info.isIndexer then
                    indexerValues[key] = value;
                elseif meta[key] then
                    error("Cannot assign value to "..tostring(key));
                elseif methods[key] then 
                    error("Cannot assign value to method field "..tostring(key));
                elseif nonStaticVariables[key] then 
                    nonStaticValues[key] = value;
                elseif staticVariables[key] then 
                    staticValues[key] = value;
                elseif staticSetters[key] then 
                    if type(staticSetters[key].value) == "function" then
                        staticSetters[key].value(value);
                    else
                        staticValues[key] = value;
                    end
                elseif nonStaticSetters[key] then 
                    if type(nonStaticGetters[key].value) == "function" then
                        nonStaticGetters[key].value(value);
                    else
                        nonStaticValues[key] = value;
                    end
                elseif not(inheritiedClass) and (nonStaticGetters[key] or staticGetters[key]) then
                    error("Cannot set value for getter that is defined without a setter");
                elseif info.isDictionary then
                    dictionaryValues[key] = value;
                elseif inheritiedClass then
                    inheritiedClass[key] = value;
                end
            end,
        });      

        return class, populateOverride;
    end

    local ClassWithOverride = function(generic)
        local overriddenClass = {};
        local class, populateParentOverrides = initializeClass(generic, overriddenClass);

        local overrides;

        local populateOverrides = function()
            if populateParentOverrides then
                overrides = populateParentOverrides();
            else
                overrides = {};
            end

            local ownOverrides = class.__GetOverrides();
            for i,v in pairs(ownOverrides) do
                overrides[i] = v;
            end

            return overrides;
        end

        setmetatable(overriddenClass, {
            __index = function(_, key)
                if overrides == null then
                    populateOverrides();
                end
                if overrides[key] then
                    return overrides[key];
                end
                return class[key];
            end,
            __newindex = function(_, key, value)
                class[key] = value;
            end,
        });

        return overriddenClass, class, populateOverrides;
    end

    local namespaceElement = {};
    if (info.isStatic) then
        local staticClass = nil;
        local Init = function()
            if staticClass == nil then
                staticClass = initializeClass().__Cstor();
            end
        end

        setmetatable(namespaceElement, {
            __index = function(_, key)
                Init();
                return staticClass[key];
            end,
            __newindex = function(_, key, value)
                Init();
                staticClass[key] = value;
            end,
        });
    else
        setmetatable(namespaceElement, {
            __call = function(_, ...)
                return ClassWithOverride(...);
            end,
            __index = function(_, key)
                initializeStaticElements();
                return staticValues[key];
            end,
            __newindex = function(_, key, value)
                initializeStaticElements();
                staticValues[key] = value;
            end,
        });
    end

    return namespaceElement;
end

local __Struct = function(typeName, implements)
    local __IsType = function(t) 
        if t == typeName then
            return true;
        end
        for _,v in pairs(implements or {}) do
            if t == v then
                return true;
            end
        end
        return false;
    end; 

    local t;
    t = {
        __IsType = __IsType,
        __Cstor = function()
            return t;
        end,
        __Initialize = function(values)
            values.__IsType = __IsType;
            return values;
        end
    };
    
    return function() return t; end;
end

