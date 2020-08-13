require "./init"
require "./application_controller"

#map("/admin") { run AdminController }
map("/") { run ApplicationController }