module GettoUpload.App.Upload.Edit.Info.Html exposing
  ( info
  )
import GettoUpload.App.Upload.Edit.Info.View as View
import GettoUpload.View.Html as Html
import GettoUpload.View.Html.Button as Button
import GettoUpload.View.Html.Input as Input
import GettoUpload.View.Html.Http as Http
import GettoUpload.View.Icon as Icon
import GettoUpload.View.Http as HttpView

import Getto.Field as Field
import Getto.Field.Form as Form

import File exposing ( File )
import Set exposing ( Set )
import Html as H exposing ( Html )
import Html.Attributes as A
import Html.Events as E


type alias InfoModel msg =
  { title : String
  , form  : View.View
  , get   : HttpView.Model View.ResponseHeader View.ResponseBody
  , put   : HttpView.Model View.ResponseHeader View.ResponseBody
  , options :
    { gender  : List ( String, String )
    , quality : List ( String, String )
    , roles   : List ( String, String )
    }
  , msg :
    { put    : msg
    , input  : Form.Prop View.Form String -> String -> msg
    , check  : Form.Prop View.Form (Set String) -> String -> msg
    , change : msg
    , edit   : msg
    , static : msg
    }
  , i18n :
    { title : String -> String
    , field : String -> String
    , error : String -> String
    , form  : String -> String
    , http  : HttpView.Error -> String
    }
  }

