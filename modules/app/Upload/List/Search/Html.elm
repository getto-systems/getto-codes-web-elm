module GettoUpload.App.Upload.List.Search.Html exposing
  ( search
  )
import GettoUpload.View.Html as Html
import GettoUpload.View.Icon as Icon

import File exposing ( File )
import Html as H exposing ( Html )
import Html.Attributes as A
import Html.Events as E


type alias SearchModel msg =
  { title : String
  , entries :
    { file :
      { name : String
      , file : Maybe File
      }
    }
  , msg :
    { submit : msg
    , select : msg
    }
  , i18n :
    { title : String -> String
    , entry : String -> String
    , form  : String -> String
    }
  }

search : SearchModel msg -> Html msg
search model =
  H.section []
    [ H.form [ model.msg.submit |> E.onSubmit ]
      [ H.h2 [] [ model.title |> model.i18n.title |> H.text ]
      , H.table []
        [ H.tbody []
          [ H.tr []
            [ H.th [] [ model.entries.file.name |> model.i18n.entry |> H.text ]
            , H.td [] <|
              case model.entries.file.file of
                Nothing ->
                  [ H.button [ "button" |> A.type_, model.msg.select |> E.onClick ]
                    [ "select-file" |> model.i18n.form |> H.text
                    ]
                  ]
                Just file ->
                  [ H.p [] [ file |> File.name |> H.text ]
                  , H.button [ "button" |> A.type_, model.msg.select |> E.onClick ]
                    [ "re-select-file" |> model.i18n.form |> H.text
                    ]
                  ]
            ]
          ]
        ]
      , H.footer []
        [ H.button [ "is-save" |> A.class ] [ "save" |> model.i18n.form |> H.text ]
        ]
      ]
    ]
