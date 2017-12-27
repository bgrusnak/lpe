-module(admin_inbox_handler).

-include("include/constants.hrl").

-export([desc/0]).
-export([init/2]).

desc() ->
    [
        #{handle => {"/admin/inbox", ?MODULE, []}, order => 0}
    ]
.
    
init(Req0, Opts) ->
    Page= [
        {<<"template">>, <<"inbox.html">>},
        {<<"plugins">>, []},
        {<<"script">>, <<"">>},
        {<<"styles">>, []},
        {<<"options">>, []}
    ],
    Source=binary_to_list(proplists:get_value(<<"template">>, Page)),
    Template=list_to_atom(filename:basename(Source)++"_template"),
    erlydtl:compile_file("priv/static/admin/"++Source, Template, [{force_recompile, true}]),
    {_,Rendered} = Template:render([{page,Page}]),

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/html">>
	}, Rendered, Req0),
	{ok, Req, Opts}.