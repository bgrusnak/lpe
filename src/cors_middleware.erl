-module(cors_middleware).

-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req, Env) ->
    {ok, ReqWithCorsHeaders} = set_cors_headers(Req),
    #{method := Method} = ReqWithCorsHeaders,
    case Method of
	<<"OPTIONS">> ->
		ReqFinal = cowboy_req:reply(200, ReqWithCorsHeaders),
		{stop, ReqFinal};
	_ ->
	    %% continue as normal
	    {ok, ReqWithCorsHeaders, Env}
    end.

%% ===================================================================
%% Helpers
%% ===================================================================

set_headers(Headers, Req) ->
    ReqWithHeaders = lists:foldl(fun({Header, Value}, ReqIn) ->
					 ReqWithHeader = cowboy_req:set_resp_header(Header, Value, ReqIn),
					 ReqWithHeader
				 end, Req, Headers),
    {ok, ReqWithHeaders}.
    

set_cors_headers(Req) ->
	ReqHeaders = cowboy_req:headers(Req),
	Origin=maps:get(<<"origin">>, ReqHeaders, <<"http://localhost:8080">>),
	Headers = [{<<"access-control-allow-origin">>, Origin},
		{<<"access-control-allow-credentials">>, <<"true">>},
		{<<"access-control-allow-methods">>, <<"POST, GET, OPTIONS, PUT, DELETE">>},
		{<<"access-control-allow-headers">>, <<"Access-Control-Allow-Origin, Origin, X-Requested-With, Content-Type, Accept">>},
		{<<"access-control-max-age">>, <<"100000">>}],
    set_headers(Headers, Req)
.