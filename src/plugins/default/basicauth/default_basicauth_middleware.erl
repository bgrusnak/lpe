-module(default_basicauth_middleware).

-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req, Env) ->    
%io:format("Call middleware ~p~n",[Env]),	
    {ok, Req, Env}
.
