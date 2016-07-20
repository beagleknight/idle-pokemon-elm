import Html exposing (..)
import Html.App as App
import Html.Events exposing (..)

main: Program Never
main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

-- MODEL

type alias Model =
  { pokeballs: Int
  }

init : (Model, Cmd Msg)
init =
  (Model 0, Cmd.none)


-- UPDATE

type Msg 
  = ClickPokeball

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ClickPokeball ->
      ({ model | pokeballs = model.pokeballs + 1}, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ h2 [] [ text (toString model.pokeballs) ]
    , button [ onClick ClickPokeball ] [ text "Pokeball" ]
    ]