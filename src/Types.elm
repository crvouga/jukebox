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
    , rooms : Rooms
    , roomName : String
    , status : Status
    }


type Status
    = Idle
    | Loading
    | Resulted CreateRoomResult


type alias BackendModel =
    { message : String
    , tickCount : Int
    , sessions : Dict SessionId Session
    , rooms : Rooms
    , runningRoomId : Int
    }


type alias Rooms =
    Dict Int Room


type alias Room =
    { name : String }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | ClickedCreateRoom
    | InputtedRoomName String
    | ClickedCloseError


type ToBackend
    = NoOpToBackend
    | CreateRoom { name : String }


type BackendMsg
    = NoOpBackendMsg
    | Ticked
    | ClientConnected SessionId ClientId
    | ClientDisconnected SessionId ClientId


type ToFrontend
    = NoOpToFrontend
    | NewTick Int
    | GotSession Session
    | CreateRoomResulted CreateRoomResult
    | Sync { rooms : Rooms }


type alias CreateRoomResult =
    Result CreateRoomProblem Rooms


type CreateRoomProblem
    = InvalidRoomName


type alias Session =
    { sessionId : SessionId
    , clientId : ClientId
    , name : Maybe String
    }
