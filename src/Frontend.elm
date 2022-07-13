module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (button, div, input, label, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
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
      }
    , Cmd.none
    )



-- Update


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        ClickedCreateRoom ->
            ( model, Lamdera.sendToBackend CreateRoom )

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


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        GotSession session ->
            ( { model | session = Maybe.Just session }, Cmd.none )

        NewTick tickCount ->
            ( { model | tickCount = Maybe.Just tickCount }, Cmd.none )

        NoOpToFrontend ->
            ( model, Cmd.none )



-- View


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "Jukebox"
    , body =
        [ bootstrapCDN
        , viewSession model
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
            viewHome

        Route.Login ->
            viewLogin


viewHome : Html.Html FrontendMsg
viewHome =
    div
        [ Attr.class "p-4"
        ]
        [ Html.h4 [] [ text "Jukebox" ]
        , button
            [ Attr.class "btn btn-primary btn-block"
            , onClick ClickedCreateRoom
            ]
            [ text "Create Room" ]
        ]


viewLogin : Html.Html msg
viewLogin =
    div [ Attr.class "block" ]
        [ div
            [ Attr.class "mb-3"
            ]
            [ label
                [ Attr.for "emailAddressInput"
                , Attr.class "form-label"
                ]
                [ text "Email address" ]
            , input
                [ Attr.type_ "email"
                , Attr.class "form-control"
                , Attr.id "emailAddressInput"
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


viewTickCount : Model -> Html.Html msg
viewTickCount model =
    Html.text
        (model.tickCount
            |> Maybe.map String.fromInt
            |> Maybe.withDefault "Loading..."
        )
