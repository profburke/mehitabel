import CLua

struct LuaState {
    let L: OpaquePointer

    init(withLibs: Bool = true) {
        L = luaL_newstate()
        if withLibs {
            luaL_openlibs(L)
        }
    }

    func eval(script: String) -> String {
        luaL_loadstring(L, script)
        lua_pcallk(L, 0, LUA_MULTRET, 0, 0, nil)
        let result = String(cString: lua_tolstring(L, -1, nil))
        return result
    }
}
