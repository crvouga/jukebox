module Backend exposing (..)

import Html
import Lamdera exposing (ClientId, SessionId)
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
    ( { message = "Hello!", tickCount = 0 }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        Ticked ->
            let
                tickCountNew =
                    model.tickCount + 1
            in
            ( { model | tickCount = tickCountNew }, Lamdera.broadcast (NewTick tickCountNew) )

        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )


subscriptions model =
    Time.every 1000 (\t -> Ticked)
