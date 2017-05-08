port module App exposing (..)

import Html exposing (Html, Attribute, div, span, ul, li, input, text, programWithFlags)
import Html.Attributes exposing (style, autofocus, placeholder, value)
import Html.Events exposing (on, keyCode, onInput)
import Json.Decode as Decode
import Json.Encode as Encode
import Json.Decode.Pipeline exposing (decode, required)
import Dom.Scroll exposing (toBottom)
import Task


-- PORTS


port loadUserData : () -> Cmd msg


port connectSocket : String -> Cmd msg


port sendMessage : String -> Cmd msg


port onUserData : (String -> msg) -> Sub msg


port onConnect : (String -> msg) -> Sub msg


port onMessages : (String -> msg) -> Sub msg



-- FLAGS


type alias Flags =
    { host : String
    }



-- MODEL


type alias Model =
    { messages : List Message
    , user : User
    , inputText : String
    , flags : Flags
    }


type alias User =
    { username : String
    , color : String
    }


type alias Message =
    { username : String
    , color : String
    , payload : String
    }


defaultUser : User
defaultUser =
    { username = ""
    , color = ""
    }


initialModel : Flags -> Model
initialModel flags =
    { messages = []
    , user = defaultUser
    , inputText = ""
    , flags = flags
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags, loadUserData () )



-- DECODERS


decodeUser : String -> User
decodeUser string =
    case Decode.decodeString userDecoder string of
        Ok user ->
            user

        Err _ ->
            defaultUser


userDecoder : Decode.Decoder User
userDecoder =
    decode User
        |> required "username" Decode.string
        |> required "color" Decode.string


decodeMessages : String -> List Message
decodeMessages string =
    case Decode.decodeString messagesDecoder string of
        Ok messages ->
            messages

        Err _ ->
            []


messagesDecoder : Decode.Decoder (List Message)
messagesDecoder =
    Decode.list messageDecoder


messageDecoder : Decode.Decoder Message
messageDecoder =
    decode Message
        |> required "username" Decode.string
        |> required "color" Decode.string
        |> required "payload" Decode.string



-- ENCODERS


encodeMessage : Message -> Encode.Value
encodeMessage { username, color, payload } =
    Encode.object
        [ ( "username", Encode.string username )
        , ( "color", Encode.string color )
        , ( "payload", Encode.string payload )
        ]



-- HELPERS


socketUrl : Flags -> String
socketUrl { host } =
    "ws://" ++ host ++ "/chat-room"



-- MESSAGES


type Msg
    = NoOp
    | OnConnect String
    | OnUserData String
    | OnMessages String
    | KeyDown Int
    | OnInput String



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        OnConnect _ ->
            let
                message =
                    encodeMessage
                        { username = model.user.username
                        , color = model.user.color
                        , payload = "Se unió a la sala"
                        }
            in
                ( model, sendMessage (Encode.encode 0 message) )

        OnUserData data ->
            let
                user =
                    decodeUser data
            in
                ( { model | user = user }, connectSocket (socketUrl model.flags) )

        OnMessages data ->
            let
                messages =
                    decodeMessages data
            in
                ( { model | messages = messages }
                , Task.attempt (always NoOp) (toBottom "body")
                )

        KeyDown key ->
            let
                message =
                    encodeMessage
                        { username = model.user.username
                        , color = model.user.color
                        , payload = model.inputText
                        }

                trimmedText =
                    String.trim model.inputText
            in
                if key == 13 && trimmedText /= "" then
                    ( { model | inputText = "" }
                    , sendMessage (Encode.encode 0 message)
                    )
                else
                    ( model, Cmd.none )

        OnInput text ->
            ( { model | inputText = text }, Cmd.none )



-- CUSTOM EVENTS


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Decode.map tagger keyCode)



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ ul [] (List.map message model.messages)
        , input
            [ autofocus True
            , placeholder "Enter a message..."
            , onKeyDown KeyDown
            , onInput OnInput
            , value model.inputText
            ]
            []
        ]


message : Message -> Html Msg
message { username, color, payload } =
    li []
        [ span [ style [ ( "color", color ) ] ]
            [ text (username ++ ": ") ]
        , span [] [ text payload ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onConnect OnConnect
        , onUserData OnUserData
        , onMessages OnMessages
        ]



-- PROGRAM


main : Program Flags Model Msg
main =
    programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
