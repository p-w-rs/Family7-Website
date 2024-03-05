module MyUtils exposing (..)

import Element exposing (el, rgba, text, transparent)



-- ASSET PATHS


f7f_logo =
    "/assets/f7f_logo.png"


f7f_icon =
    "/assets/f7f_icon.png"


f7f_logo_inv =
    "/assets/f7f_logo_inv.png"


f7f_icon_inv =
    "/assets/f7f_icon_inv.png"


family_front =
    "/assets/family_front.jpg"


watermark =
    "/assets/watermark.webp"


story1 =
    "/assets/story1.jpg"


story2 =
    "/assets/story2.jpg"


story3 =
    "/assets/story3.jpg"


story4 =
    "/assets/story4.jpg"


story5 =
    "/assets/story5.jpg"



-- COLORS


f7f_blue alpha =
    rgba (69 / 255) (129 / 255) (142 / 255) alpha


f7f_light_blue alpha =
    rgba (69 / 255) (92 / 255) (142 / 255) alpha


f7f_green alpha =
    rgba (51 / 255) (102 / 255) (82 / 255) alpha


f7f_red alpha =
    rgba (187 / 255) (53 / 255) (24 / 255) alpha


f7f_black alpha =
    rgba (51 / 255) (51 / 255) (51 / 255) alpha


f7f_grey alpha =
    rgba (77 / 255) (77 / 255) (77 / 255) alpha


white alpha =
    rgba 1.0 1.0 1.0 alpha


inv =
    rgba 0.0 0.0 0.0 0.0



-- FILLERS


hide n =
    el [ transparent True ] (text <| String.repeat n " ")


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
