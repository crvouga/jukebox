module Backend exposing (..)

import Html
import Lamdera exposing (ClientId, SessionId)
import Set
import Time
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { message = "Hello!"
      , tickCount = 0
      , clients = Set.empty
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        ClientConnected clientId ->
            ( { model | clients = Set.insert clientId model.clients }, Cmd.none )

        ClientDisconnected clientId ->
            ( { model | clients = Set.remove clientId model.clients }, Cmd.none )

        Ticked ->
            let
                tickCountNew =
                    model.tickCount + 1
            in
            ( { model | tickCount = tickCountNew }, Lamdera.broadcast (NewTick tickCountNew) )

        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : Lamdera.SessionId -> Lamdera.ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )


subscriptions model =
    Sub.batch
        [ Time.every 1000 (\t -> Ticked)
        , Lamdera.onConnect onConnect
        , Lamdera.onDisconnect onDisconnect
        ]


onConnect : SessionId -> ClientId -> BackendMsg
onConnect sessionId clientId =
    ClientConnected clientId


onDisconnect : SessionId -> ClientId -> BackendMsg
onDisconnect sessionId clientId =
    ClientDisconnected clientId
