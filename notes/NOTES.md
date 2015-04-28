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

##  Making some Static Page controllers

Generate some controllers

    $ rails g controller StaticPages Home About Faq Partners Pricing Contact

I've brought in views from Sample_App, and the homepage view and css from Compost_Denton. I need to look into pulling in the header and footer views from Compost_Denton as well, and other necessary css.

To make bootstrap javascript available, need to add this bit to app/assets/javascripts/application.js

    //= require bootstrap

