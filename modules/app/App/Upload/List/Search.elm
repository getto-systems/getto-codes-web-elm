module GettoUpload.App.Upload.List.Search exposing
  ( Msg
  , init
  , encodeQuery
  , decodeQuery
  , encodeStore
  , decodeStore
  , subscriptions
  , update
  , contents
  )
import GettoUpload.App.Upload.List.Model as Model
import GettoUpload.App.Upload.List.Search.View as View
import GettoUpload.App.Upload.List.Search.Html as Html
import GettoUpload.Layout.Frame as Frame
import GettoUpload.Layout.Page.Options.View as Options
import GettoUpload.Layout.Api as Api
import GettoUpload.Command.Http as Http
import GettoUpload.Command.Dom as Dom
import GettoUpload.View.Http as HttpView
import GettoUpload.I18n.App as AppI18n
import GettoUpload.I18n.App.Upload as I18n
import GettoUpload.I18n.Http as HttpI18n

import Getto.Command.Transition as T exposing ( Transition )
import Getto.Url.Query.Encode as QueryEncode
import Getto.Url.Query.Decode as QueryDecode
import Getto.Http.Header.Decode as HeaderDecode
import Getto.Http.Part as Part
import Getto.Field as Field
import Getto.Field.Form as Form
import Getto.Field.Present as Present
import Getto.Sort as Sort

import Json.Encode as Encode
import Json.Decode as Decode

import Set exposing ( Set )
import Html as H exposing ( Html )
import Html.Attributes as A
import Html.Events as E
import Html.Lazy as L

type Msg
  = Input  (View.Prop String) String
  | Toggle (View.Prop (Set String)) String
  | Change
  | PageTo String
  | SortBy Sort.Model
  | Request
  | StateChanged (HttpView.Migration View.Response)

signature = "search"

get : Http.Tracker Model.Frame View.Response
get = Http.tracker "get" <|
  \model ->
    let
      search = model |> Frame.app |> .search
    in
      Http.get
        { url     = "uploads" |> Api.url []
        , headers = model |> Api.headers
        , params  = QueryEncode.object
          [ ( "q"
            , [ ( "name",           search.form.name          |> Field.value |> QueryEncode.string )
              , ( "age_gteq",       search.form.age_gteq      |> Field.value |> QueryEncode.string )
              , ( "age_lteq",       search.form.age_lteq      |> Field.value |> QueryEncode.string )
              , ( "email",          search.form.email         |> Field.value |> QueryEncode.string )
              , ( "tel",            search.form.tel           |> Field.value |> QueryEncode.string )
              , ( "birthday_gteq",  search.form.birthday_gteq |> Field.value |> QueryEncode.string )
              , ( "birthday_lteq",  search.form.birthday_lteq |> Field.value |> QueryEncode.string )
              , ( "start_at_gteq",  search.form.start_at_gteq |> Field.value |> QueryEncode.string )
              , ( "start_at_lteq",  search.form.start_at_lteq |> Field.value |> QueryEncode.string )
              , ( "gender",         search.form.gender        |> Field.value |> QueryEncode.string )
              , ( "roles",          search.form.roles         |> Field.value |> QueryEncode.set QueryEncode.string )
              ] |> QueryEncode.object
            )
          , ( "page", search.page |> QueryEncode.int )
          , ( "sort"
            , case search.sort |> Sort.expose of
              (column,order) ->
                [ ( "column", column |> QueryEncode.string )
                , ( "order",  order  |> QueryEncode.string )
                ] |> QueryEncode.object
            )
          ]
        , response = View.response
        , timeout = 10 * 1000
        }

getTrack   = Http.track   signature get StateChanged
getRequest = Http.request signature get StateChanged


init : Frame.InitModel -> ( Model.Search, Model.Transition Msg )
init model =
  ( { form = View.init signature
    , page = 0
    , sort = "id" |> Sort.by
    , get  = HttpView.empty
    }
  , [ searchAndPushUrl
    , fill
    ] |> T.batch
  )

encodeQuery : Model.Search -> QueryEncode.Value
encodeQuery model = QueryEncode.object
  [ ( "q",    model.form |> View.encodeForm )
  , ( "page", model.page |> QueryEncode.int )
  , ( "sort"
    , case model.sort |> Sort.expose of
      (column,order) ->
        [ ( "column", column |> QueryEncode.string )
        , ( "order",  order  |> QueryEncode.string )
        ] |> QueryEncode.object
    )
  ]

