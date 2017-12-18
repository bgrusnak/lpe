-module(basic_handler).

-include("include/constants.hrl").

-export([desc/0]).
-export([init/2]).

desc() ->
        {"/", ?MODULE, []}
    .
    
init(Req0, Opts) ->
    Template = list_to_atom(?TEMPLATE++"_template"),
    erlydtl:compile_file("priv/static/themes/"++?TEMPLATE++"/index.html", Template, [{force_recompile, true}]),
    {_,Rendered} = Template:render([]),

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/html">>
	}, Rendered, Req0),
	{ok, Req, Opts}.