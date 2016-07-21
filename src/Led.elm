module Led exposing ( Model, Msg, init, update, view, subscriptions, active )

import Html exposing (..)
import Html.App as App
import Html.Events exposing (..)
import Time exposing (Time, second)
import Http
import Json.Decode as Json
import Task

main: Program Never
main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

-- MODEL

type alias Model =
  { ledStatus: Bool
  }

init : (Model, Cmd Msg)
init =
  (Model False, getLedStatus)

-- UPDATE

type Msg 
  = Tick Time
  | LedStatusSucceed Bool
  | LedStatusFail Http.Error
  | ToggleLed

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick time ->
      (model, getLedStatus)
    LedStatusSucceed ledStatus ->
      ({ model | ledStatus = ledStatus}, Cmd.none)
    LedStatusFail _ ->
      (model, Cmd.none)
    ToggleLed ->
      (model, toggleLed)

active : Model -> Bool
active model =
  model.ledStatus

getLedStatus : Cmd Msg
getLedStatus = 
  let
    url = "http://localhost:3000/led"
  in
    Task.perform LedStatusFail LedStatusSucceed (Http.get decodeLedStatus url)

toggleLed : Cmd Msg
toggleLed =
  let
    url = "http://localhost:3000/led/toggle"
  in
    Task.perform LedStatusFail LedStatusSucceed (Http.post decodeLedStatus url Http.empty) 

decodeLedStatus: Json.Decoder Bool
decodeLedStatus = 
  Json.at ["led"] Json.bool

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every second Tick

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ span [] [ text ("Led Status: " ++ toString model.ledStatus) ]
    , br [] []
    , button [ onClick ToggleLed ] [ text "ToggleLED" ]
    ]