-module(api_v1_gallery_handler).

-include("include/constants.hrl").

-export([desc/0]).
-export([init/2]).
-export([content_types_provided/2]).
-export([json_answer/2]).

desc() ->
    [
        #{handle => {"/api/v1/gallery", ?MODULE, []}, order => 0}
    ]
.

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
	{[
		{<<"application/json">>, json_answer}
	], Req, State}.

json_answer(Req, State) ->
    Data = db:execute(gallery," select * from  \"library\" ORDER by filename", 
        []),
        Body = lists:map(fun(A) ->
            F=proplists:get_value(<<"filename">>, A),
        #{name => F, url => << "/static/content/gallery/", F/binary >>}
    end, maps:get(gallery, Data)),
	{jsx:encode(Body), Req, State}.