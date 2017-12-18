-module(env).
-define(APPLICATION, lpe).
-export([get/2, set/2]).

get(Key, Default) ->
    application:get_env(?APPLICATION, Key, Default)
.

set(Key, Value) ->
    application:set_env(?APPLICATION, Key, Value).