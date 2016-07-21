module GenericCounter exposing 
  ( Model
  , Msg
  , init
  , update
  , view
  , subscriptions
  , setEpc
  , setEps
  , setEnabled
  , decrementCounter
  , convert
  )

import Html exposing (..)
import Html.Attributes exposing (disabled)
import Html.Events exposing (..)
import Time exposing (Time, second)

-- MODEL

type alias Model =
  { label: String 
  , count: Int
  , epc: Int
  , eps: Int
  , enabled: Bool
  }

init : String -> Int -> Bool -> (Model, Cmd Msg)
init label epc enabled =
  (Model label 0 epc 0 enabled, Cmd.none)

-- UPDATE

type Msg 
  = Click
  | Idle Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Click ->
      ({ model | count = model.count + model.epc}, Cmd.none)
    Idle time ->
      ({ model | count = model.count + model.eps}, Cmd.none)

setEpc : Model -> Int -> Model
setEpc model epc =
  ({ model | epc = epc })

setEps : Model -> Int -> Model
setEps model eps =
  ({ model | eps = eps })

setEnabled : Model -> Model -> Model
setEnabled model modelNeeded =
  let
    enabled = if modelNeeded.count >= 10 then True else False
  in
    { model | enabled = enabled }

decrementCounter: Model -> Msg -> Model -> Model
decrementCounter model msg modelNeeded =
  case msg of
    Click ->
      { model | count = model.count - modelNeeded.epc * 10 }
    Idle time ->
      { model | count = model.count - modelNeeded.eps * 10 }

convert: Model -> Model -> Model -> (Model, Model)
convert modelWasted modelGained modelNeeded =
  let
    investment = modelNeeded.count * 10
    wastedAmount = if modelWasted.count >= investment then investment else 0
    gainedAmount = if wastedAmount > 0 then wastedAmount // 10 else 0
  in
    ( { modelWasted | count = modelWasted.count - wastedAmount }
    , { modelGained | count = modelGained.count + gainedAmount }
    )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every second Idle

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ h2 [] [ text (toString model.count) ]
    , button [ onClick Click, disabled (not model.enabled) ] [ text model.label ]
    , if model.eps > 0 then renderEpsLabel model else br [] []
    ]

renderEpsLabel : Model -> Html Msg
renderEpsLabel model =
  div []
    [ br [] []
    , span [] [ text (model.label ++ "/s " ++ toString model.eps) ]
    ]