decodeQuery : List String -> QueryDecode.Value -> Model.Search -> Model.Search
decodeQuery names value model =
  { model
  | form = model.form |> View.decodeForm (names ++ ["q"]) value
  , page = value |> QueryDecode.entryAt (names ++ ["page"]) QueryDecode.int |> Maybe.withDefault model.page
  , sort =
    ( value |> QueryDecode.entryAt (names ++ ["sort","column"]) QueryDecode.string
    , value |> QueryDecode.entryAt (names ++ ["sort","order"])  QueryDecode.string
    ) |> Sort.fromString |> Maybe.withDefault model.sort
  }

encodeStore : Model.Search -> Encode.Value
encodeStore model = Encode.null

decodeStore : Decode.Value -> Model.Search -> Model.Search
decodeStore value model = model

subscriptions : Model.Search -> Sub Msg
subscriptions model = getTrack

update : Msg -> Model.Search -> ( Model.Search, Model.Transition Msg )
update msg model =
  case msg of
    Input  prop value -> ( { model | form = model.form |> Form.set prop value },    T.none )
    Toggle prop value -> ( { model | form = model.form |> Form.toggle prop value }, T.none )
    Change -> ( model, T.none )

    PageTo page -> ( { model | page = page |> toPage }, searchAndPushUrl )
    SortBy sort -> ( { model | sort = sort },           searchAndPushUrl )
    Request     -> ( { model | page = 0 },              searchAndPushUrl )

    StateChanged mig -> ( { model | get = model.get |> HttpView.update mig }, T.none )

toPage : String -> Int
toPage = String.toInt >> Maybe.withDefault 0

fill : Model.Transition Msg
fill = Frame.app >> .search >>
  (\model -> Dom.fill
    [ model.form.name          |> Field.pair
    , model.form.age_gteq      |> Field.pair
    , model.form.age_lteq      |> Field.pair
    , model.form.email         |> Field.pair
    , model.form.tel           |> Field.pair
    , model.form.birthday_gteq |> Field.pair
    , model.form.birthday_lteq |> Field.pair
    , model.form.start_at_gteq |> Field.pair
    , model.form.start_at_lteq |> Field.pair
    ]
  )

searchAndPushUrl : Model.Transition Msg
searchAndPushUrl =
  [ getRequest
  , Frame.pushUrl
  ] |> T.batch

contents : Model.Frame -> List (Html Msg)
contents model =
  [ H.section [ A.class "list" ]
    [ H.section [ "search" |> A.class ]
      [ model |> form
      ]
    , H.section [ "data" |> A.class ]
      [ model |> paging
      , model |> table
      , model |> paging
      ]
    ]
  ]

form : Model.Frame -> Html Msg
form model = L.lazy2
  (\options search -> Html.search
    { view = search.form |> View.view
    , get  = search.get
    , options =
      { gender = options.get |> Options.gender |> toSelectOptions I18n.gender
      , role   = options.get |> Options.role   |> toBoxOptions AppI18n.role
      }
    , msg =
      { request = Request
      , input   = Input
      , toggle  = Toggle
      , change  = Change
      }
    , i18n =
      { field = I18n.field
      , form  = AppI18n.form
      , http  = HttpI18n.error
      }
    }
  )
  (model |> Frame.layout |> .options)
  (model |> Frame.app    |> .search)

paging : Model.Frame -> Html Msg
paging model = L.lazy
  (\search -> Html.paging
    { page = search.page
    , get  = search.get
    , msg =
      { page = PageTo
      }
    , i18n =
      { paging = AppI18n.paging
      }
    }
  )
  (model |> Frame.app |> .search)

table : Model.Frame -> Html Msg
table model = L.lazy
  (\search -> Html.table
    { get  = search.get
    , sort = search.sort
    , msg =
      { sort = SortBy
      }
    , i18n =
      { field = I18n.field
      , table = AppI18n.table
      , form  = AppI18n.form
      }
    }
  )
  (model |> Frame.app |> .search)

toSelectOptions : (String -> String) -> Maybe (List String) -> List ( String, String )
toSelectOptions i18n = Maybe.map (toOptions i18n >> includeDefault) >> withLoading

toBoxOptions : (String -> String) -> Maybe (List String) -> List ( String, String )
toBoxOptions i18n = Maybe.map (toOptions i18n) >> Maybe.withDefault []

toOptions : (String -> String) -> List String -> List ( String, String )
toOptions i18n = List.map (\value -> ( value, value |> i18n ) )

includeDefault : List ( String, String ) -> List ( String, String )
includeDefault options = ( "", "please-select" |> AppI18n.form ) :: options

withLoading : Maybe (List ( String, String )) -> List ( String, String )
withLoading = Maybe.withDefault [ ( "", "loading" |> AppI18n.form ) ]
