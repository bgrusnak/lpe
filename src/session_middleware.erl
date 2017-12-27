-module(session_middleware).

-behaviour(cowboy_middleware).

-export([execute/2]).

-define(SESSION, <<"session">>).
-define(SESSION_AGE, 60*60*24).

execute(Req, Env) ->    
        Cookies = cowboy_req:parse_cookies(Req),
        SessionId = proplists:get_value(?SESSION, Cookies, uuid:uuid_to_string(uuid:get_v4())),
        Req1 = cowboy_req:set_resp_cookie(?SESSION, SessionId, Req,
        #{max_age => ?SESSION_AGE, path => "/admin"}),
io:format("Call middleware ~p~n",[Req]),	
    {ok, Req1, Env}
.
