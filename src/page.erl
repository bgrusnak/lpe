-module(page).

-export([get/1, get/2, set/3, breadcrumbs/1, menu/1, chips/1]).

get(Page) ->
    get(Page, [])
.

get(Page, Default) ->
    Got= db:execute(page,"select * from \"pages\" where \"path\" = $1 order by \"path\" DESC, updated DESC LIMIT 1", 
    [Page]),
    case maps:get(page, Got) of
        [] -> Default;
        [Any] -> Any
    end
.

set(Page, Name, Value) ->
    {_, Data} = db:execute(undefined,"select * from \"pages\" where \"path\" = $1 order by updated DESC LIMIT 1", 
    [Page]),
    NewData = lists:keystore(Name, 1, Data, {Name, Value}),
%    db:execute(undefined,
%    "INSERT INTO \"pages\" (\"path\", \"template\", \"title\", titledesc, \"plugins\", \"script\", \"styles\", \"options\", \"function\""") VALUES ($1, $2, $3, $4, $5, $6, $7, $8)", 
%    [proplists:get_value()
%    ])
erlang:display(NewData)
.

breadcrumbs(Path) ->
    Got= db:execute(page,"select path as uri, title from pages where  $1 ~ (path || '.*') ORDER BY path asc", 
    [Path]),
    case maps:get(page, Got) of
        [] -> [];
        Any -> Any
    end
.

menu(Parent) ->
    Got = case maps:get(page, db:execute(page,"select * from menu order by parent_id ASC NULLS FIRST, \"order\" ASC NULLS LAST", [])) of
        [] -> [];
        Any -> Any
    end,
    Tops = lists:filter(fun(Curr)-> 
            case proplists:get_value(<<"parent_id">>, Curr) of
                null -> true;
                _ -> false
            end
    end, Got ),
    lists:map(fun(Curr) ->
        Id =  proplists:get_value(<<"id">>, Curr),
        Path = proplists:get_value(<<"path">>, Curr),
        Childed = lists:append(Curr, [{<<"childs">>, lists:map(fun(Ch)-> 
                CPath = proplists:get_value(<<"path">>, Ch),
                lists:keyreplace(<<"path">>, 1, Ch, {<<"path">>, << Parent/binary, "/", Path/binary, "/", CPath/binary >>})
            end, lists:filter(fun(Ch)->
            case proplists:get_value(<<"parent_id">>, Ch) of
               Id -> true;
                _ -> false
            end
        end, Got))}]),
        lists:keyreplace(<<"path">>, 1, Childed, {<<"path">>, << Parent/binary, "/", Path/binary >> })
    end, Tops)
.

chips(Req) ->
    Chips = case maps:get(page, db:execute(page,"select * from chips", [])) of
        [] -> [];
        Any -> Any
    end,
    lists:map(fun(Chip)->
        {proplists:get_value(<<"name">>, Chip), apply(list_to_atom(binary_to_list(proplists:get_value(<<"module">>, Chip))), list_to_atom(binary_to_list(proplists:get_value(<<"function">>, Chip))), [Req])}
    end, Chips)
.
