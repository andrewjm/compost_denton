http://www.zenspider.com/Languages/Ruby/QuickRef.html#4 Really good quick reference

# Compost Denton Rails App

The Compost Denton app was originally developed on a MEAN stack (Mongo, ExpressJS, AngularJS, NodeJS) by some wonderful developer friends. These notes are intended to detail the development of an identical app using Rails and Postgres.

## Why migrate to Rails?

Quite honestly, this decision was made for personal reasons. Our app experiences modest traffic even at it's busiest times. The current MEAN stack is working fine. I am now in the position of overseeing all technical requirements for Compost Denton. The current app lacks a few features that would take some time to develop and, given my growing interest in Rails, I would prefer to dedicate that time towards not only developing the app but also learning Rails.

## DB Data Migration

I needed to move all production data from MongoDB into Postgres (and Sqlite because that is what I'm running locally to develop and test). Some tools I think I'll need to be aware of:

* **mongoexport**: can dump all mongodb data into a CSV
* **postgis**: geospatial data support for postgres
* **spatialite**: geospatial data support for SQlite

Stackoverflow has [suggestions](http://stackoverflow.com/questions/2987433/how-to-import-csv-file-data-into-a-postgres-table) about how to achieve this.

## Models / DB Schema

MongoDB is a document bases no-sql database, thus it does not feature a schema exactly. However, I'll need one for Postgres.

### Mongo Documents

#### Users Collection

```javascript
var UserSchema = new Schema({
    firstName: String,
    lastName: String,
    email: {
        type: String,
        unique: true
    },
    addressLineOne: String,
    addressLineTwo: String,
    zipCode: Number,
    geometry: {				// lat/long from address
      type: { type: String },
      coordinates: {}
    },
    numberResidents: Number,
    binId: Number,			// no longer needed
    weightLog: [{
        weight: Number,
        date: Date
    }],
    weightUpdateDate: {			// no longer needed
        type: Date
    },
    totalWeight: {			// no longer needed
        type: Number,
        default: 0
    },
    customerId: String,			// for stripe (?)
    subscribed: {			// stripe
        type: Boolean,
        default: false
    },
    role: {
        type: String,
        default: 'member'
    },
    registration: {			// was user created through reg form?
        type: Boolean,
        default: false
    },
    creationDate: {
        type: Date,
        default: Date.now
    },
    hashed_password: String,
    provider: String,
    salt: String,
    facebook: {},			// not needed
    twitter: {},			// not needed
    github: {},				// not needed
    google: {},				// not needed
    linkedin: {}			// not needed
});
```

### Ruby Models

* **user**: user CRUD and relation definitions
* **pickups**: pickups CRUD and relation definitions

### Postgres Schema

#### Users Table

Name            | Type    | Key         | Unique | Default
--------------- | ------- | ----------- | ------ | -------
id              | int     | primary     | yes    |
firstName       | string  |             |        | 
lastName        | string  |             |        | 
email           | string  |             | yes    |
addressLineOne  | string  |             |        | 
addressLineTwo  | string  |             |        | 
zip             | int     |             |        | 
latitude        | point   |             |        | 
longitude       | point   |             |        | 
numberResidents | int     |             |        | 
customerId      | string  |             | yes    |
subscribed      | boolean |             |        | false
role            | string  |             |        | 'member'
registration    | boolean |             |        | false
creationDate    | date    |             |        | now()
hashed_pw       | string  |             |        | 

#### Pickups Table

Name            | Type    | Key         | Unique | Default
--------------- | ------- | ----------- | ------ | -------
id              | int     | primary     | yes    | 
user_id         | int     | foreign     |        | 
weight          | float   |             |        | 
date            | date    |             |        | now()

## Controllers

### Node Controllers

These are not terribly well organized. It's unclear (to me) if the index, admin, and pickups controllers are necessary. Session handling could exist as it's own controller.

* **index**: renders index page (is this necessary?)
* **admin**: admin only actions (can refactor into a the users controller)
* **users**: User CRUD, session handling (the CRUD should go into a model(
* **pickups**: get nearby members
* **stripe**: all things stripe

### Rails Controllers

The controllers I think I want to use:

* **account_activation**: handles activating accounts
* **application**: a base level controller available to all other controllers
* **password_reset**: handles password resets
* **users**: user CRUD, data grabbing
* **session**: creating and destroying sessions
* **static_pages**: handle static page rendering

I am a little confused on best practices for what goes in a controller vs what goes in a model. I plan to follow Michael Hartl's sample twitter apps lead on some of these decisions.

## Getting Started

### Local

Create a new rails app, initialize a git repo, push up to github.

```
$ rails _4.2.0_ new compost_denton
$ cd compost_denton
$ git init
$ git add -A
$ git commit -am 'initialize repo'
$ git remote add origin https://github.com/andrewjm/compost_denton.git
$ git push -u origin master
```

Update Gemfile and install Gems

    $ bundle install --without production

### Production

I already have a Backspace server, so I'd rather use that than Heroku. I know I'll need to do a few things on the Backspace server:

* Install and run Postgres
* Clone the git repo
* Install Ruby
* Install Rails (do I need to do this?)
* Try running the server and see what breaks

Ideally I'd like to setup an automated system that deploys, builds, and service restarts on push to production. This feels like it is a Continuous Integration (CI) task, or perhaps it is just a piece of CI. There is a short tutorial on how to use [git post-receive hooks](https://gist.github.com/thomasfr/9691385) to do this. And [another tutorial](http://krisjordan.com/essays/setting-up-push-to-deploy-with-git). And finally [one last tutorial](http://www.realchaseadams.com/2014/01/deploy-code-with-git-push-and-a-post-receive-hook/). Digital Ocean has a nice [overview of git hooks](https://www.digitalocean.com/community/tutorials/how-to-use-git-hooks-to-automate-development-and-deployment-tasks). Googling 'git push deploy' yields much information.

My production server runs on a Debian Linux box. Install ruby:

    $ sudo apt-get update
    $ sup apt-get install ruby-full

Install Postgres ([info here](https://wiki.debian.org/PostgreSql)):

    $ sudo apt-get install postgresql postgresql-client

Apparently postgres runs automatically after installation. Currently the following ports are taken:

* 3000: Compost Denton Production App
* 3001: DSSD Production App

Leaving port 80 open! So let's just use that one.

Or... why not just use Heroku for free? This [stackoverflow thread](http://stackoverflow.com/questions/10020227/rails-app-starts-very-slowly-in-heroku) explains why first load is slow and offers suggestions.

Add the heroku addon to ping the app every 2 minutes:

    $ heroku addons:add newrelic
    $ heroku addons:docs newrelic

Need to get the domain transferred to me, and also need to setup [Custom Domains on Heroku](https://devcenter.heroku.com/articles/custom-domains).

#### Final Production Server Plans

* A single 1x heroku dyno
* Newrelic add on for performance monitoring and sleep prevention

## Setting up Production Server

```
$ heroku version		#check if installed
$ heroku login
$ heroku keys:add		#add SSH key if needed
$ heroku create			#create space on servers for the app
```

From the Sample App:

* copy Gemfile
* copy Procfile
* copy config/puma.rb

```
$ git add -A
$ git commit -am 'setting up prod server'
$ git push heroku master
$ heroku open
```

Add Newrelic monitoring:

```
$ heroku addons:add newrelic
$ heroku config:set NEW_RELIC_LICENSE_KEY=<key_here>
$ heroku logs
```

Once the newrelic agent is talking with the newrelic server, you have to go into the newrelic gui (through the heroku dashboard) and add the proper URL to have the agent ping.

## The Git workflow

```
$ git checkout -b new-branch-name
```
Do work, make changes, etc.

```
$ bundle exec rake test
$ git add -A
$ git commit -am 'comment here'
$ git checkout master
$ git merge new-branch-name
$ bundle exec rake test
$ git push origin master
$ git push heroku master
```
Run any necessary commands on Heroku

```
$ heroku run rake db:migrate
```

##  Making some Static Page controllers

Generate some controllers

    $ rails g controller StaticPages Home About Faq Partners Pricing Contact

I've brought in views from Sample_App, and the homepage view and css from Compost_Denton. I need to look into pulling in the header and footer views from Compost_Denton as well, and other necessary css.

To make bootstrap javascript available, need to add this bit to app/assets/javascripts/application.js

    //= require bootstrap

## User Management

<<<<<<< HEAD
=======
### User Signup UI

Generate Users controller with page and method 'new'

    rails g controller Users new

update config/routes.rb
update the view at app/views/users/new.html.erb

>>>>>>> 91e52ae88291cfcdebaf65475d5ddb0df30283f0
### Modeling Users

Generate a model and migrate the database

<<<<<<< HEAD
    $ rails g model User name:string email:string:uniq password_digest:string remember_digest:string
    $ bundle exec rake db:migrate
=======
```
rails g model User name:string email:string:uniq password_digest:string
bundle exec rake db:migrate
```
>>>>>>> 91e52ae88291cfcdebaf65475d5ddb0df30283f0

add tests at test/models/user_test.rb
add validations at app/models/user.rb
empty users fixture at test/fixtures/users.yml

run test

<<<<<<< HEAD
    $ bundle exec rake test

### Display Users

Add resources to config/routes.rb for REST

    resources :users

> When following REST principles, resources are typically referenced
> using the resource name and a unique identifier...we should view the
> user with id 1 by issuing a GET request to the URL /users/1...the
> show action is implicit...GET requests are automatically handled by
> the show action.

Create view for displaying a user profile

    $ touch app/views/users/show.html.erb

Will need to manually create a user in the DB to move forward

    $ rails c
    >> User.create(name:'Name Here', email:'email@here.com'
                   password:'password', password_confirmation:'password')

visit <websitename>.com/users/1 to see display in action

### User Signup

Generate Users controller with page and method 'new'

    $ rails g controller Users new

update config/routes.rb
update the view at app/views/users/new.html.erb
update method new at app/controllers/users_controller.rb

    $ bundle exec rake test

add a signup page with form
add a signup method in users controller

setup an integration test for user signup

    $ rails g integration_test users_signup

SSL on production, uncomment this line in config/environments/production.rb

    config.force_ssl = true

Heroku will automatically allow the app to piggyback on it's own SSL cert
as long as SSL is enabled on the app. To setup SSL on Heroku with a custom
domain, refer to this [article on ssl-endpoints](https://devcenter.heroku.com/articles/ssl-endpoint).

### Log in, Log out

    $ git checkout -b login-logout
    $ rails g controller Sessions new

Update config/routes.rb

    get    'login'   => 'sessions#new'
    post   'login'   => 'sessions#create'
    delete 'logout'  => 'sessions#destroy'

The above routes serve the following functions respectively:

* Render the login view
* Create a session upon successful form submissions
* Destroy a session upon logout

Update view at app/views/sessions/new.html.erb
Update controller at app/controllers/sessions\_controller.r
Update app/helpers/sessions\_helper.rb
Update app/models/user.rb

Make an integration test for logins

    $ rails g integration_test users_login

Update:
* test/fixtures/users.yml
* test/integration\_users\_login\_test.rb
* test/integration\_users\_signup\_test.rb
* test/helpers/sessions\_helper.rb
* test/test\_helpber.rb
* app/views/layouts/\_header.html.erb (to change items when logged in)
* app/controllers/application\_controller.rb

### Updating, Showing, and Deleting Users

Update:
* app/controllers/users\_controller.rb
* app/controllers/sessions\_controller.rb

* app/helpers/session\_helper.rb

* app/models.uer.rb

* test/controllers/users\_controller\_test.rb
* test/fixtures/users.yml
* test/integration/users\_edit\_test.rb
* test/integration/users\_index\_test.rb

* app/views/user/edit.html.erb
* app/views/user/index.html.erb
* app/views/user/\_user.html.erb

* db/seeds.rb

Add admin column to users table

    $ rails g migration add\_admin\_to\_users admin:boolean

Default value modifiers are not supported by rails generate migration, so update the migration file to

    add_column :users, :admin, :boolean, default: false

Create and update integration test

    $ rails g integration_test users_edit
    $ rails g integration_test users_index

### Account Activation & Password Reset

A Note of variables:
* Use instance variables if they need to be passed to a view
* Variables should have the narrowest scope possible

*Update*:
* config/environments/production.rb (fill out SMTP settings)
* config/routes.rb
* app/models/user.rb
* app/controllers/users\_controller.rb
* db/seeds.rb
* test/fixtures/users.yml
* config/environments/development.rb
* config/environments/test.rb
* test/models/user\_test.rb
* test/integration/users\_signup\_test.rb
* app/views/sessions/new.html.erb

*NOTE*: A controller generation yields the following:
* controller
* views directory
* controller test
* helper
* coffeescript file
* scss file

#### Account Activation

##### Psuedocode

1. Start users in an “unactivated” state.
2. When a user signs up, generate an activation token and corresponding activation digest.
3. Save the activation digest to the database, and then send an email to the user with a
   link containing the activation token and user’s email address.
4. When the user clicks the link, find the user by email address, and then authenticate
   the token by comparing with the activation digest.
5. If the user is authenticated, change the status from “unactivated” to “activated”.

##### Devel

    $ rails g controller AccountActivations
    $ rails g migration add_activation_to_users activation_digest:string activated:boolean activated_at:datetime

Edit migration file to make 'activated' default value false.

    $ bundle exec rake db:migrate
    $ rails g mailer UserMailer account_activation password_reset

*Note*: 'rails g mailer UserMailer account\_activation\ password\_reset' generates:
* app/mailers/user\_mailer.rb
* app/mailers/application\_mailer.rb
* app/views/user\_mailer
* app/views/layouts/mailer.text.erb
* app/views/layouts/mailer.html.erb
* app/views/user\_mailer/account\_activation.text.erb
* app/views/user\_mailer/account\_activation.html.erb
* app/views/user\_mailer/password\_reset.text.erb
* app/views/user\_mailer/password\_reset.html.erb
* test/mailers/user\_mailer\_test.rb
* test/mailers/previews/user\_mailer\_preview.rb

Mailers are structured much like controller actions, with email templates defined as views.

#### Password Reset

##### Pseudocode

1. When a user requests a password reset, find the user by the submitted email address.
2. If the email address exists in the database, generate a reset token and corresponding
   reset digest.
3. Save the reset digest to the database, and then send an email to the user with a link
   containing the reset token and user’s email address.
4. When the user clicks the link, find the user by email address, and then authenticate
   the token by comparing to the reset digest.
5. If authenticated, present the user with the form for changing the password.

##### Devel

    $ rails g controller PasswordResets new edit --no-test-framework
    $ rails g migration add_reset_to_users reset_digest:string reset_sent_at:datetime
    $ bundle exec rake db:migrate
    $ rails g integration_test password_resets
    $ heroku addons:add sendgrid:starter

Update config/environments/production.rb with SMTP settings, this will require a manual update of 'host' to match heroku app name, unless I can grab the heroku app name via heroku CLI and then use sed to swap it into place in the file.

Git up.

## Custom Featurs

NOTE: We have a problem, it costs $50/mo to use PostGIS on Heroku. (source)[https://addons.heroku.com/heroku-postgresql#standard-0]

### Collecting more Sign up data

* Get necessary data on sign up form (other than credit card/stripe things)
* Geolocate address upon signup
* Ensure users can edit all necessary data
* Ensure geolocation updates upon address update

    $ rails g migration add_custom_fields_to_users first_name:string last_name:string address_line_one:string address_line_two:string city:string zip_code:number number_residents:number
    $ bundle exec db:migrate

### Geolocation

Dependencies:
* RGeo gem
* PostGRES
* PostGIS
* Spatialite (actually I may dev w postgres locally)
* activerecord-postgis-adapter gem
* Ruby Geocoder (gmaps-autocomplete-rails gem already geocodes address, but looks like Geocoder offers 'near' queries)
* Gmaps Autocomplete: https://github.com/kristianmandrup/gmaps-autocomplete-rails

To install postgres gem requires details here: http://postgresapp.com/documentation/configuration-ruby.html you have to use their code on bundle

I have swapped db for psql, migrated db, and cleaned up necessary bits.

See this post for some more details: http://ngauthier.com/2013/08/postgis-and-rails-a-simple-approach.html

Probably needs a controller (and a model?)

*TODO:*

#### Setup PostGIS:

  $ psql
  > \c database\_name
  > create extension postgis;

#### Autocomplete Address Field:

Follow the instructions at https://github.com/kristianmandrup/gmaps-autocomplete-rails

#### Geocode address to lat long on form submission:

The gmaps-autocomplete-rails gem geocodes the address into lat/long.
Setup the activerecord-postgis-adapter gem and its dependencies https://github.com/rgeo/activerecord-postgis-adapter
Setup fields in db table for latlong:
  rails g migration add\_lonlat\_to\_users lonlat:st\_point
  bundle exec rake db:migrate

UPDATE: Geocoder does not require Postgis. Although Postgis looks awesome, it increases cost on Heroku. Geocoder has good documentation,
        looks easy to use, and keeps costs low. I'm going to go with Geocoder and Postgres over RGeo and Postgis

Geocoder is working, however address\_line\_one is not saving in db. Need to investigate.. is now saving, attr\_accessor was getting in the way

Working on UI branch. Finish up ui that I can, then move onto creating two more tables (members, weight), as well as fxn to make new members etc.

#### Add Members

I'm going to follow Chapter 11 'User Microposts' for these steps, as well at Section 6 in http://guides.rubyonrails.org/getting\_started.html

Members db table:

Name               | Type    | Key     | Unique | Default
---------------------------------------------------------
first\_name        | string  |         |        |
last\_name         | string  |         |        |
address\_line\_one | string  |         |        |
address\_line\_two | string  |         |        |
latitude           | float   |         |        |
longitude          | float   |         |        |
active             | boolean |         |        |
user\_id           | integer | foreign |        |

    rails g model Member first\_name:string last\_name:string address\_line\_one:string address\_line\_two:string latitude:float longitude:float active:boolean user:references
    rails g controller Members

Okay I got it saving members, next steps:
* save their lat long on save (DONE!)
* the gmaps-auto-complete stuff is not being loaded consistently, may need to look into other options (breaking address\_line\_one into state, city, address) (This was an issue with turbolinks not allowing the js to load properly, this is fixed with the jquery.turbrolinks gem)
* display them in a list (ordered by first name, last name, proximity)

*Some queries for displaying members:*
* Member.where(:user\_id => 1)
* Member.near([33.1970366,-96.7052353], 50)
* Member.order(first\_name: :asc).where(:user\_id => 2)
* Member.order("LOWER(first\_name) asc").where(:user\_id => 1)
* apparently these won't be necessary, defining User then taking a @user.members is sufficient to grab the correct members

I am now displaying members on each user profile page with a link to the member profile page. check members controller, views, partials to clean up with crap code that didnt end up working.

To sort members I have a few queries setup in the show action of the members controller. I need to grab client location using html5 geolocation enableHighAccuracy

Then on to logging weight, etc.
