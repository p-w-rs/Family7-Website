module EMAIL

include("SMTPClient/SMTPClient.jl")
using .SMTPClient

export send_email

url = "smtps://$(ENV["BRIDGE_HOST"]):$(ENV["BRIDGE_PORT"])"
opt = SendOptions(
  isSSL=true,
  username=ENV["BRIDGE_UNAME"],
  passwd=ENV["BRIDGE_PASS"],
  cacert=ENV["BRIDGE_CERT"],
  verbose=true
)


function send_email(name, sender, receiver, subject, message, attachments)
    global url, opt

    to = [receiver]
    from = sender
    replyto = sender
    body = get_body(to, from, subject, get_mime_msg(message); replyto, attachments)
    #=data = read(body, String)
    open("body.txt", "w") do file
       write(file, data)
    end
    body = IOBuffer(data)=#
    resp = send(url, to, from, body, opt)
end

function send_email(name, sender, receiver, subject, message)
    global url, opt

    to = [receiver]
    from = sender
    replyto = sender
    body = get_body(to, from, subject, get_mime_msg(message); replyto)
    resp = send(url, to, from, body, opt)
end


end # module
