-module(api_v1_plugins_handler).

-include("include/constants.hrl").

-export([desc/0]).
-export([init/2]).
-export([content_types_provided/2]).
-export([json_answer/2]).

desc() ->
    [
        #{handle => {"/api/v1/plugins", ?MODULE, []}, order => 0}
    ]
.

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
	{[
		{<<"application/json">>, json_answer}
	], Req, State}.

json_answer(Req, State) ->
    #{activate := Activate} = cowboy_req:match_qs([{activate, [], undefined}], Req),
    case Activate of 
        undefined -> ok;
        _ -> db:execute(themes,"update \"themes\" set \"active\" = CASE WHEN \"id\" = $1 THEN true ELSE false END ", [Activate])
    end,
    Data = db:execute(plugins," select * from  \"plugins\" ORDER by name", 
        []),
    Body = maps:get(plugins, Data),
	{jsx:encode(Body), Req, State}.