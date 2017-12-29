-module(default_basicauth_middleware).

-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req, Env) ->    
    Path = binary:split(cowboy_req:path(Req), <<"/">>, [global,trim_all]),
    case Path of
        [<<"admin">>, <<"login">> | _ ] -> validate_auth(Req, Env);
        [<<"admin">> | _ ] -> check_auth(Req, Env);
        _ -> {ok, Req, Env}
    end
.

check_auth(Req, Env) ->
    {Ss, _} = cowboy_session:get(authentified, false, Req),
    case cowboy_session:get(authentified, false, Req) of
        {true, _} -> {ok, Req, Env};
        _ -> {stop,  cowboy_req:reply(303, #{
            <<"location">> => <<"/admin/login">>
        }, Req)}
    end
.

validate_auth(Req, Env) ->   
    Query = cowboy_req:parse_qs(Req),
    Username = proplists:get_value(<<"username">>, Query, undefined),
    Password = proplists:get_value(<<"password">>, Query, undefined),
    Remember = proplists:get_value(<<"remember">>, Query, undefined),
    L=options:get([<<"login">>, <<"access">>]),
    P = options:get([<<"password">>, <<"access">>]),
    case Remember of
        undefined -> ok ;
        _ -> cowboy_session_config:set([{expire, 60*60*24*30}])
    end,
    case {Username, Password} of 
        {undefined, _} ->{ok, Req, Env};
        {_,undefined} ->{ok, Req, Env};
        {L, P} ->  
            {ok, Req1} = cowboy_session:set(authentified, true, Req),
            {stop,  cowboy_req:reply(303, #{
                <<"location">> => <<"/admin">>
            }, Req1)}
        ;
        _ -> {ok, Req, Env}
    end
.