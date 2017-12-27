-module(options).

-export([get/1, get/2, set/2, tree/0, defineDefaultValue/1, defineDefaultValue/2, treePage/2]).


get(Key) ->
    get(Key, undefined)
.

get(KeyGroup, Default) ->
    [Key, Group] = case KeyGroup of
        [_,_] -> KeyGroup;
        _ -> [KeyGroup, <<>>]
    end,
    Connection=db:connection(),
    SelectRes = epgsql:equery(Connection,
        "select value from \"options\" where \"name\" = $1 AND \"group\" = $2 order by updated DESC LIMIT 1", 
        [Key, Group]),
    case SelectRes of
        {ok, _, [{Data}]} -> 
            case jsx:is_json(Data) of
                true -> jsx:decode(Data);
                false -> Data
            end;
        {ok, _, []} -> Default;
        {error, _} -> Default
    end
.

set(KeyGroup, Value) ->
        [Key, Group] = case KeyGroup of
        [_,_] -> KeyGroup;
        _ -> [KeyGroup, <<>>]
    end,
    Connection=db:connection(),
    epgsql:equery(Connection,
    "INSERT INTO \"options\" (\"name\", \"group\", \"value\") VALUES ($1, $2, $3)", 
    [Key, Group, jsx:encode(Value)
    ])
.

tree() ->    
    Got= db:chain([
        #{name => tree, 'query' => "select * from optionslist ORDER BY \"group\" asc, \"order\" asc, name asc", params => []},
        #{name => groups, 'query' => "select * from optionsgroups ORDER BY name asc", params => []}
    ]),
    GotGroups = case maps:get(groups, Got) of
        [] -> [];
        Any -> lists:map(fun(Row) ->
                lists:append(Row,  [{items, []}])
            end, Any)
    end,
    DefaultGroup = [{<<"name">>, <<>>}, {<<"title">>, <<"Other settngs">>}, {items, []}, {<<"order">>, 255}],
    Groups = lists:append([DefaultGroup], GotGroups),
    Tree = case maps:get(tree, Got) of
        [] -> [];
        Any2 -> Any2
    end,
    Folded = lists:foldl(fun(Item, Set) -> 
        Default = defineDefaultValue(<<"string">>, proplists:get_value(<<"options">>, Item)),
        Value = get([proplists:get_value(<<"name">>, Item), proplists:get_value(<<"group">>, Item)], Default),
        VItem = lists:append(Item,  [{<<"value">>, Value}]),
        setGroupItem(Set, VItem)
    end, Groups, Tree),
    lists:sort(fun(A,B)->
        proplists:get_value(<<"order">> ,A,255) =< proplists:get_value(<<"order">> ,B,255)
    end, Folded)
.

setGroupItem([Group|Tail], Item) ->
    GI= case proplists:get_value(<<"group">>, Item) of 
        null -> <<>>;
        F -> F
    end,
    GN = proplists:get_value(<<"name">>, Group),
    case (GI == GN) of
        true -> 
            Items = proplists:get_value(items, Group),
            NewItems = lists:append(Items,  [Item]),
            NewGroup = lists:keystore(items, 1, Group, {items, NewItems}),
            [NewGroup|Tail]
        ;
        _ -> [Group | setGroupItem(Tail, Item)]
    end
;

setGroupItem([], _) ->
    []
.

defineDefaultValue(Type) ->
    defineDefaultValue(Type, [])
.

defineDefaultValue(<<"string">>, Options) ->
    proplists:get_value(<<"default">>, Options,<<"">>)
;

defineDefaultValue(<<"number">>, Options) ->
        proplists:get_value(<<"default">>, Options,<<"0">>)
;

defineDefaultValue(<<"media">>, Options) ->
        proplists:get_value(<<"default">>, Options,<<"">>)
;

defineDefaultValue(<<"date">>, Options) ->
        proplists:get_value(<<"default">>, Options,<<"1980-01-01">>)
;

defineDefaultValue(<<"time">>, Options) ->
        proplists:get_value(<<"default">>, Options,<<"00:00">>)
;

defineDefaultValue(<<"datetime">>, Options) ->
        proplists:get_value(<<"default">>, Options,<<"1980-01-01 00:00">>)
;

defineDefaultValue(_, Options) ->
        proplists:get_value(<<"default">>, Options,<<"">>)
.

treePage(_,_) ->
    Gallery = db:execute(gallery," select * from  \"library\" ORDER by filename", []),
    Options = tree(),
    [{settings, Options}, {library, maps:get(gallery, Gallery)}]
.