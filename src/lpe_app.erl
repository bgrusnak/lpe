%%%-------------------------------------------------------------------
%% @doc lpe public API
%% @end
%%%-------------------------------------------------------------------

-module(lpe_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).


processHandlersWithPath(Path) ->
    {State, Value} = file:list_dir(Path),
    case State of
        ok -> 
            lists:map(fun(File) ->
                Module=list_to_atom(filename:rootname(filename:basename(File))),
                apply(Module, desc, [])
            end, Value);
        _ -> []
    end
.

processHandlers() ->
    {State, Value} = file:get_cwd(),
    case State of
        ok -> processHandlersWithPath(filename:absname_join(Value, "src/handlers" ));
        _ -> []
    end
.

makeDispatch() ->
    cowboy_router:compile([
		{'_', 
		    lists:append(
                processHandlers(), 
                [
                    {"/static/[...]", cowboy_static, {priv_dir, lpe, "static"}}
                ]
            )	
		}
	])
    %    
.


%%====================================================================
%% API
%%====================================================================


start(_StartType, _StartArgs) ->
    io:format("~p~n", [env:get(test, "NOT TEST")]),
    io:format("~p~n", [application:get_all_env()]),
    sync:go(),
    sync:onsync(fun(Mods) ->
        cowboy:set_env(http_listener, dispatch, makeDispatch()),
        io:format("Reloaded Modules: ~p~n",[Mods]) 
    end),
    {ok, _} = cowboy:start_clear(http_listener,
        [{port, 8080}],
        #{
            env => #{dispatch => makeDispatch()},
            middlewares => [cowboy_router, cors_middleware, cowboy_handler]
        }
    ),
    lpe_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
