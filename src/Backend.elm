module Backend exposing (..)

import Lamdera exposing (ClientId, SessionId)
import Set
import Time
import Types exposing (..)


type alias Model =
    BackendModel


type alias App =
    { init : ( Model, Cmd BackendMsg )
    , update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
    , updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
    , subscriptions : Model -> Sub BackendMsg
    }


app : App
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


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend _ _ msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )


subscriptions : Model -> Sub BackendMsg
subscriptions _ =
    Sub.batch
        [ Lamdera.onConnect onConnect
        , Lamdera.onDisconnect onDisconnect
        ]


onConnect : SessionId -> ClientId -> BackendMsg
onConnect _ clientId =
    ClientConnected clientId


onDisconnect : SessionId -> ClientId -> BackendMsg
onDisconnect _ clientId =
    ClientDisconnected clientId
