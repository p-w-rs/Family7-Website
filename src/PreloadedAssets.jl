module PreloadedAssets

export index_html, teachers_html, admin_html

file = open("static/index.html", "r")
index_html = read(file, String)
close(file)

file = open("static/teachers.html", "r")
teachers_html = read(file, String)
close(file)

file = open("static/admin.html", "r")
admin_html = read(file, String)
close(file)

end # module
