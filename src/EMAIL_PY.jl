module EMAIL

using PyCall
pushfirst!(pyimport("sys")."path", "./src")
EmailSender = pyimport("EmailSender")
email_sender = EmailSender.EmailSender(ENV["BRIDGE_HOST"], ENV["BRIDGE_PORT"], ENV["BRIDGE_UNAME"], ENV["BRIDGE_PASS"], ENV["BRIDGE_CERT"])

export send_email

function send_email(from_name, sender_addr, receiver_addr, subject, message, attachments)
    println("Sending Email with att")
    global email_sender
    #email_sender = EmailSender.EmailSender(ENV["BRIDGE_HOST"], ENV["BRIDGE_PORT"], ENV["BRIDGE_UNAME"], ENV["BRIDGE_PASS"], ENV["BRIDGE_CERT"])
    email_sender.send_email(from_name, sender_addr, receiver_addr, subject, message, attachments)
    #email_sender.close_server()
end

function send_email(from_name, sender_addr, receiver_addr, subject, message)
    println("Sending Email sem att")
    global email_sender
    #email_sender = EmailSender.EmailSender(ENV["BRIDGE_HOST"], ENV["BRIDGE_PORT"], ENV["BRIDGE_UNAME"], ENV["BRIDGE_PASS"], ENV["BRIDGE_CERT"])
    email_sender.send_email(from_name, sender_addr, receiver_addr, subject, message)
    #email_sender.close_server()
end

end # module
