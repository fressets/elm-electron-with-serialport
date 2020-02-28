module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Env exposing (Env)
import Html exposing (Html)
import Page.SerialTest as SerialTestPage
import Route exposing (Route)
import Url


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type Model
    = NotFound Env
    | SerialTest Env SerialTestPage.Model


type alias Flags =
    { url : String }


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init top url key =
    let
        u =
            Url.fromString top.url
    in
    case u of
        Just parsed ->
            changeRouteTo (Route.fromUrl parsed) (NotFound <| Env.create key)

        Nothing ->
            changeRouteTo (Route.fromUrl url) (NotFound <| Env.create key)



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotSerialTestMsg SerialTestPage.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    let
        env =
            toEnv model
    in
    case ( message, model ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case Route.fromUrl url of
                        Just _ ->
                            ( model, Nav.pushUrl (Env.navKey env) (Url.toString url) )

                        Nothing ->
                            ( model, Nav.load <| Url.toString url )

                Browser.External href ->
                    if String.length href == 0 then
                        ( model, Cmd.none )

                    else
                        ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( GotSerialTestMsg subMsg, SerialTest _ subModel ) ->
            SerialTestPage.update subMsg subModel
                |> updateWith (SerialTest env) GotSerialTestMsg

        ( _, _ ) ->
            ( model, Cmd.none )


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        env =
            toEnv model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound env, Cmd.none )

        Just Route.SerialTest ->
            updateWith (SerialTest env) GotSerialTestMsg (SerialTestPage.init ())


toEnv : Model -> Env
toEnv page =
    case page of
        NotFound env ->
            env

        SerialTest env _ ->
            env


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        NotFound _ ->
            Sub.none

        SerialTest _ subModel ->
            Sub.map GotSerialTestMsg (SerialTestPage.subscriptions subModel)



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        viewPage toMsg { title, body } =
            { title = title, body = List.map (Html.map toMsg) body }
    in
    case model of
        NotFound _ ->
            { title = "Not Found", body = [ Html.text "Not Found" ] }

        SerialTest _ subModel ->
            viewPage GotSerialTestMsg (SerialTestPage.view subModel)
