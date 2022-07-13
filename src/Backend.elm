module Backend exposing (..)

import Dict
import Lamdera exposing (ClientId, SessionId)
import Types exposing (..)



-- Model


type alias Model =
    BackendModel



-- App


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



-- Init


init : ( Model, Cmd BackendMsg )
init =
    ( { message = "Hello!"
      , tickCount = 0
      , sessions = Dict.empty
      }
    , Cmd.none
    )



-- Update


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        ClientConnected sessionId clientId ->
            let
                session : Session
                session =
                    { sessionId = sessionId
                    , clientId = clientId
                    }
            in
            ( { model
                | sessions =
                    Dict.insert sessionId session model.sessions
              }
            , Lamdera.sendToFrontend clientId (GotSession session)
            )

        ClientDisconnected sessionId _ ->
            ( { model
                | sessions =
                    Dict.remove sessionId model.sessions
              }
            , Cmd.none
            )

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

        CreateRoom ->
            ( model, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub BackendMsg
subscriptions _ =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        , Lamdera.onDisconnect ClientDisconnected
        ]
