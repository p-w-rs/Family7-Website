module Teachers exposing (main)

import Array
import Browser
import Browser.Navigation as Nav
import Date exposing (Date, compare, day, month, weekday, year)
import DatePicker exposing (DateEvent(..), defaultSettings, getInitialDate)
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
import Html
import Http
import MyUtils exposing (..)
import Task
import Time exposing (Weekday(..))
import Url



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
    , caseWorker : String
    , familyName : String
    , educationCoordinator : String
    , numSessionsTaught : Maybe Int
    , whichSessionsTaught : Maybe Int
    , otherTaughtDetails : String
    , visitDate : String
    , startTime : String
    , endTime : String
    , milesDriven : Maybe Float
    , region : String
    , date : Maybe Date
    , datePicker : DatePicker.DatePicker
    }


settings : DatePicker.DatePicker -> DatePicker.Settings
settings datePicker =
    let
        isDisabled : Date -> Date -> Bool
        isDisabled today date =
            Date.compare (Date.add Date.Weeks -1 today) date /= LT
    in
    { defaultSettings | isDisabled = isDisabled (getInitialDate datePicker) }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( datePicker, datePickerFx ) =
            DatePicker.init
    in
    ( Model key url "" "" "" Nothing Nothing "" "" "" "" Nothing "" Nothing datePicker
    , Cmd.map ToDatePicker datePickerFx
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | UpCaseWorker String
    | UpFamilyName String
    | UpEducationCoordinator String
    | UpNumSessionsTaught String
    | UpWhichSessionsTaught String
    | UpOtherTaughtDetails String
    | UpVisitDate String
    | UpStartTime String
    | UpEndTime String
    | UpMilesDriven String
    | UpRegion String
    | ToDatePicker DatePicker.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    if not (url.path == "/teachers") then
                        ( model, Nav.load (Url.toString url) )

                    else
                        ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        UpCaseWorker str ->
            ( { model | caseWorker = str }, Cmd.none )

        UpFamilyName str ->
            ( { model | familyName = str }, Cmd.none )

        UpEducationCoordinator str ->
            ( { model | educationCoordinator = str }, Cmd.none )

        UpNumSessionsTaught int ->
            let
                value =
                    case String.toInt int of
                        Just n ->
                            Just <| clamp 1 2 n

                        Nothing ->
                            Nothing
            in
            ( { model | numSessionsTaught = value }, Cmd.none )

        UpWhichSessionsTaught int ->
            let
                value =
                    case String.toInt int of
                        Just n ->
                            Just <| clamp 0 25 n

                        Nothing ->
                            Nothing
            in
            ( { model | whichSessionsTaught = value }, Cmd.none )

        UpOtherTaughtDetails str ->
            ( { model | otherTaughtDetails = str }, Cmd.none )

        UpVisitDate str ->
            ( { model | visitDate = str }, Cmd.none )

        UpStartTime str ->
            ( { model | startTime = str }, Cmd.none )

        UpEndTime str ->
            ( { model | endTime = str }, Cmd.none )

        UpMilesDriven flt ->
            ( { model | milesDriven = String.toFloat flt }, Cmd.none )

        UpRegion str ->
            ( { model | region = str }, Cmd.none )

        ToDatePicker subMsg ->
            let
                ( newDatePicker, dateEvent ) =
                    DatePicker.update (settings model.datePicker) subMsg model.datePicker

                newDate =
                    case dateEvent of
                        Picked changedDate ->
                            Just changedDate

                        _ ->
                            model.date
            in
            ( { model | date = newDate, datePicker = newDatePicker }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


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
        , el [ Font.size 50 ] (text "Teacher Report Submissions")
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
                , teachers model
                , footer
                ]
            )
        ]
    }



-- PAGES


input_field msg typedtext labeltext holdertext =
    Input.text []
        { onChange = msg
        , text = typedtext
        , placeholder = Just <| Input.placeholder [ Font.italic ] (text holdertext)
        , label = Input.labelAbove [] (text labeltext)
        }


input_field_int msg num labeltext holdertext =
    let
        typedtext =
            case num of
                Just n ->
                    String.fromInt n

                Nothing ->
                    ""
    in
    Input.text []
        { onChange = msg
        , text = typedtext
        , placeholder = Just <| Input.placeholder [ Font.italic ] (text holdertext)
        , label = Input.labelAbove [] (text labeltext)
        }


input_field_float msg num labeltext holdertext =
    let
        typedtext =
            case num of
                Just n ->
                    String.fromFloat n

                Nothing ->
                    ""
    in
    Input.text []
        { onChange = msg
        , text = typedtext
        , placeholder = Just <| Input.placeholder [ Font.italic ] (text holdertext)
        , label = Input.labelAbove [] (text labeltext)
        }


datePickerView model =
    column []
        [ html
            (case model.date of
                Nothing ->
                    Html.h1 [] [ Html.text "Pick a date" ]

                Just date ->
                    Html.h1 [] [ Html.text <| Date.format "MMM d, yyyy" date ]
            )
        , html
            (DatePicker.view model.date (settings model.datePicker) model.datePicker
                |> Html.map ToDatePicker
            )
        ]


teachers model =
    column [ paddingXY 35 35, spacing 45 ]
        [ wrappedRow [ spacing 15 ]
            [ input_field UpCaseWorker model.caseWorker "Case Worker" "Your name here"
            , input_field UpFamilyName model.familyName "Family Name" "Name of family you taught"
            , input_field UpEducationCoordinator model.educationCoordinator "Educational Coordinator" "Name of Coordinator"
            ]
        , wrappedRow [ spacing 15 ]
            [ input_field_int UpNumSessionsTaught model.numSessionsTaught "Number of Sessions Taught" "1 or 2"
            , input_field_int UpWhichSessionsTaught model.whichSessionsTaught "Which Sessions Numbers Were Taught" "1 - 25 or 0 for elective/other"
            , input_field UpOtherTaughtDetails model.otherTaughtDetails "If Elective or Other Explain Here" "Prior approval required"
            ]
        , datePickerView model
        , wrappedRow [ spacing 15 ]
            [ input_field UpStartTime model.startTime "Start Time of Visit" "..."
            , input_field UpEndTime model.endTime "End Time of Visit" "..."
            , input_field_float UpMilesDriven model.milesDriven "Miles Driven" "..."
            ]
        , input_field UpRegion model.region "Utah Region" "..."
        ]
