module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Lamdera exposing (ClientId, SessionId)
import Maybe exposing (Maybe)
import Route exposing (Route)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , message : String
    , tickCount : Maybe Int
    , route : Route
    , session : Maybe Session
    }


type alias BackendModel =
    { message : String
    , tickCount : Int
    , sessions : Dict SessionId Session
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | ClickedCreateRoom


type ToBackend
    = NoOpToBackend
    | CreateRoom


type BackendMsg
    = NoOpBackendMsg
    | Ticked
    | ClientConnected SessionId ClientId
    | ClientDisconnected SessionId ClientId


type ToFrontend
    = NoOpToFrontend
    | NewTick Int
    | GotSession Session


type alias Session =
    { sessionId : SessionId
    , clientId : ClientId
    }
