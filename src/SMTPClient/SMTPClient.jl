module SMTPClient

using Distributed
using LibCURL
using Dates
using Base64
using Markdown

import Base: convert
import Sockets: send

export SendOptions, SendResponse, send
export get_body, get_mime_msg

include("utils.jl")
include("types.jl")
include("cbs.jl")  # callbacks
include("mail.jl")
include("mime_types.jl")
include("user.jl")

##############################
# Module init/cleanup
##############################

function __init__()
  curl_global_init(CURL_GLOBAL_ALL)

  global c_curl_write_cb =
    @cfunction(curl_write_cb, Csize_t, (Ptr{Cchar}, Csize_t, Csize_t, Ptr{Cvoid}))
  global c_curl_read_cb =
    @cfunction(curl_read_cb,  Csize_t, (Ptr{Cchar}, Csize_t, Csize_t, Ptr{Cvoid}))

  atexit() do
    curl_global_cleanup()
  end
end


end  # module SMTPClient
