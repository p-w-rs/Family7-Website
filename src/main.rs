#![allow(dead_code)]
#![allow(unused_variables)]
#![allow(unused_imports)]
#![allow(unused_mut)]
#[macro_use] extern crate rocket;

use std::path::{Path, PathBuf};
use rocket::fs::{NamedFile, TempFile};
use rocket::response::status;

use rocket::http::Header;
use rocket::{Request, Response};
use rocket::fairing::{Fairing, Info, Kind};

pub struct Cors;

#[rocket::async_trait]
impl Fairing for Cors {
    fn info(&self) -> Info {
        Info {
            name: "Add CORS headers to responses",
            kind: Kind::Response
        }
    }

    async fn on_response<'r>(&self, _request: &'r Request<'_>, response: &mut Response<'r>) {
        response.set_header(Header::new("Access-Control-Allow-Origin", "*"));
        response.set_header(Header::new(
            "Access-Control-Allow-Methods",
            "POST, PATCH, PUT, DELETE, HEAD, OPTIONS, GET",
        ));
        response.set_header(Header::new("Access-Control-Allow-Headers", "*"));
        response.set_header(Header::new("Access-Control-Allow-Credentials", "true"));
    }
}

#[get("/")]
async fn index() -> Option<NamedFile> {
    NamedFile::open(Path::new("./static/index.html")).await.ok()
}

#[get("/admin")]
async fn admin() -> Option<NamedFile> {
    NamedFile::open(Path::new("./static/admin.html")).await.ok()
}

#[get("/teachers")]
async fn teachers() -> Option<NamedFile> {
    NamedFile::open(Path::new("./static/teachers.html")).await.ok()
}

#[get("/<_..>")]
async fn index_route() -> Option<NamedFile> {
    NamedFile::open(Path::new("./static/index.html")).await.ok()
}

#[get("/static/<file..>")]
async fn files(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("./static/").join(file)).await.ok()
}

#[get("/assets/<file..>")]
async fn assets(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("./static/assets/").join(file)).await.ok()
}

#[post("/new_candidate/<name>/<email>/<other>", format = "application/pdf", data = "<file>")]
async fn new_candidate(name: &str, email: &str, other: &str, mut file: TempFile<'_>) -> status::Accepted<String> {
    file.persist_to(Path::new(
        &format!("./.data/resumes/{}.pdf", 0)
    )).await.ok();
    status::Accepted(Some(format!("Thank You!")))
}

#[post("/drop_candidate/<id>")]
async fn drop_candidate(id: u64) -> status::Accepted<String> {
    status::Accepted(Some(format!("Thank You!")))
}

#[launch]
fn rocket() -> _ {
    rocket::build().attach(Cors).mount("/", routes![index, admin, teachers, index_route, files, assets, new_candidate, drop_candidate])
}
