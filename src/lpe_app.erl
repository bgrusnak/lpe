%%%-------------------------------------------------------------------
%% @doc lpe public API
%% @end
%%%-------------------------------------------------------------------

-module(lpe_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).



%%====================================================================
%% API
%%====================================================================


start(_StartType, _StartArgs) ->
    db:start_link(),
    sync:go(),
    cowboy_session:start(),
    application:start(fast_xml),
    sync:onsync(fun(Mods) ->
        cowboy:set_env(http_listener, dispatch, makeDispatch()),
        io:format("Reloaded Modules: ~p~n",[Mods]) 
    end),
    {ok, _} = cowboy:start_clear(http_listener,
        [{port, 8080}],
        #{
            env => #{dispatch => makeDispatch()},
            middlewares => generate_middlewares()
        }
    ),
    lpe_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

generate_middlewares() ->
        MW = db:execute(middlewares," select * from  \"middlewares\" WHERE \"enabled\" ORDER by \"order\"", []),
        Middlewares = lists:map(fun(A) -> 
            list_to_atom(binary_to_list(proplists:get_value(<<"function">>,A)))
        end, maps:get(middlewares, MW)),
        lists:append([[cowboy_session], Middlewares, [ cors_middleware, cowboy_router,cowboy_handler]])
.
 
processHandlersWithPath(Path) ->
    {State, Value} = file:list_dir(Path),
    case State of
        ok -> 
            lists:map(fun(File) ->
                Module=list_to_atom(filename:rootname(filename:basename(File))),
                apply(Module, desc, [])
            end, lists:sort(fun(A,B)->
                A < B
            end, Value));
        _ -> []
    end
.

processHandlers() ->
    {State, Value} = file:get_cwd(),
    Rt=case State of
        ok -> processHandlersWithPath(filename:absname_join(Value, "src/handlers" ));
        _ -> []
    end,
    lists:flatten(Rt)
.

makeDispatch() ->
    SHandlers = lists:sort(fun(A,B) -> 
            ALast = maps:get(order,A, 0),
            BLast = maps:get(order,B, 0),
            ALast < BLast 
        end, processHandlers()),
    Handlers = lists:map(fun(A)-> maps:get(handle,A) end, SHandlers),
    cowboy_router:compile([
		{'_', 
		    lists:append(
                Handlers, 
                [
                    {"/static/[...]", cowboy_static, {priv_dir, lpe, "static"}}
                ]
            )	
		}
	])
    %    
.

