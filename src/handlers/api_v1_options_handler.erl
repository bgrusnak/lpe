-module(api_v1_options_handler).

-include("include/constants.hrl").

-export([desc/0]).
-export([init/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([resource_exists/2]).
-export([get_handle/2]).
-export([allowed_methods/2]).
-export([post_handle/2]).

desc() ->
    [
        #{handle => {"/api/v1/options", ?MODULE, []}, order => 0}
    ]
.

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
		{[<<"GET">>, <<"POST">>, <<"PUT">>, <<"HEAD">>, <<"OPTIONS">>, <<"DELETE">>], Req, State}.

content_types_provided(Req, State) ->
	{[
		{<<"application/json">>, get_handle}
	], Req, State}.


content_types_accepted(Req, State) ->
	{[{<<"application/json">>, post_handle}], Req, State}.

resource_exists(Req, State) ->
    {true, Req, State}.

post_handle(Req, State) ->
        {ok, EncBody, _} = cowboy_req:read_body(Req),
        Body = jsx:decode(EncBody, [{labels, attempt_atom}, return_maps]),
        lists:foreach(fun(Item)->
            options:set([maps:get(key, Item), maps:get(group, Item)], maps:get(value, Item))
        end, Body),
        {{true, <<"/api/v1/options">>}, Req, State}
.

get_handle(Req, State) ->
    Body = jsx:encode(options:tree()),
    {Body, Req, State}
.

	
	
