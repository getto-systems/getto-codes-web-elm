module GettoUpload.App.Upload.Edit.Data exposing
  ( Model
  , Msg
  , getRequest
  , init
  , encodeQuery
  , decodeQuery
  , encodeStore
  , decodeStore
  , subscriptions
  , update
  )
import GettoUpload.App.Upload.Edit.Model as Model
import GettoUpload.App.Upload.Edit.Data.View as View
import GettoUpload.Layout.Page.Page as Layout
import GettoUpload.Layout.Frame as Frame
import GettoUpload.Layout.Api as Api
import GettoUpload.Command.Http as Http
import GettoUpload.View.Http as HttpView

import Getto.Command.Transition as T exposing ( Transition )
import Getto.Url.Query.Encode as QueryEncode
import Getto.Url.Query.Decode as QueryDecode
import Getto.Url.Query.SafeDecode as QuerySafeDecode
import Getto.Json.SafeDecode as SafeDecode

import Json.Encode as Encode
import Json.Decode as Decode

import Set exposing ( Set )
import Html as H exposing ( Html )
import Html.Attributes as A
import Html.Lazy as L

type alias FrameModel a = Frame.Model Layout.Model { a | data : Model.Data }
type alias FrameTransition a = Transition (FrameModel a) Msg
type alias Model = Model.Data

type Msg
  = StateChanged (HttpView.Migration View.Response)

signature = "data"

get : Http.Tracker (FrameModel a) View.Response
get = Http.tracker "get" <|
  \model ->
    let
      m = model |> Frame.app |> .data
    in
      Http.getIfNoneMatch ( m |> Model.etag )
        { url      = "upload/:id" |> Api.url ( m |> Model.pathInfo )
        , headers  = model |> Api.headers
        , params   = QueryEncode.empty
        , response = View.response
        , timeout = 10 * 1000
        }

getTrack   = Http.track   signature get StateChanged
getRequest = Http.request signature get StateChanged


init : Frame.InitModel -> ( Model, FrameTransition a )
init model =
  ( { id  = 0
    , get = HttpView.empty
    }
  , [ getRequest
    ] |> T.batch
  )

encodeQuery : Model -> QueryEncode.Value
encodeQuery model = QueryEncode.empty

decodeQuery : List String -> QueryDecode.Value -> Model -> Model
decodeQuery names value model =
  let
    entryAt name = QuerySafeDecode.entryAt (names ++ [name])
  in
    { model | id = value |> entryAt "id" (QuerySafeDecode.int 0) }

encodeStore : Model -> Encode.Value
encodeStore model = Encode.object
  [ ( model.id |> String.fromInt
    , model.get |> HttpView.response |> Maybe.map View.encodeResponse |> Maybe.withDefault Encode.null
    )
  ]

decodeStore : Decode.Value -> Model -> Model
decodeStore value model =
  let
    obj = value |> SafeDecode.valueAt [model.id |> String.fromInt]
  in
    { model
    | get = model.get |>
      case obj |> Decode.decodeValue View.decodeResponse of
        Ok res -> res |> HttpView.success |> HttpView.update
        Err _  -> identity
    }

subscriptions : Model -> Sub Msg
subscriptions model = getTrack

update : Msg -> Model -> ( Model, FrameTransition a )
update msg model =
  case msg of
    StateChanged mig ->
      ( { model | get = model.get |> HttpView.update mig }
      , case mig |> HttpView.isSuccess of
        Just _  -> Frame.storeApp
        Nothing -> T.none
      )
