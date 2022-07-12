module Route exposing (..)

import Html
import Html.Attributes as Attr
import Maybe
import Url
import Url.Parser


type Route
    = Home
    | Login


parser : Url.Parser.Parser (Route -> a) a
parser =
    Url.Parser.oneOf
        [ Url.Parser.map Home Url.Parser.top
        , Url.Parser.map Login (Url.Parser.s "login")
        ]


fromUrl : Url.Url -> Maybe Route
fromUrl url =
    { url
        | path = Maybe.withDefault "" url.fragment
        , fragment = Nothing
    }
        |> Url.Parser.parse parser


href : Route -> Html.Attribute msg
href route =
    Attr.href (routeToString route)


routeToString : Route -> String
routeToString page =
    "#/" ++ String.join "/" (routeToPieces page)


routeToPieces : Route -> List String
routeToPieces route =
    case route of
        Home ->
            []

        Login ->
            [ "login" ]
