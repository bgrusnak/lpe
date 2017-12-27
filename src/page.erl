-module(page).

-export([get/1, get/2, set/3, breadcrumbs/1]).

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
