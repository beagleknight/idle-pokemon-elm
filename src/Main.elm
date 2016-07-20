import Html exposing (..)
import Html.App as App

import PokeballCounter
import Led

main: Program Never
main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

-- MODEL

type alias Model =
  { pokeballCounter: PokeballCounter.Model
  , led: Led.Model
  }

init : (Model, Cmd Msg)
init =
  let
    (pokeballCounterModel, pokeballCounterCmd) = PokeballCounter.init
    (ledModel, ledCmd) = Led.init
  in
    (Model pokeballCounterModel ledModel, Cmd.batch 
    [ Cmd.map PokeballCounter pokeballCounterCmd
    , Cmd.map Led ledCmd
    ])

-- UPDATE

type Msg 
  = PokeballCounter PokeballCounter.Msg
  | Led Led.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    PokeballCounter msg ->
      let
        (pokeballCounterModel, pokeballCounterCmd) = PokeballCounter.update msg model.pokeballCounter
      in
        ({ model | pokeballCounter = pokeballCounterModel }, Cmd.map PokeballCounter pokeballCounterCmd)
    Led msg ->
      let
        (ledModel, ledCmd) = Led.update msg model.led
      in
        ({ model | led = ledModel }, Cmd.map Led ledCmd)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ Sub.map PokeballCounter (PokeballCounter.subscriptions model.pokeballCounter)
  , Sub.map Led (Led.subscriptions model.led)
  ]
  

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ App.map PokeballCounter (PokeballCounter.view model.pokeballCounter)
    , App.map Led (Led.view model.led)
    ]