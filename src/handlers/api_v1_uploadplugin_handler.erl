-module(api_v1_uploadplugin_handler).

-include("include/constants.hrl").
-include("_build/default/lib/fast_xml/include/fxml.hrl").

-export([desc/0]).
-export([init/2]).

desc() ->
    [
        #{handle => {"/api/v1/uploadplugin", ?MODULE, []}, order => 0}
    ]
.
init(Req, Opts) ->
	{ok, Headers, Req2} = cowboy_req:read_part(Req),
	{ok, Data, Req3} = cowboy_req:read_part_body(Req2),
    Tempdir = tempdir:name()++"/",
    ok = filelib:ensure_dir(Tempdir),
    Tempfile = tempdir:name(),
    file:write_file(Tempfile, Data),
    zip:extract(Tempfile, [{cwd, Tempdir}]),
    {ok, File} = file:read_file(Tempdir ++ "manifest.xml"),
    Manifest = fxml_stream:parse_element(File),
    Id=fxml:get_subtag_cdata(Manifest, <<"id">>),
    Name=fxml:get_subtag_cdata(Manifest, <<"name">>),
    Version=fxml:get_subtag_cdata(Manifest, <<"version">>),
    Author=fxml:get_subtag_cdata(Manifest, <<"author">>),
    Company=fxml:get_subtag_cdata(Manifest, <<"company">>),
    Url=fxml:get_subtag_cdata(Manifest, <<"url">>),
    Description=fxml:get_subtag_cdata(Manifest, <<"description">>),
    Preview=fxml:get_subtag_cdata(Manifest, <<"preview">>),
    RawGroups = fxml:get_subtags(fxml:get_subtag(Manifest, <<"options">>), <<"group">>),        
    Groups = lists:map(fun(Group) ->
            parse_group(Group)
    end, RawGroups),   
    db:execute(file," INSERT INTO \"plugins\" (\"id\", \"name\", \"version\", \"author\", \"company\", \"description\", \"preview\", \"url\", \"default\", \"saved\") VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $9)",
    [
        Id, Name, Version, Author, Company, Description, Preview, Url, jsx:encode(Groups)
    ]),
    Rename=file:rename(Tempdir, filename:absname(filename:join([<<"priv">>, <<"static">>, <<"themes">>, Id]))),
    io:format("Renamed~n~p~n", [Rename]), 
    {ok, Req3, Opts}.

get_tag_cdata(<<>>) ->
    <<"">>
;

get_tag_cdata(Tag) ->
    fxml:get_tag_cdata(Tag)
.

parse_group(Group) ->
    Description = list_to_binary(string:trim(binary_to_list(get_tag_cdata(Group)))),
    {_,Name} = fxml:get_tag_attr(<<"name">>, Group),
    {_,Title} = fxml:get_tag_attr(<<"title">>, Group),
    GroupOrder = case fxml:get_tag_attr(<<"order">>, Group) of
        {_, A} -> A;
        false -> 0
    end,
    options:addGroup(Name, Title, Description, GroupOrder),
    RawOptions = fxml:get_subtags(Group, <<"option">>),
    Options = lists:map(fun(Option) ->
            OptionDescription = list_to_binary(string:trim(binary_to_list(get_tag_cdata(Option)))),
            {_,OptionName} = fxml:get_tag_attr(<<"name">>, Option),
            {_,OptionTitle} = fxml:get_tag_attr(<<"title">>, Option),
            {_,Type} = fxml:get_tag_attr(<<"type">>, Option),
            OptionOrder =  case fxml:get_tag_attr(<<"order">>, Option) of
                {_, B} -> B;
                false -> 0
            end,
            #xmlel{children = RawChildrens} = Option,
            Childrens = lists:foldl(fun(Item, Items)->
                    case Item of
                        {xmlel,ParamName,_,_} -> 
                            lists:append(Items, [{ParamName, get_tag_cdata(Item)}]);
                        _ -> Items
                    end
                end, [], RawChildrens),
            options:addListItem(Name, OptionName, OptionTitle, OptionDescription, OptionOrder, Type, Childrens),
            #{description => OptionDescription, name => OptionName, title => OptionTitle, type => Type, order=> OptionOrder,  options => Childrens}
        end, RawOptions),
    #{description => Description, name => Name, title => Title, options => Options}
.
