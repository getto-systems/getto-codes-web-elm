port module GettoUpload.Layout.Command.Store exposing
  ( Model
  , init
  , layout
  , page
  , exec
  )

import Json.Encode as Encode

port storeLayout : Encode.Value -> Cmd msg
port storePage : Encode.Value -> Cmd msg

type alias Model = List StorageType

type alias Storage =
  { layout : Encode.Value
  , page   : Encode.Value
  }

type StorageType
  = Layout
  | Page

init : Model
init = []

layout : Model -> Model
layout model =
  if model |> List.member Layout
    then model
    else Layout :: model

page : Model -> Model
page model =
  if model |> List.member Page
    then model
    else Page :: model

exec : Storage -> Model -> ( Model, Cmd msg )
exec storage model =
  ( []
  , model
    |> List.map (execCmd storage)
    |> Cmd.batch
  )

execCmd : Storage -> StorageType -> Cmd msg
execCmd storage t =
  case t of
    Layout -> storage.layout |> storeLayout
    Page   -> storage.page   |> storePage