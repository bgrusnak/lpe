-module(api_v1_upload_handler).

-include("include/constants.hrl").

-export([desc/0]).
-export([init/2]).

desc() ->
    [
        #{handle => {"/api/v1/upload", ?MODULE, []}, order => 0}
    ]
.
init(Req, Opts) ->
	{ok, Headers, Req2} = cowboy_req:read_part(Req),
	{ok, Data, Req3} = cowboy_req:read_part_body(Req2),
	{file, <<"file">>, Filename, ContentType}
        = cow_multipart:form_data(Headers),
    UData = db:execute(file," INSERT INTO \"library\" (filename, \"type\") VALUES ($1, $2) RETURNING uid", 
        [Filename, ContentType]),
    [[{<<"uid">>, Uid}]] = maps:get(file, UData),
    Pd = filename:absname(filename:join([<<"priv">>, <<"library">>,Uid])),
    file:write_file(Pd, Data),
    Pd2 = filename:absname(filename:join([<<"priv">>, <<"static">>, <<"content">>, <<"gallery">>, Filename])),
    file:write_file(Pd2, Data),
	{ok, Req3, Opts}.