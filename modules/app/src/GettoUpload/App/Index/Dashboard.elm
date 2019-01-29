module GettoUpload.App.Index.Dashboard exposing
  ( Model
  , Msg
  , construct
  , init
  , search
  , searchChanged
  , store
  , storeChanged
  , subscriptions
  , update
  , contents
  , dialogs
  )
import GettoUpload.Layout.Frame as Frame
import GettoUpload.Layout.Href.Home as HomeHref

import Getto.Command.Transition as Transition
import Getto.Url.Query.Encode as QueryEncode
import Getto.Url.Query.Decode as QueryDecode

import Json.Encode as Encode
import Json.Decode as Decode
import Html as H exposing ( Html )
import Html.Attributes as A
import Html.Events as E
import Html.Lazy as L

type alias FrameModel a msg = Frame.Model { a | dashboard : Model } msg
type alias Model = {}

type Msg
  = HelloWorld

construct : Frame.InitModel -> Model
construct model = {}

init : FrameModel a msg -> ( FrameModel a msg, Cmd Msg )
init = Transition.none

search : Model -> QueryEncode.Value
search model = QueryEncode.empty

searchChanged : List String -> QueryDecode.Value -> Model -> ( Model, Cmd Msg )
searchChanged names value model = ( model, Cmd.none )

store : Model -> Encode.Value
store model = Encode.null

storeChanged : Decode.Value -> Model -> Model
storeChanged value model = model

subscriptions : FrameModel a msg -> Sub Msg
subscriptions model = Sub.none

update : Msg -> FrameModel a msg -> ( FrameModel a msg, Cmd Msg )
update msg model =
  case msg of
    HelloWorld -> ( model, Cmd.none )

contents : FrameModel a msg -> List (Html Msg)
contents model =
  [ model |> dashboard
  ]

dashboard : FrameModel a msg -> Html Msg
dashboard model =
  H.section [ A.class "dashboard" ]
    [ H.dl []
      [ H.dd []
        [ H.section []
          [ H.h2 [] [ "Subject" |> H.text ]
          , H.p []
            [ H.em []
              [ "3" |> H.text
              , H.small [] [ H.small [] [ "million" |> H.text ] ]
              ]
            , " " |> H.text
            , H.em [] [ "/" |> H.text ]
            , " " |> H.text
            , H.em []
              [ H.small [] [ "20" |> H.text ]
              , H.small [] [ H.small [] [ "million" |> H.text ] ]
              ]
            ]
          , H.meter [ A.value "3", A.max "20" ] [ "15%" |> H.text ]
          , H.footer []
            [ H.a [ A.href HomeHref.index ]
              [ H.i [ A.class "fas fa-user" ] []
              , " " |> H.text
              , "User" |> H.text
              ]
            ]
          ]
        ]
      ]
    ]

dialogs : FrameModel a msg -> List (Html Msg)
dialogs model = []
