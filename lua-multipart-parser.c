#define LUA_LIB
#include <lauxlib.h>
#include <lualib.h>
#include <string.h>
#include "multipart_parser.h"

int read_header_name(multipart_parser* p, const char* at, size_t length)
{
	//printf(">>%.*s: ", (int)length, at);
	lua_State* L = multipart_parser_get_data(p);
	lua_createtable(L, 0, 2);
	lua_pushlstring(L, at, length);
	lua_setfield(L, -2, "key");
	return 0;
}

int read_header_value(multipart_parser* p, const char* at, size_t length)
{
	lua_State* L = multipart_parser_get_data(p);
	lua_pushlstring(L, at, length);
	lua_setfield(L, -2, "value");
	int i = lua_tointeger(L, -2);
	lua_settable(L, -3);
	lua_pushinteger(L, i + 1);
	//printf("%.*s\n", (int)length, at);
	//printf("------------------------------\n");
	return 0;
}

int read_part_data(multipart_parser* p, const char* at, size_t length)
{
	lua_State* L = multipart_parser_get_data(p);
	//弹出数组序号
	lua_pop(L, 1);
	lua_setfield(L, -2, "headers");
	lua_pushlstring(L, at, length);
	lua_setfield(L, -2, "data");
	//printf(">>%.*s\n", (int)length, at);
	//printf("------------------------------\n");
	return 0;
}


static int lparse(lua_State* L)
{
	size_t sz = 0;
	const char* boundary = luaL_checklstring(L, 1, &sz);
	if (!boundary)
		return luaL_error(L, "Invalid boundary");

	size_t len = 0;
	const char* body = luaL_checklstring(L, 2, &len);
	if (!body)
		return luaL_error(L, "Invalid body");

	multipart_parser_settings callbacks;
	memset(&callbacks, 0, sizeof(multipart_parser_settings));
	callbacks.on_header_field = read_header_name;
	callbacks.on_header_value = read_header_value;
	callbacks.on_part_data = read_part_data;

	multipart_parser* parser = multipart_parser_init(boundary, &callbacks);
	lua_createtable(L, 0, 2);
	// headers数组
	lua_createtable(L, 0, 0);
	// 数组序号
	lua_pushinteger(L, 1);
	multipart_parser_set_data(parser, L);

	multipart_parser_execute(parser, body, len);
	multipart_parser_free(parser);
	return 1;
}

LUAMOD_API int
luaopen_multipart_parser(lua_State* L)
{
	struct luaL_Reg lib[] = {
		{"parse", lparse},
		{NULL, NULL} };
	luaL_newlib(L, lib);
	return 1;
}