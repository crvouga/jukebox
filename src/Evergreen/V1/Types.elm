module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Navigation
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , message : String
    , tickCount : Int
    }


type alias BackendModel =
    { message : String
    , tickCount : Int
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


type ToFrontend
    = NoOpToFrontend
    | NewTick Int
