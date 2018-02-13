-module(admin_handler).

-include("include/constants.hrl").

-export([desc/0]).
-export([init/2]).

desc() ->
    [
        #{handle => {"/admin/[...]", ?MODULE, []}, order => 1}
    ]    
.
init(Req0, Opts) ->
    Path = "/admin/"++string:join(lists:map(fun(B) ->
        binary_to_list(B)
    end, cowboy_req:path_info(Req0)), "/"),
    Page=page:get(Path, [
        {<<"template">>, <<"error-404.html">>},
        {<<"plugins">>, []},
        {<<"script">>, <<"">>},
        {<<"styles">>, []},
        {<<"options">>, []}
    ]),
    Source=binary_to_list(proplists:get_value(<<"template">>, Page)),
    Template=list_to_atom(filename:basename(Source)++"_template"),
    erlydtl:compile_file("priv/static/admin/"++Source, Template, [{force_recompile, true}]),
    Data = case proplists:get_value(<<"function">>, Page, []) of
        [] -> [];
        [Module, Function] -> apply(list_to_atom(binary_to_list(Module)), 
            list_to_atom(binary_to_list(Function)), 
            [Req0, Page]);
        [Function2] ->apply(list_to_atom(binary_to_list(Function2)),  [Req0, Page]);
        Function3 ->apply(list_to_atom(binary_to_list(Function3)),  [Req0, Page])
    end,
    {_,Rendered} = Template:render(lists:append(Data, [{page,Page}, {menu, page:menu(<<"/admin">>)}, {breadcrumbs, page:breadcrumbs(Path)}])),
	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/html">>
	}, Rendered, Req0),
	{ok, Req, Opts}.