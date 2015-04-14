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

## Rails Controllers

The controllers I think I want to use:

* **account_activation**: handles activating accounts
* **application**: a base level controller available to all other controllers
* **password_reset**: handles password resets
* **users**: user CRUD, data grabbing
* **session**: creating and destroying sessions

I am a little confused on best practices for what goes in a controller vs what goes in a model. I plan to follow Michael Hartl's sample twitter apps lead on some of these decisions.

## Getting Started

    rails _4.2.0_ new compost_denton
    cd compost_denton
    git init
    git commit -am 'initialize repo'
    git remote add origin https://github.com/andrewjm/compost_denton.git
    git push -u origin master

