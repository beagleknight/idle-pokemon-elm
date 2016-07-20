module PokeballCounter exposing ( Model, Msg, init, update, view, subscriptions )

import Html exposing (..)
import Html.App as App
import Html.Events exposing (..)
import Time exposing (Time, second)

main: Program Never
main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

-- MODEL

type alias Model =
  { pokeballs: Int
  , pps: Int
  }

init : (Model, Cmd Msg)
init =
  (Model 0 0, Cmd.none)

-- UPDATE

type Msg 
  = ClickPokeball
  | Tick Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ClickPokeball ->
      ({ model | pokeballs = model.pokeballs + 1}, Cmd.none)
    Tick time ->
      ({ model | pokeballs = model.pokeballs + model.pps}, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every second Tick

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ h2 [] [ text (toString model.pokeballs) ]
    , button [ onClick ClickPokeball ] [ text "Pokeball" ]
    , br [] []
    , span [] [ text ("Pokeballs per second: " ++ toString model.pps) ]
    ]