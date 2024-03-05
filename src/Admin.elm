module Admin exposing (main)

import Array
import Browser
import Browser.Navigation as Nav
import Debug exposing (log)
import Element exposing (..)
import Element.Background as Back
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Email exposing (isValid)
import File exposing (File)
import File.Select as Select
import Http
import Task
import Url


lorem100 : String
lorem100 =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris viverra elit eget lectus congue, in elementum nisl placerat. Aliquam quis felis est. Donec id quam et nibh posuere molestie. Sed tortor ante, pulvinar non sem at, pulvinar egestas felis. Mauris volutpat quam eu risus mollis finibus nec in erat. Curabitur accumsan nec augue vel interdum. Donec et interdum magna. Pellentesque rutrum lorem dui, eget posuere augue varius ut. Maecenas ac hendrerit ipsum, nec euismod massa. Integer congue dui tincidunt interdum pretium. Suspendisse eleifend est tellus, id semper dolor ultrices vel. Interdum et malesuada fames ac ante ipsum primis in faucibus"


lorem75 : String
lorem75 =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut porta libero ut sapien tempus, at finibus urna volutpat. Nunc erat libero, vulputate sed odio sed, porttitor egestas turpis. Nam efficitur auctor varius. Donec ante libero, feugiat sit amet elit ac, aliquam malesuada nibh. Proin tempor, quam ac mollis dictum, sapien eros pulvinar neque, porta feugiat velit lectus at elit. Fusce cursus purus nibh, a suscipit diam imperdiet sit amet. Integer a felis non velit convallis."


lorem50 : String
lorem50 =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eu vestibulum nisl. Aliquam nec dui sem. Vivamus sit amet purus velit. Morbi sit amet lorem non magna euismod imperdiet quis sed magna. Duis id leo pharetra, elementum libero ut, placerat nisi. Nulla in mauris laoreet, eleifend elit sit amet, porta."


lorem25 : String
lorem25 =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur ut molestie risus, eu lacinia justo. Nunc elit nunc, pellentesque quis vestibulum vel, volutpat nec elit."


lorem n =
    List.foldr (++) "" (List.repeat n lorem25)



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model key url
    , Cmd.none
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    if not (url.path == "/admin") then
                        ( model, Nav.load (Url.toString url) )

                    else
                        ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


inv =
    rgba 0.0 0.0 0.0 0.0


offWhite =
    rgba (233 / 255) (233 / 255) (228 / 255) 0.5


white =
    rgba 1.0 1.0 1.0 1.0


darkGrey =
    rgba (81 / 255) (81 / 255) (77 / 255) 0.1


darkerGrey =
    rgba (81 / 255) (81 / 255) (77 / 255) 1.0


lightGreen =
    rgba (90 / 255) (196 / 255) (136 / 255) 1.0


green =
    rgba (86 / 255) (188 / 255) (130 / 255) 1.0


darkGreen =
    rgba (51 / 255) (85 / 255) (79 / 255) 1.0


red =
    rgba (255 / 255) (87 / 255) (51 / 255) 1.0


hide n =
    el [ transparent True ] (text <| String.repeat n " ")


navlink : String -> String -> Element Msg
navlink name path =
    let
        color =
            if String.toLower name == path then
                lightGreen

            else
                inv
    in
    link
        [ alignRight
        , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
        , Border.color color
        , mouseOver [ Border.color lightGreen ]
        ]
        { url = "/" ++ String.toLower name
        , label = text name
        }


navbar : String -> Element Msg
navbar path =
    row [ width fill, paddingXY 35 35, spacing 35, Font.size 32 ]
        [ link [ alignLeft ]
            { url = "/home"
            , label =
                image [ height (px 80) ]
                    { src = "/assets/f7_logo.png"
                    , description = "Family 7 Logo and Link"
                    }
            }
        , el [ Font.size 50 ] (text "Sherie's Admin Panel")
        ]


fheader : String -> Element Msg
fheader str =
    el [ alignTop, Font.heavy, Font.size 16, Font.color darkGreen ] (text str)


flink : String -> String -> Element Msg
flink str ln =
    link
        [ alignTop, Font.size 14, Font.color darkGreen, mouseOver [ Font.color lightGreen ] ]
        { url = ln
        , label = text str
        }


footer : Element Msg
footer =
    row [ width fill, paddingXY 35 35, spaceEvenly, Back.color darkGrey ]
        [ link [ alignTop, height fill ]
            { url = "/home"
            , label =
                image [ alignTop, height (px 50) ]
                    { src = "/assets/f7_logo.png"
                    , description = "Family 7 Logo and Link"
                    }
            }
        , column [ alignTop, spacing 4 ]
            [ fheader "Contact"
            , flink "Press Inquiries" "mailto:press@family7foundations.com"
            , flink "Get Family7 in Your State" "mailto:expand@family7foundations.com"
            ]
        , column [ alignTop, spacing 4 ]
            [ fheader "Data"
            , flink "Family Progression" "/data"
            ]
        , column [ alignTop, spacing 4 ]
            [ fheader "Admin"
            , flink "Teachers" "/teachers"
            , flink "Reports" "/admin"
            ]
        , column [ alignTop, spacing 4 ]
            [ fheader "Legal"
            , flink "Site Terms of Use" "/terms"
            , flink "Privacy Policy" "/policy"
            , flink "Security" "/security"
            ]
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Family 7 Foundations"
    , body =
        [ layout []
            (column [ width fill, Back.color offWhite ]
                [ navbar (String.dropLeft 1 model.url.path)
                , admin model
                , footer
                ]
            )
        ]
    }



-- PAGES


admin model =
    row [] [ el [] (text "hello world") ]
