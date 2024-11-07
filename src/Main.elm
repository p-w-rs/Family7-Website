module Main exposing (main)

import Array
import Browser
import Browser.Events exposing (onResize)
import Browser.Navigation as Nav
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
import MyUtils exposing (..)
import Url



-- MAIN


main : Program Flags Model Msg
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


type alias Flags =
    { width : Int
    , height : Int
    }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , device : Device
    , active_story : Int
    , name : String
    , email : String
    , other : String
    , resName : String
    , resume : Maybe File
    , error : Maybe Bool
    , errorMsg : Maybe String
    }


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model key url (classifyDevice flags) 0 "" "" "" "" Nothing Nothing Nothing
    , Cmd.none
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | DeviceClassified Device
    | Select Int
    | SetName String
    | SetEmail String
    | SetOther String
    | ResumeRequested
    | ResumeLoaded File
    | Upload
    | Uploaded (Result Http.Error String)


upload : File.File -> String -> String -> String -> Cmd Msg
upload file name email other =
    let
        url =
            if other == "" then
                "/new_candidate" ++ "/" ++ name ++ "/" ++ email ++ "/" ++ "!"

            else
                "/new_candidate" ++ "/" ++ name ++ "/" ++ email ++ "/" ++ other
    in
    Http.post
        { url = url
        , body = Http.fileBody file
        , expect = Http.expectString Uploaded
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    if url.path == "/admin" || url.path == "/teachers" then
                        ( model, Nav.load (Url.toString url) )

                    else
                        ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        DeviceClassified device ->
            ( { model | device = device }
            , Cmd.none
            )

        Select idx ->
            ( { model | active_story = idx }
            , Cmd.none
            )

        SetName str ->
            ( { model | name = str }
            , Cmd.none
            )

        SetEmail str ->
            ( { model | email = str }
            , Cmd.none
            )

        SetOther str ->
            ( { model | other = str }
            , Cmd.none
            )

        ResumeRequested ->
            ( model
            , Select.file [ "application/pdf" ] ResumeLoaded
            )

        ResumeLoaded file ->
            ( { model | resName = File.name file, resume = Just file }
            , Cmd.none
            )

        Upload ->
            let
                validForm =
                    not (model.name == "" || model.resName == "") && isValid model.email
            in
            case ( validForm, model.resume ) of
                ( True, Just resume ) ->
                    ( model, upload resume model.name model.email model.other )

                _ ->
                    ( { model | error = Just True }, Cmd.none )

        Uploaded result ->
            case result of
                Ok str ->
                    ( { model | errorMsg = Just str, error = Just False, name = "", email = "", other = "", resName = "", resume = Nothing }, Cmd.none )

                Err err ->
                    case err of
                        Http.BadUrl url ->
                            ( { model | errorMsg = Just url, error = Just True }, Cmd.none )

                        Http.Timeout ->
                            ( { model | errorMsg = Just "timeout", error = Just True }, Cmd.none )

                        Http.NetworkError ->
                            ( { model | errorMsg = Just "network error", error = Just True }, Cmd.none )

                        Http.BadStatus _ ->
                            ( { model | errorMsg = Just "bad status", error = Just True }, Cmd.none )

                        Http.BadBody _ ->
                            ( { model | errorMsg = Just "bad body", error = Just True }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    onResize <|
        \width height ->
            DeviceClassified (classifyDevice { width = width, height = height })



-- VIEW :: MAIN


view : Model -> Browser.Document Msg
view model =
    let
        page =
            case model.url.path of
                "/" ->
                    home model

                "/home" ->
                    home model

                "/mission" ->
                    mission model

                "/stories" ->
                    stories model

                "/careers" ->
                    careers model

                "/terms" ->
                    terms

                "/policy" ->
                    policy

                _ ->
                    page404
    in
    { title = "Family 7 Foundations"
    , body =
        [ layout
            [ Font.size 18
            , Font.family
                [ Font.typeface "Helvetica"
                , Font.sansSerif
                ]
            ]
            (column [ height fill, width fill, Back.color <| white 1.0 ]
                [ -- el [] (Maybe.withDefault "nothing" model.stuff |> text)
                  navbar [ "Careers" ] (String.dropLeft 1 model.url.path)
                , page
                , footer
                ]
            )
        ]
    }



-- VIEW :: NAVIGATION


navlink : String -> Bool -> Element Msg
navlink name active =
    let
        color =
            if active then
                f7f_blue 1.0

            else
                inv
    in
    link
        [ alignRight
        , paddingXY 0 8
        , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
        , Border.color color
        , mouseOver [ Border.color <| f7f_blue 1.0 ]
        ]
        { url = "/" ++ String.toLower name
        , label = text name
        }


navbar : List String -> String -> Element Msg
navbar paths path =
    row [ width fill, paddingXY 45 25, spacing 45, Font.color <| white 1.0, Font.size 32, Back.color <| f7f_black 1.0 ]
        (link [ alignLeft ]
            { url = "/home"
            , label =
                image [ height (px 100) ]
                    { src = f7f_logo_inv
                    , description = "Family 7 Logo and Link"
                    }
            }
            :: List.map
                (\p -> navlink p (path == String.toLower p))
                paths
        )



-- VIEW :: FOOTER


fheader : String -> Element Msg
fheader str =
    el [ alignTop, Font.heavy, Font.size 16, Font.color <| white 1.0 ] (text str)


flink : String -> String -> Element Msg
flink str ln =
    link
        [ alignTop, Font.size 14, Font.color <| f7f_blue 1.0, mouseOver [ Font.color <| f7f_green 1.0 ] ]
        { url = ln
        , label = text str
        }


footer : Element Msg
footer =
    row [ width fill, paddingXY 35 25, spaceEvenly, Back.color <| f7f_black 1.0 ]
        [ link [ alignTop, height fill ]
            { url = "/home"
            , label =
                image [ centerY, height (px 100) ]
                    { src = f7f_icon_inv
                    , description = "Family 7 Icon and Link"
                    }
            }
        , column [ alignTop, paddingXY 0 8, spacing 5 ]
            [ fheader "Contact"
            , flink "Press Inquiries" "mailto:pr@family7foundations.com"
            , flink "Get Family7 in Your State" "mailto:join@family7foundations.com"
            ]
        , column [ alignTop, paddingXY 0 8, spacing 5 ]
            [ fheader "Data"
            , flink "Family Progression" "/data"
            ]
        , column [ alignTop, paddingXY 0 8, spacing 5 ]
            [ fheader "Admin"
            , flink "Teachers" "/teachers"
            , flink "Reports" "/admin"
            ]
        , column [ alignTop, paddingXY 0 8, spacing 5 ]
            [ fheader "Legal"
            , flink "Site Terms of Use" "/terms"
            , flink "Privacy Policy" "/policy"
            ]
        ]



-- VIEW :: PAGES
{- home model =
   column [ height fill, width fill, paddingXY 35 50, spacing 75 ]
       [ row [ width fill, spacing 50 ]
           [ paragraph [ width fill ]
               [ el [ Font.size 20, Font.bold, Font.color <| f7f_blue 1.0 ] (text "Family 7 Foundations")
               , text " is a dedicated organization working hand-in-hand with state authorities to provide pivotal social work services for families at risk. Our primary goal is to "
               , el [ Font.size 20, Font.bold, Font.color <| f7f_blue 1.0 ] (text "keep families intact")
               , text ", offering a lifeline to parents who are on the verge of losing their children to state custody or face limited visitation rights. Through our home-based training sessions, our specialized teachers deliver an "
               , el [ Font.size 20, Font.bold, Font.color <| f7f_blue 1.0 ] (text "expertly crafted curriculum")
               , text ", ensuring parents are well-equipped with the essential skills, knowledge, and understanding required to create a safe, nurturing environment for their children."
               ]
           , image [ width fill, Border.glow (f7f_blue 1.0) 3 ]
               { src = family_front
               , description = "A picture of a happy family"
               }
           ]
       , paragraph [ width fill, Font.size 25 ]
           [ el [ Font.size 28, Font.bold, Font.color <| f7f_blue 1.0 ] (text "Family 7 Foundations")
           , text " is the bridge between at-risk families and the brighter future they deserve, offering tailored training and support to ensure every child remains in a loving, safe home."
           ]
       ]
-}


homeBullet the_text =
    row [ height fill, spacing 20 ]
        [ el [ alignLeft, Font.size 50, Font.bold, Font.color <| f7f_blue 1.0 ] (text "•")
        , paragraph [ alignRight, Font.size 32 ] [ text the_text ]
        ]


home model =
    column [ height fill, width fill, paddingXY 35 50, spacing 75 ]
        [ wrappedRow [ width fill, spacing 50 ]
            [ paragraph [ width fill, Font.size 25 ]
                [ el [ Font.size 26, Font.bold, Font.color <| f7f_blue 1.0 ] (text "Family 7 Foundations")
                , text " is a contracted provider for the State of Utah. We are a comprehensive, in-home, "
                , el [ Font.size 26, Font.bold, Font.color <| f7f_blue 1.0 ] (text "ADAPTIVE")
                , text " program that serves families where one or of both parents struggle with an "
                , el [ Font.size 26, Font.bold, Font.color <| f7f_blue 1.0 ] (text "Intellectual Disability OR Related Cause")
                , text " such as: "
                , el [ Font.size 26, Font.bold, Font.color <| f7f_blue 1.0 ] (text "ADHD")
                , text ", "
                , el [ Font.size 26, Font.bold, Font.color <| f7f_blue 1.0 ] (text "PTSD")
                , text ", "
                , el [ Font.size 26, Font.bold, Font.color <| f7f_blue 1.0 ] (text "Addiction")
                , text ", "
                , el [ Font.size 26, Font.bold, Font.color <| f7f_blue 1.0 ] (text "Dyslexia")
                , text ", "
                , el [ Font.size 26, Font.bold, Font.color <| f7f_blue 1.0 ] (text "TBI")
                , text ", "
                , el [ Font.size 26, Font.bold, Font.color <| f7f_blue 1.0 ] (text "Low IQ")
                , text ", or any other intellectual disability that needs extra support to learn and retain information."
                ]
            , image [ width fill, Border.glow (f7f_blue 1.0) 3 ]
                { src = family_front
                , description = "A picture of a happy family"
                }
            ]
        , hide 0
        , column [ width fill, Font.size 25, spacing 35 ]
            [ el [ Font.size 28, Font.bold, Font.color <| f7f_blue 1.0 ] (text "Our Program Includes:")
            , homeBullet "Evidence based curriculum"
            , homeBullet "24 teachers across the state"
            , homeBullet "25, 90-minute-long sessions of in-home education and support for the family"
            , homeBullet "A weekly partner report sent to the case manager sharing progress and/or concerns"
            , homeBullet "Adaptable curriculum to meet caseworker’s concerns, parent’s abilities and much more"
            , homeBullet "The 5 protective factors"
            , homeBullet "Child safety, discipline, organization, routines, finances, co-parenting, home and personal hygiene, among many other topics are covered in this comprehensive course."
            ]
        , hide 0
        , paragraph [ width fill, Font.size 25 ]
            [ el [ Font.size 28, Font.bold, Font.color <| f7f_blue 1.0 ] (text "Family 7 Foundations")
            , text " is ready to help. Please consider referring your families that qualify for these enlightening and empowering classes. Please follow all directions as outlined by DHHS in referring a family for services."
            ]
        ]



--------------------------------------------------------------------------------


msBullet value the_text =
    row [ width fill, height fill, spacing 35 ]
        [ el [ alignLeft, Font.size 50, Font.bold, Font.color <| f7f_blue 1.0, width (fillPortion 1) ] (text value)
        , paragraph [ alignRight, Font.size 35, width (fillPortion 2) ] [ text the_text ]
        ]


mission model =
    column [ height fill, width fill, paddingXY 35 50, spacing 60, Back.image watermark ]
        [ hide 0
        , paragraph [ alignLeft, Font.size 45, Font.semiBold, width (fill |> maximum 450) ]
            [ text "At Family 7, through "
            , el [ Font.bold, Font.color <| f7f_blue 1.0 ] (text "Empowerment")
            , text ", "
            , el [ Font.bold, Font.color <| f7f_blue 1.0 ] (text "Intervention")
            , text ", "
            , el [ Font.bold, Font.color <| f7f_blue 1.0 ] (text "Education")
            , text ", and unwavering "
            , el [ Font.bold, Font.color <| f7f_blue 1.0 ] (text "Support")
            , text ", we foster "
            , el [ Font.bold, Font.color <| f7f_blue 1.0 ] (text "Unity")
            , text ", enabling families to thrive together."
            ]
        , hide 0
        , hide 0
        , msBullet "Empowerment" "Equipping parents with the skills for a nurturing home."
        , msBullet "Intervention" "Stepping in before families reach the point of separation."
        , msBullet "Education" "Providing an evidence based curriculum tailored for family success."
        , msBullet "Support" "Offering advice, guidance, and unwavering commitment at every step."
        , msBullet "Unity" "Strengthening family bonds, ensuring every child grows in love and security."
        ]



--------------------------------------------------------------------------------


story_imgs : Array.Array String
story_imgs =
    Array.fromList [ story1, story2, story3, story4 ]


story_titles : Array.Array String
story_titles =
    Array.fromList [ "The Washington Family", "The Bennett Family", "The Malik-Jamal Family", "The Garcia Family" ]


story_cont : Array.Array String
story_cont =
    Array.fromList
        [ "Malik and Tasha Washington always envisioned a loving household for their kids, Isaiah and Keisha. Growing up in underprivileged neighborhoods, both parents experienced the repercussions of inadequate parental guidance, leading to cycles of miscommunication and misunderstandings within their family. Tasha, having experienced the foster care system herself, feared her children might end up in a similar situation. Enter Family 7 Foundations. Through our programs, the Washingtons were introduced to effective communication strategies, emotional support, and tools to break free from generational patterns. Today, Isaiah excels in school and Keisha is an aspiring artist, both flourishing in a cohesive and loving family environment."
        , "Andre and Emily Bennett were the epitome of a modern family. With Andre's deep African roots and Emily's Midwestern upbringing, their twins, Lucas and Lily, were exposed to a rich blend of cultures. However, the challenges of interracial marriage coupled with the complexities of previous relationships and the stress of a prior separation for Andre took its toll. Lucas and Lily were caught amidst the occasional discord. Family 7 Foundations stepped in, offering them resources to understand each other's cultural backgrounds, tools to effectively co-parent, and workshops to unite their family. Their journey with Family 7 led them to embrace their mixed heritage, fostering an environment where Lucas and Lily felt secure and cherished."
        , "Kareem, an African-American, and Yasmeen, hailing from the Middle East, faced unique challenges as a couple, not least of which were societal stigmas and cultural clashes. Kareem's previous marriage and the subsequent battles over custody of his firstborn were harrowing experiences. Meanwhile, Yasmeen struggled with her immigration status, amplifying the family's anxiety. Their children, Amir and Layla, often felt the brunt of these stresses. Family 7 Foundations intervened with holistic solutions: from helping Yasmeen navigate her immigration complexities to counseling sessions for Kareem regarding his past. Through Family 7, the Malik-Jamal family learned to redefine their identity, prioritize their unity, and create a harmonious household for Amir and Layla."
        , "Miguel and Rosa Garcia immigrated to the U.S. with dreams of a brighter future for their children, Diego and Sofia. However, the challenges of assimilating into a new culture, coupled with the pressures of sustaining a family in unfamiliar territory, were overwhelming. Rosa grappled with isolation and homesickness, while Miguel faced discrimination at work. These hardships affected their home environment, causing Diego to struggle academically and Sofia to become withdrawn. When Family 7 Foundations was introduced to the Garcias, a transformation began. Our educators provided the family with tools to cope with external pressures and to rebuild their home's emotional foundation. Diego's school performance improved, and Sofia discovered a love for community service, with both children becoming beacons of hope and resilience."
        ]


storyDot : Int -> Int -> Element Msg
storyDot idx activeIdx =
    let
        color =
            if idx == activeIdx then
                f7f_blue 1.0

            else
                f7f_black 1.0
    in
    el
        [ width (px 15)
        , height (px 15)
        , Border.width 2
        , Border.rounded 15
        , Border.color <| f7f_black 1.0
        , Back.color color
        , mouseOver [ Border.color <| f7f_black 1.0, Back.color <| f7f_blue 1.0 ]
        , Events.onClick (Select idx)
        , pointer
        ]
        none


storyDots : Int -> Element Msg
storyDots activeIdx =
    row [ centerX, padding 15, spacing 15 ]
        [ storyDot 0 activeIdx
        , storyDot 1 activeIdx
        , storyDot 2 activeIdx
        , storyDot 3 activeIdx
        ]


blueLine w =
    el
        [ centerX
        , width (px w)
        , height (px 4)
        , Back.color <| f7f_blue 1.0
        , Border.color <| f7f_blue 1.0
        , Border.width 4
        , Border.rounded 4
        , moveDown 15.0
        ]
        none


stories : Model -> Element Msg
stories model =
    let
        src =
            Maybe.withDefault "" (Array.get model.active_story story_imgs)

        title =
            Maybe.withDefault "" (Array.get model.active_story story_titles)

        content =
            Maybe.withDefault "" (Array.get model.active_story story_cont)
    in
    column [ height fill, width fill, paddingEach { bottom = 50, top = 0, left = 0, right = 0 }, spacing 50 ]
        [ image [ width fill, height (px 450), below (storyDots model.active_story) ]
            { src = src
            , description = "A picture of a family"
            }
        , el [ centerX, Font.size 60, Font.semiBold, below <| blueLine 300 ] (text title)
        , paragraph [ centerX, paddingXY 300 0 ] [ text content ]
        ]



--------------------------------------------------------------------------------


input_form : (String -> msg) -> String -> String -> String -> Element msg
input_form msg typedtext holdertext labeltext =
    Input.text []
        { onChange = msg
        , text = typedtext
        , placeholder = Just <| Input.placeholder [ Font.italic ] (text holdertext)
        , label = Input.labelAbove [] (text labeltext)
        }


email_form : (String -> msg) -> String -> String -> String -> Element msg
email_form msg typedtext holdertext labeltext =
    Input.email []
        { onChange = msg
        , text = typedtext
        , placeholder = Just <| Input.placeholder [ Font.italic ] (text holdertext)
        , label = Input.labelAbove [] (text labeltext)
        }


input_multi : (String -> msg) -> String -> String -> String -> Element msg
input_multi msg typedtext holdertext labeltext =
    Input.multiline [ height (fill |> minimum 150) ]
        { onChange = msg
        , text = typedtext
        , placeholder = Just <| Input.placeholder [ Font.italic ] (text holdertext)
        , label = Input.labelAbove [] (text labeltext)
        , spellcheck = True
        }


selectedFile : String -> Maybe a -> Element msg
selectedFile name file =
    case file of
        Nothing ->
            el [] none

        Just _ ->
            el [ moveLeft 15, padding 10, Font.color <| f7f_green 1.0 ] (text name)


submitMessage : Maybe Bool -> Element msg
submitMessage error =
    case error of
        Nothing ->
            el [] none

        Just bool ->
            if bool then
                el [ alignLeft, Font.alignLeft, moveLeft 15, padding 10, Font.color <| f7f_red 1.0 ] (text "Submission Error!\nCheck form and try again.")

            else
                el [ alignLeft, Font.alignLeft, moveLeft 15, padding 10, Font.color <| f7f_green 1.0 ] (text "Submission Success!\nAwait email confirmation.")



{- careers : Model -> Element Msg
   careers model =
       column [ height fill, width fill, spacing 50, paddingXY 35 50 ]
           [ paragraph [ centerX, Font.size 60, Font.semiBold ]
               [ el [ Font.bold, Font.color <| f7f_blue 1.0 ] (text "Be a beacon of hope")
               , text " – Join our passionate team of educators at Family 7 Foundations and make a lasting impact on families' futures."
               ]
           , row [ width fill, spaceEvenly ]
               [ column [ width (fill |> maximum 600), padding 35, spacing 25, Back.color <| f7f_grey 0.5, Border.width 5, Border.rounded 10, Border.color <| f7f_black 1.0 ]
                   [ input_form SetName model.name "Enter your name..." "Name (Required)"
                   , email_form SetEmail model.email "Enter your email..." "Email (Required)"
                   , input_multi SetOther model.other "Any other information you'd like..." "Extra Info (Optional)"
                   , hide 0
                   , blueLine 450
                   , hide 0
                   , row [ width fill, spacing 50, centerX ]
                       [ Input.button
                           [ focused [], centerX, Font.center, width (px 200), padding 15, mouseOver [ Back.color <| f7f_green 1.0 ], Back.color <| f7f_blue 1.0, Border.width 5, Border.rounded 10, Border.color <| f7f_black 1.0, below <| selectedFile model.resName model.resume ]
                           { onPress = Just ResumeRequested
                           , label = text "Upload Resume"
                           }
                       , Input.button
                           [ focused [], centerX, Font.center, width (px 200), padding 15, mouseOver [ Back.color <| f7f_green 1.0 ], Back.color <| f7f_blue 1.0, Border.width 5, Border.rounded 10, Border.color <| f7f_black 1.0, below <| submitMessage model.error ]
                           { onPress = Just Upload
                           , label = text "Submit Form"
                           }
                       ]
                   , hide 0
                   ]
               ]
           ]
-}


careers : Model -> Element Msg
careers model =
    column [ height fill, width fill, spacing 50, paddingXY 35 50 ]
        [ paragraph [ centerX, Font.size 60, Font.semiBold ]
            [ el [ Font.bold, Font.color <| f7f_blue 1.0 ] (text "Be a beacon of hope")
            , text " – Join our passionate team of educators at Family 7 Foundations and make a lasting impact on families' futures."
            ]
        , row [ width fill, spaceEvenly ]
            [ column [ width (fill |> maximum 600), padding 35, spacing 25, Back.color <| f7f_grey 0.5, Border.width 5, Border.rounded 10, Border.color <| f7f_black 1.0 ]
                [ paragraph [ Font.center, padding 20 ]
                    [ text "Interested in joining our team? Please send your resume to:\n"
                    , link [ Font.size 32, Font.color <| f7f_blue 1.0, mouseOver [ Font.color <| f7f_green 1.0 ] ]
                        { url = "mailto:hr@family7f.com"
                        , label = text "hr@family7f.com"
                        }
                    ]
                ]
            ]
        ]



--------------------------------------------------------------------------------


terms =
    column [ centerX, height fill ] []


policy =
    column [ centerX, height fill ] []


page404 =
    column [ centerX, height fill ]
        [ el [ padding 45, centerX, Font.color <| f7f_red 1.0, Font.size 48 ] (text "404 Not Found")
        , hide 0
        , el [ padding 10, alignLeft, Font.size 30 ] (text "The page you're looking for was not found.")
        , paragraph [ padding 10, centerX, Font.center, Font.size 30 ]
            [ text "Please go back to the "
            , link
                [ Font.color <| f7f_blue 1.0, mouseOver [ Font.color <| f7f_green 1.0 ] ]
                { url = "/"
                , label = text "home page"
                }
            ]
        ]
