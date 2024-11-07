using HTTP, Oxygen, StructTypes, Base.Threads

#include("EMAIL_PY.jl")
#using .EMAIL

include("PreloadedAssets.jl")
using .PreloadedAssets

staticfiles("static", "static")
staticfiles("static/assets", "assets")

@get "/" function(req::HTTP.Request)
    return html(index_html)
end

@get "/*" function(req::HTTP.Request)
    return html(index_html)
end

#=@get "/teachers" function(req::HTTP.Request)
    return html(teachers_html)
end

@get "/admin" function(req::HTTP.Request)
    return html(admin_html)
end

admin_message(name, email, other) = "Name: $name\nEmail: $email\nOther: $other"
candidate_message(name) = "Hello $name,\n\nThank you for your interest in Family 7 Foundations.\nWe have received your application and will be in touch soon.\n\nBest,\nFamily 7 Recruiting Team"
@post "/new_candidate/{name}/{email}/{other}" function(req::HTTP.Request, name::String, email::String, other::String)
    filename = joinpath(tempdir(), "$name resume.pdf")
    open(filename, "w") do file
        write(file, req.body)
    end
    send_email("Family 7 Recruiting", "do-not-reply@family7f.com", "careers@family7f.com", "New Application", admin_message(name, email, other), [filename])
    send_email("Family 7 Recruiting", "do-not-reply@family7f.com", email, "Thank you for you application", candidate_message(name))
    return html("OK")
    end=#

serveparallel()
