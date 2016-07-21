port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.App as App
import Task

import GenericCounter
import Led

main : Program (Maybe Model)
main =
  App.programWithFlags
    { init = init
    , view = view
    , update = updateWithStorage
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  { pokeballCounter: GenericCounter.Model
  , trainerCounter: GenericCounter.Model
  , pokemonCounter: GenericCounter.Model
  , led: Led.Model
  }

emptyModel : Model
emptyModel =
  { pokeballCounter = GenericCounter.Model "Pokeballs" 100 1 0 True
  , trainerCounter = GenericCounter.Model "Trainer" 1 1 0 True
  , pokemonCounter = GenericCounter.Model "Pokemons" 0 1 0 False
  , led = Led.Model False
  }

init : Maybe Model -> (Model, Cmd Msg)
init savedModel =
  Maybe.withDefault emptyModel savedModel ! []

-- UPDATE

type Msg 
  = PokeballCounter GenericCounter.Msg
  | TrainerCounter GenericCounter.Msg
  | PokemonCounter GenericCounter.Msg
  | Led Led.Msg
  | UpdateInventory
  | ResetAll

port setStorage : Model -> Cmd msg

updateWithStorage : Msg -> Model -> (Model, Cmd Msg)
updateWithStorage msg model =
  let
    (newModel, cmds) =
      update msg model
  in
    ( newModel
    , Cmd.batch [ setStorage newModel, cmds ]
    )

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
    TrainerCounter msg ->
      let
        (trainerCounterModel, trainerCounterCmd) = GenericCounter.update msg model.trainerCounter
        ( pokeballCounterModel
        , pokemonCounterModel
        ) = GenericCounter.convert model.pokeballCounter model.pokemonCounter trainerCounterModel
      in
        ({ model 
        | trainerCounter = trainerCounterModel
        , pokeballCounter = pokeballCounterModel
        , pokemonCounter = pokemonCounterModel
        }, Cmd.batch
        [ Cmd.map TrainerCounter trainerCounterCmd
        , updateInventory
        ])
    PokemonCounter msg ->
      let
        (pokemonCounterModel, pokemonCounterCmd) = GenericCounter.update msg model.pokemonCounter
        pokeballCounterModel = GenericCounter.decrementCounter model.pokeballCounter msg pokemonCounterModel
      in
        ({ model 
        | pokemonCounter = pokemonCounterModel
        , pokeballCounter = pokeballCounterModel 
        }, Cmd.batch
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
    ResetAll ->
      (emptyModel, Cmd.none)

updateInventory : Cmd Msg
updateInventory =
  Task.perform (\_ -> Debug.crash "This failure cannot happen.") identity (Task.succeed UpdateInventory)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ Sub.map PokeballCounter (GenericCounter.subscriptions model.pokeballCounter)
  , Sub.map TrainerCounter (GenericCounter.subscriptions model.trainerCounter)
  , Sub.map PokemonCounter (GenericCounter.subscriptions model.pokemonCounter)
  , Sub.map Led (Led.subscriptions model.led)
  ]
  

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ App.map PokeballCounter (GenericCounter.view model.pokeballCounter)
    , App.map TrainerCounter (GenericCounter.view model.trainerCounter)
    , App.map PokemonCounter (GenericCounter.view model.pokemonCounter)
    , br [] []
    , button [ onClick ResetAll ] [ text "Reset ALL" ]
    -- , App.map Led (Led.view model.led)
    ]