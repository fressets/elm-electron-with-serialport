port module Page.SerialTest exposing (Model, Msg, init, serialConnection, subscriptions, update, updateSerial, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)



-- PORT


port updateSerial : () -> Cmd msg


port serialConnection : (String -> msg) -> Sub msg



-- MODEL


type alias Model =
    { isConnected : String
    , redData : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { isConnected = "接続", redData = "" }, Cmd.none )



-- UPDATE


type Msg
    = UpdateSerialConnection
    | IncomingSerialState String
    | ReadQRCode String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateSerialConnection ->
            ( model, updateSerial () )

        IncomingSerialState str ->
            ( { model | isConnected = str }, Cmd.none )

        ReadQRCode str ->
            ( { model | redData = model.redData ++ str }, Cmd.none )



-- VIEW


view : Model -> { title : String, body : List (Html Msg) }
view model =
    { title = "SerialConnection Test"
    , body =
        [ section [ class "section" ]
            [ div [ class "container" ]
                [ button [ class "button", onClick UpdateSerialConnection ] [ text model.isConnected ]
                , div [ class "tile is-parent" ]
                    [ article [ class "tile is-child has-background-black has-text-white" ]
                        [ p [] [ text model.redData ]
                        ]
                    ]
                ]
            ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ serialConnection IncomingSerialState ]