info : InfoModel msg -> Html msg
info model =
  case [ model.get, model.put ] |> List.map HttpView.response of
    [ Just get, put ] ->
      let
        res    = put |> Maybe.withDefault get
        header = res |> HttpView.header
        body   = res |> HttpView.body
      in
        H.section []
          [ H.form []
            [ H.h2 [] [ model.title |> model.i18n.title |> H.text ]
            , H.table []
              [ H.tbody [] <| List.concat
                [ case model.form |> View.name of
                  (View.Static,(name,_,_)) ->
                    [ H.tr []
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td []
                        [ H.p [] [ body.info.name |> H.text ]
                        ]
                      ]
                    ]
                  (View.Edit,(name,errors,form)) ->
                    [ H.tr ( errors |> Input.isError )
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td [] <| List.concat
                        [ [ form.field |> Input.text [] (model.msg.input form.prop) model.msg.change
                          ]
                        , errors |> Input.errors model.i18n.error
                        ]
                      ]
                    ]
                , case model.form |> View.memo of
                  (View.Static,(name,_,_)) ->
                    [ H.tr []
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td []
                        [ H.p [ "text-pre-wrap" |> A.class ] [ body.info.memo |> H.text ]
                        ]
                      ]
                    ]
                  (View.Edit,(name,errors,form)) ->
                    [ H.tr ( errors |> Input.isError )
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td [] <| List.concat
                        [ [ form.field |> Input.textarea [] (model.msg.input form.prop) model.msg.change
                          ]
                        , errors |> Input.errors model.i18n.error
                        ]
                      ]
                    ]
                , case model.form |> View.age of
                  (View.Static,(name,_,_)) ->
                    [ H.tr []
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td []
                        [ H.p [] [ body.info.age |> String.fromInt |> H.text ]
                        ]
                      ]
                    ]
                  (View.Edit,(name,errors,form)) ->
                    [ H.tr ( errors |> Input.isError )
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td [] <| List.concat
                        [ [ form.field |> Input.number [] (model.msg.input form.prop) model.msg.change
                          ]
                        , errors |> Input.errors model.i18n.error
                        ]
                      ]
                    ]
                , case model.form |> View.email of
                  (View.Static,(name,_,_)) ->
                    [ H.tr []
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td []
                        [ H.p [] [ body.info.email |> H.text ]
                        ]
                      ]
                    ]
                  (View.Edit,(name,errors,form)) ->
                    [ H.tr ( errors |> Input.isError )
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td [] <| List.concat
                        [ [ form.field |> Input.email [] (model.msg.input form.prop) model.msg.change
                          ]
                        , errors |> Input.errors model.i18n.error
                        ]
                      ]
                    ]
                , case model.form |> View.tel of
                  (View.Static,(name,_,_)) ->
                    [ H.tr []
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td []
                        [ H.p [] [ body.info.tel |> H.text ]
                        ]
                      ]
                    ]
                  (View.Edit,(name,errors,form)) ->
                    [ H.tr ( errors |> Input.isError )
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td [] <| List.concat
                        [ [ form.field |> Input.tel [] (model.msg.input form.prop) model.msg.change
                          ]
                        , errors |> Input.errors model.i18n.error
                        ]
                      ]
                    ]
                , case model.form |> View.birthday of
                  (View.Static,(name,_,_)) ->
                    [ H.tr []
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td []
                        [ H.p [] [ body.detail.birthday |> H.text ]
                        ]
                      ]
                    ]
                  (View.Edit,(name,errors,form)) ->
                    [ H.tr ( errors |> Input.isError )
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td [] <| List.concat
                        [ [ form.field |> Input.date [] (model.msg.input form.prop) model.msg.change
                          ]
                        , errors |> Input.errors model.i18n.error
                        ]
                      ]
                    ]
                , case model.form |> View.start_at of
                  (View.Static,(name,_,_)) ->
                    [ H.tr []
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td []
                        [ H.p [] [ body.detail.start_at |> H.text ]
                        ]
                      ]
                    ]
                  (View.Edit,(name,errors,form)) ->
                    [ H.tr ( errors |> Input.isError )
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td [] <| List.concat
                        [ [ form.field |> Input.time [] (model.msg.input form.prop) model.msg.change
                          ]
                        , errors |> Input.errors model.i18n.error
                        ]
                      ]
                    ]
                , case model.form |> View.gender of
                  (View.Static,(name,_,_)) ->
                    [ H.tr []
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td []
                        [ H.p [] [ body.detail.gender |> H.text ]
                        ]
                      ]
                    ]
                  (View.Edit,(name,errors,form)) ->
                    [ H.tr ( errors |> Input.isError )
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td [] <| List.concat
                        [ [ form.field |> Input.select model.options.gender [] (model.msg.input form.prop) model.msg.change
                          ]
                        , errors |> Input.errors model.i18n.error
                        ]
                      ]
                    ]
                , case model.form |> View.quality of
                  (View.Static,(name,_,_)) ->
                    [ H.tr []
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td []
                        [ H.p [] [ body.detail.quality |> H.text ]
                        ]
                      ]
                    ]
                  (View.Edit,(name,errors,form)) ->
                    [ H.tr ( errors |> Input.isError )
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td [] <| List.concat
                        [ [ form.field |> Input.radio model.options.quality [] (model.msg.input form.prop) model.msg.change
                          ]
                        , errors |> Input.errors model.i18n.error
                        ]
                      ]
                    ]
                , case model.form |> View.roles of
                  (View.Static,(name,_,_)) ->
                    [ H.tr []
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td []
                        [ H.ul []
                          ( body.detail.roles |> Set.toList |> List.map
                            (\role ->
                              H.li [] [ role |> H.text ]
                            )
                          )
                        ]
                      ]
                    ]
                  (View.Edit,(name,errors,form)) ->
                    [ H.tr ( errors |> Input.isError )
                      [ H.th [] [ name |> model.i18n.field |> H.text ]
                      , H.td [] <| List.concat
                        [ [ form.field |> Input.checkbox model.options.roles [] (model.msg.check form.prop) model.msg.change
                          ]
                        , errors |> Input.errors model.i18n.error
                        ]
                      ]
                    ]
                ]
              ]
            , H.footer [] <|
              case model.form |> View.state of
                (View.Static,_) ->
                  [ "edit" |> model.i18n.form |> Button.edit model.msg.edit
                  ]
                (View.Edit,hasError) ->
                  case model.put |> HttpView.state of
                    HttpView.Connecting progress ->
                      [ "saving" |> model.i18n.form |> Button.connecting
                      , progress |> Http.progress
                      ]
                    HttpView.Ready response ->
                      [ if hasError
                        then "has-error" |> model.i18n.form |> Button.error
                        else "save"      |> model.i18n.form |> Button.save model.msg.put
                      , "cancel" |> model.i18n.form |> Button.cancel model.msg.static
                      , response |> Http.error model.i18n.http
                      ]
            ]
          ]
    _ ->
      case model.get |> HttpView.state of
        HttpView.Ready (Just error) ->
          H.section [ "loading" |> A.class ]
            [ H.section []
              [ error |> model.i18n.http |> Html.badge ["is-danger"]
              ]
            ]
        _ ->
          H.section [ "loading" |> A.class ]
            [ H.section []
              [ Icon.fas "spinner" |> Html.icon ["fa-pulse"]
              ]
            ]
