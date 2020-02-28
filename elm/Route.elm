module Route exposing (Route(..), fromUrl, href, parser, routeToString)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = SerialTest


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map SerialTest (Parser.s "elm-electron-app")
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                SerialTest ->
                    []

    in
    "/elm-electron-app/" ++ String.join "/" pieces
