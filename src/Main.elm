import Html exposing (..)
import Html.App as App
import Task

import GenericCounter
import Led

main: Program Never
main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

-- MODEL

type alias Model =
  { pokeballCounter: GenericCounter.Model
  , pokemonCounter: GenericCounter.Model
  , led: Led.Model
  }

init : (Model, Cmd Msg)
init =
  let
    (pokeballCounterModel, pokeballCounterCmd) = GenericCounter.init "Pokeballs" 1 True
    (pokemonCounterModel, pokemonCounterCmd) = GenericCounter.init "Pokemons" 1 False
    (ledModel, ledCmd) = Led.init
  in
    (Model pokeballCounterModel pokemonCounterModel ledModel, Cmd.batch 
    [ Cmd.map PokeballCounter pokeballCounterCmd
    , Cmd.map Led ledCmd
    ])

-- UPDATE

type Msg 
  = PokeballCounter GenericCounter.Msg
  | PokemonCounter GenericCounter.Msg
  | Led Led.Msg
  | UpdateInventory

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UpdateInventory ->
      let
        pokemonCounterModel = GenericCounter.setEnabled model.pokemonCounter model.pokeballCounter
      in
        ({ model
        | pokemonCounter = pokemonCounterModel
        }, Cmd.none)
    PokeballCounter msg ->
      let
        (pokeballCounterModel, pokeballCounterCmd) = GenericCounter.update msg model.pokeballCounter
      in
        ({ model | pokeballCounter = pokeballCounterModel }, Cmd.batch
        [ Cmd.map PokeballCounter pokeballCounterCmd
        , updateInventory
        ])
    PokemonCounter msg ->
      let
        (pokemonCounterModel, pokemonCounterCmd) = GenericCounter.update msg model.pokemonCounter
        pokeballCounterModel = GenericCounter.decrementCounter model.pokeballCounter msg pokemonCounterModel
      in
        ({ model 
        | pokemonCounter = pokemonCounterModel
        , pokeballCounter = pokeballCounterModel }, Cmd.batch
        [ Cmd.map PokeballCounter pokemonCounterCmd
        , updateInventory
        ])
    Led msg ->
      let
        (ledModel, ledCmd) = Led.update msg model.led
        pps = if Led.active ledModel then 5 else 0
        pokeballCounterModel = GenericCounter.setEps model.pokeballCounter pps
      in
        ({ model | led = ledModel , pokeballCounter = pokeballCounterModel }, Cmd.map Led ledCmd)

updateInventory : Cmd Msg
updateInventory =
  Task.perform (\_ -> Debug.crash "This failure cannot happen.") identity (Task.succeed UpdateInventory)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ Sub.map PokeballCounter (GenericCounter.subscriptions model.pokeballCounter)
  , Sub.map PokemonCounter (GenericCounter.subscriptions model.pokemonCounter)
  , Sub.map Led (Led.subscriptions model.led)
  ]
  

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ App.map PokeballCounter (GenericCounter.view model.pokeballCounter)
    , App.map PokemonCounter (GenericCounter.view model.pokemonCounter)
    , br [] []
    , App.map Led (Led.view model.led)
    ]