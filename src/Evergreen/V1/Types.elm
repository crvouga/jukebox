module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V1.Route
import Lamdera
import Url


type alias Session =
    { sessionId : Lamdera.SessionId
    , clientId : Lamdera.ClientId
    }


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , message : String
    , tickCount : Maybe Int
    , route : Evergreen.V1.Route.Route
    , session : Maybe Session
    }


type alias BackendModel =
    { message : String
    , tickCount : Int
    , sessions : Dict.Dict Lamdera.SessionId Session
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg
    | Ticked
    | ClientConnected Lamdera.SessionId Lamdera.ClientId
    | ClientDisconnected Lamdera.SessionId Lamdera.ClientId


type ToFrontend
    = NoOpToFrontend
    | NewTick Int
    | GotSession Session
