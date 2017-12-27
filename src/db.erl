-module(db).

-behaviour(gen_server).

-export([connection/0]).
-export([process/2]).
-export([chain/1]).
-export([execute/3]).



-export([start_link/0]).


-export([init/1, handle_call/3, handle_cast/2]).


init(_Args) ->
    {ok, dict:new()}.


start_link() ->
    gen_server:start_link({local, db}, db, [], []).

connection() ->
    gen_server:call(db, connection).
    
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_call(connection, _From, State) ->
    case dict:find(db_connection, State) of
        error -> 
            {ok, C} = epgsql:connect("localhost", "lpe", "lpe", [
                {database, "lpedb"},
                {timeout, 4000}
            ]),
            NewState = dict:store(db_connection, C, State),
            {reply, C, NewState};
        {ok, Found} ->  
            {reply, Found, State}
    end;

handle_call(_Request, _From, State) ->
        Reply = ok,
        {reply, Reply, State}.



process(Cols, Data) ->
    CL=lists:map(fun(F) ->
        [column, N | _ ] = erlang:tuple_to_list(F),
        N
    end, Cols),
    lists:map(fun(X)-> 
        L=erlang:tuple_to_list(X),
        lists:map(fun({T,V}) ->
            case jsx:is_json(V) of
                true -> {T, jsx:decode(V)};
                false -> {T,V}
            end
        end,lists:zip(CL, L))
    end, Data)
.

execute(Name, Query, Params) ->
    Got = epgsql:equery(connection(), Query, Params),
    case Got of
        {ok, Answer} -> 
            #{Name => Answer};
        {ok, _, []} -> 
            #{Name => []};
        {ok, BCols, BData} -> 
            #{Name => process(BCols, BData)};
        {ok, _, BCols, BData} -> 
            #{Name => process(BCols, BData)};
        {error, {_,_,_,_,Reason,_}} ->
            #{Name => <<"Error:", Reason/binary >>}
    end
.

chain([#{name := Name, 'query' := Query, params := Params}|T]) ->
        maps:merge(execute(Name, Query, Params), chain(T))
    ;
chain([#{'query' := Query, params := Params}|T]) ->
        execute(undefined, Query, Params), 
        chain(T)
    ;
chain([]) ->
    #{}
.