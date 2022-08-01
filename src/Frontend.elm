
module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict
import Html exposing (a, article, button, div, i, input, label, p, span, text)
import Html.Attributes as Attr exposing (attribute, class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Lamdera
import Maybe
import Route
import Types exposing (..)
import Url



-- Model


type alias Model =
    FrontendModel



-- Main


type alias App =
    { init : Lamdera.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
    , view : Model -> Browser.Document FrontendMsg
    , update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
    , updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
    , subscriptions : Model -> Sub FrontendMsg
    , onUrlRequest : UrlRequest -> FrontendMsg
    , onUrlChange : Url.Url -> FrontendMsg
    }


app : App
app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \_ -> Sub.none
        , view = view
        }



-- Init


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , message = "HELLO"
      , tickCount = Maybe.Nothing
      , route = url |> Route.fromUrl |> Maybe.withDefault Route.Home
      , session = Maybe.Nothing
      , rooms = Dict.empty
      , roomName = ""
      , status = Idle
      }
    , Cmd.none
    )



-- Update


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged _ ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        ClickedCreateRoom ->
            ( { model | status = Loading }, Lamdera.sendToBackend (CreateRoom { name = model.roomName }) )

        InputtedRoomName roomName ->
             ( { model | roomName = roomName, status = Idle }, Cmd.none )

        ClickedCloseError ->
            ( { model | status = Idle }, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        GotSession session ->
            ( { model | session = Maybe.Just session }, Cmd.none )

        NewTick tickCount ->
            ( { model | tickCount = Maybe.Just tickCount }, Cmd.none )

        CreateRoomResulted result ->
            case result of
                Ok rooms ->
                    ( { model | status = Resulted result, rooms = rooms, roomName = "" }, Cmd.none )

                Err _ ->
                    ( { model | status = Resulted result }, Cmd.none )

        NoOpToFrontend ->
            ( model, Cmd.none )

        Sync { rooms } ->
            ( { model | rooms = rooms }, Cmd.none )



-- View


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "Jukebox"
    , body =
        [ bulmaCDN
        , viewMain model
        ]
    }


viewSession : Model -> Html.Html msg
viewSession model =
    case model.session of
        Nothing ->
            div [] [ text "Loading session..." ]

        Just session ->
            div [] [ text ("sessionId " ++ session.sessionId) ]


viewMain : Model -> Html.Html FrontendMsg
viewMain model =
    case model.route of
        Route.Home ->
            viewHome model

        Route.Login ->
            viewLogin


viewHome : Model -> Html.Html FrontendMsg
viewHome model =
    div
        [ Attr.class "px-4 py-4"
        ]
        [ Html.h1
            [ Attr.class "title" ]
            [ text "Jukebox" ]
        , div [ class "field" ]
            [ label [ class "label" ]
                [ text "Room Name" ]
            , div [ class "control" ]
                [ input
                    [ class
                        (if isInvalidRoomName model then
                            "input is-danger"

                         else
                            "input"
                        )
                    , placeholder "Enter room name"
                    , type_ "email"
                    , value model.roomName
                    , onInput (\roomName -> InputtedRoomName roomName)
                    ]
                    []
                ]
            , if isInvalidRoomName model then
                p [ class "help is-danger" ]
                    [ text "Invalid room name" ]

              else
                p [] []
            ]
        , button
            [ Attr.class
                (String.join " "
                    [ "button is-primary is-fullwidth"
                    , if model.status == Loading then
                        "is-loading"

                      else
                        ""
                    ]
                )
            , onClick ClickedCreateRoom
            ]
            [ text "Create Room" ]
        , div []
            (model.rooms
                |> Dict.toList
                |> List.map Tuple.second
                |> List.map (\room -> viewRoomPanel { roomName = room.name })
            )
        ]


isInvalidRoomName : Model -> Bool
isInvalidRoomName model =
    case model.status of
        Idle ->
            False

        Loading ->
            False

        Resulted result ->
            case result of
                Ok _ ->
                    False

                Err problem ->
                    case problem of
                        InvalidRoomName ->
                            True


viewStatus : Model -> Html.Html FrontendMsg
viewStatus model =
    case model.status of
        Idle ->
            div [] []

        Loading ->
            div [] []

        Resulted result ->
            case result of
                Ok _ ->
                    div [] []

                Err problem ->
                    case problem of
                        InvalidRoomName ->
                            article [ class "message is-danger mt-2" ]
                                [ div [ class "message-header" ]
                                    [ p []
                                        [ text "Invalid room name" ]
                                    , button [ attribute "aria-label" "delete", class "delete", onClick ClickedCloseError ]
                                        []
                                    ]
                                ]


viewRoomPanel : { roomName : String } -> Html.Html msg
viewRoomPanel { roomName } =
    a [ class "panel-block is-active" ]
        [ span [ class "panel-icon" ]
            [ i [ attribute "aria-hidden" "true", class "fas fa-book" ]
                []
            ]
        , text roomName
        ]


viewLogin : Html.Html msg
viewLogin =
    div [ Attr.class "block" ]
        [ div
            [ Attr.class "mb-3"
            ]
            [ label
                [ Attr.for "roomNameInput"
                , Attr.class "form-label"
                ]
                [ text "Email address" ]
            , input
                [ Attr.type_ "email"
                , Attr.class "form-control"
                , Attr.id "roomNameInput"
                , Attr.attribute "aria-describedby" "emailHelp"
                ]
                []
            ]
        , div
            [ Attr.class "mb-3"
            ]
            [ label
                [ Attr.for "exampleInputPassword1"
                , Attr.class "form-label"
                ]
                [ text "Password" ]
            , input
                [ Attr.type_ "password"
                , Attr.class "form-control"
                , Attr.id "exampleInputPassword1"
                ]
                []
            ]
        , button
            [ Attr.class "btn btn-primary btn-block"
            ]
            [ text "Submit" ]
        ]


bootstrapCDN : Html.Html msg
bootstrapCDN =
    Html.node "link"
        [ Attr.href "https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css"
        , Attr.rel "stylesheet"
        , Attr.attribute "integrity" "sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC"
        , Attr.attribute "crossorigin" "anonymous"
        ]
        []


bulmaCDN : Html.Html msg
bulmaCDN =
    Html.node "link"
        [ Attr.href "https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css"
        , Attr.rel "stylesheet"
        ]
        []


viewTickCount : Model -> Html.Html msg
viewTickCount model =
    Html.text
        (model.tickCount
            |> Maybe.map String.fromInt
            |> Maybe.withDefault "Loading..."
        )
