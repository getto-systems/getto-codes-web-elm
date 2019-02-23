module GettoUpload.App.Index.Page exposing ( main )
import GettoUpload.App.Index.Dashboard as Dashboard
import GettoUpload.Layout.Frame as Frame
import GettoUpload.Layout.Page.Page as Layout

import Getto.Command.Transition as Transition exposing ( Transition )
import Getto.Url.Query.Encode as QueryEncode
import Getto.Json.SafeDecode as SafeDecode

import Json.Encode as Encode
import Json.Decode as Decode
import Browser
import Html as H exposing ( Html )
import Html.Attributes as A
import Html.Lazy as L

main = Browser.application
  { init          = Frame.init Layout.setup setup
  , subscriptions = Frame.subscriptions Layout.subscriptions subscriptions
  , onUrlRequest  = Frame.onUrlRequest
  , onUrlChange   = Frame.onUrlChange
  , update        = Frame.update Layout.update update
  , view          = document
  }

type alias FrameModel = Frame.Model Layout.Model Model
type alias FrameTransition = Transition FrameModel Msg
type alias Model =
  { dashboard : Dashboard.Model
  }

type alias FrameMsg = Frame.Msg Layout.Msg Msg
type Msg
  = Dashboard Dashboard.Msg

setup : Frame.SetupApp Layout.Model Model Msg
setup =
  { store =
    ( \model -> Encode.object
      [ ( "dashboard", model.dashboard |> Dashboard.store )
      ]
    , \value model ->
      Model
        ( model.dashboard |> Dashboard.storeChanged (value |> SafeDecode.valueAt ["dashboard"]) )
    )
  , search =
    ( \model -> QueryEncode.object
      [ ( "dashboard", model.dashboard |> Dashboard.query )
      ]
    , \value model ->
      Model
        ( model.dashboard |> Dashboard.queryChanged ["dashboard"] value )
    )
  , dom = \model -> List.concat
    [ model.dashboard |> Dashboard.fill
    ]
  , init = init
  }

init : Frame.InitModel -> ( Model, FrameTransition )
init model =
  Transition.compose Model
    (model |> Dashboard.init "dashboard" |> Transition.map Dashboard)

subscriptions : Model -> Sub Msg
subscriptions model =
  [ model.dashboard |> Dashboard.subscriptions |> Sub.map Dashboard
  ] |> Sub.batch

dashboard_ = Transition.prop .dashboard (\v m -> { m | dashboard = v })

update : Msg -> Model -> ( Model, FrameTransition )
update message =
  case message of
    Dashboard msg ->
      Transition.update dashboard_
        (Dashboard.update msg >> Transition.map Dashboard)

document : FrameModel -> Browser.Document FrameMsg
document model =
  { title = model |> Layout.documentTitle
  , body = [ L.lazy content model ]
  }

content : FrameModel -> Html FrameMsg
content model =
  H.section [ A.class "MainLayout" ] <|
    [ model |> Layout.mobileHeader
    , model |> Layout.mobileAddress
    , H.article [] <|
      [ H.header []
        [ model |> Layout.articleHeader
        , model |> Layout.breadcrumb
        ]
      ] ++
      ( model |> Dashboard.contents |> Frame.mapApp Dashboard ) ++
      [ model |> Layout.articleFooter ]
    , H.nav []
      [ model |> Layout.navHeader
      , model |> Layout.navAddress
      , model |> Layout.nav
      , model |> Layout.navFooter
      ]
    ] ++
    ( model |> Dashboard.dialogs |> Frame.mapApp Dashboard )
