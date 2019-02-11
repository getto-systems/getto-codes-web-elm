module GettoUpload.View.Html.Button exposing
  ( error
  , connecting
  , select
  , save
  )
import GettoUpload.View.Icon as Icon
import GettoUpload.View.Html as Html

import Html as H exposing ( Html )
import Html.Attributes as A
import Html.Events as E

error : String -> Html msg
error text =
  button
    [ "is-error" |> A.class
    ]
    [ text |> H.text ]

connecting : String -> Html msg
connecting text =
  button
    [ "is-connecting" |> A.class
    ]
    [ Icon.fas "spinner" |> Html.icon ["fa-spin"]
    , " " |> H.text
    , text |> H.text
    ]

select : msg -> String -> Html msg
select msg text =
  button
    [ msg |> E.onClick
    ]
    [ text |> H.text ]

save : msg -> String -> Html msg
save msg text =
  button
    [ "is-save" |> A.class
    , msg |> E.onClick
    ]
    [ text |> H.text ]

button : List (H.Attribute msg) -> List (Html msg) -> Html msg
button attr =
  H.button ( ("button" |> A.type_) :: attr )