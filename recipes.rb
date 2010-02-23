require 'haml'
require 'dm-core'
require 'dm-validations'

#
# Configuration
#

configure :development do
 DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/recipes-dev.db")
 DataMapper::Logger.new(STDOUT, :debug)
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/recipes.db")
end

#
# Model
#

class Recipe
  include DataMapper::Resource
  
  property :id,           Serial
  property :title,        String
  property :slug,         String
end

DataMapper.auto_upgrade!

#
# Controller
#

# List
get '/' do
  haml :list, :locals => { :rs => Recipe.all }
end

# Show
get '/:id' do |id|
  haml :show, :locals => { :r => Recipe.get(id) }
end

# New / Create
get '/new' do
  haml :form, :locals => {
    :r => Recipe.new,
    :action => '/create'
  }
end

post '/create' do
  r = Recipe.new
  r.attributes = params
  r.save

  redirect("/#{r.id}")
end

# Edit / Update
get '/:id/edit' do |id|
  c = Contact.get(id)
  haml :form, :locals => {
    :r => r,
    :action => "/#{r.id}/update"
  }
end

post '/:id/update' do |id|
  r = Recipe.get(id)
  r.update_attributes params

  redirect "/#{id}"
end

# Delete
post '/:id/delete' do |id|
  r = Recipe.get(id)
  r.destroy

  redirect "/"
end

#
# View
#

use_in_file_templates!

__END__

@@ layout
%html
  %head
    %title Recipes
  %body
    = yield
    %a(href="/") Recipes list

@@ form
%h1 Add a new recipe
%form(id="add-recipe" action="#{action}" method="POST")
  %label(for="title") Title
  %input(type="text" id="title" name="title" value="#{r.title}")
  %br
  
  %label(for="slug") Slug
  %input(type="text" id="slug" name="slug" value="#{r.slug}")
  %br

  %input(type="submit")
  %input(type="reset")

- unless r.id == 0
  %form(action="/#{r.id}/delete" method="POST")
    %input(type="submit" value="Delete")
  
@@ show
%table
  %tr
    %td Title
    %td= r.title
%a(href="/#{r.id}/edit") Edit recipe

@@ list
%h1 Recipes
%a(href="/new") New recipe
%table
  - rs.each do |r|
    %tr
      %td= r.title
      %td
        %a(href="/#{r.id}") Show
      %td
        %a(href="/#{r.id}/edit") Edit