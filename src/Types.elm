module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Lamdera exposing (ClientId)
import Set exposing (Set)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , message : String
    , tickCount : Int
    }


type alias BackendModel =
    { message : String
    , tickCount : Int
    , clients : Set ClientId
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg
    | Ticked
    | ClientConnected ClientId
    | ClientDisconnected ClientId


type ToFrontend
    = NoOpToFrontend
    | NewTick Int
