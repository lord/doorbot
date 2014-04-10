doorbot
=======

For context, see [the blog post about the whole setup](http://lord.io/blog/2014/unlocking-hacker-school/).

Doorbot is a web server that manages access to Hacker School's door. It connects to a [doorduino](https://github.com/jdotjdot/DoorDuino) to unlock the door when a certain number is texted.

## Installation

You'll need to `bundle install`, and then `foreman start` to start both the Twilio watcher and the web server.

You'll also need to create and run a shell script `set_secrets.sh`, with the following API keys and whatnot.

```sh
export HS_OAUTH_ID=id
export HS_OAUTH_SECRET=secret
export HS_OAUTH_CALLBACK="http://localhost:5000"

export TWILIO_SID=sid
export TWILIO_TOKEN=token
export TWILIO_PHONE_NUMBER="human readable phone number"

export PASSWORD_REGEX="random string"
export PASSWORD_HUMAN="random string"

export HASH_SECRET="random string shared with doorduino"
```

Doorbot is designed to work behind firewalls, which is why it uses Twilio polling instead of callbacks. However, there's no reason you couldn't run it on a Heroku instance or something.