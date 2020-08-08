![Perlmutter App](https://raw.githubusercontent.com/mdodell/PerlmutterSummer2020/staging/app/assets/images/perlmutterapp.gif)
# Perlmutter App
An application developed to help not for profits maintain communication with constituents in the post-pandemic environment.

Organizations can send events, information, and messages as admins to users via call, text, email, or in-app newsletter, whichever contact method(s) each constituent has access to or would want to use.

Organizations can download this repository and run the organization initializer to configure their app and deploy a customized app for their organization's needs.

Our initial client in developing the app is [The Haven Project](https://havenproject.net/), an impactful organization started to address a gap in services to unaccompanied homeless young adults and surrounding communities. They provide direct service to more than 200 homeless unaccompanied youth ages 17-24 each year in their Drop-in Centers, with referrals to other youth serving organizations for hundreds more who don’t meet intake criteria.

## Hosting Services/Costs
The Perlmutter App relies on a few services to function, which may incur costs. It is hosted on [Heroku](https://www.heroku.com/) and it uses [Twilio](https://www.twilio.com/) to provision and automate a phone number to call/text users from.

Heroku is free by default, but can upgrade your app's performance with increased tiers.

Twilio costs, [according to their pricing in August 2020](https://www.twilio.com/pricing), $1.00/month for the phone number powering the app, $0.0085/min to receive and $0.013/min to make calls, and $0.0075 to receive and make texts.

These services are all provisioned via the initializer with your user input, to help simplify the process for you!

## Initialization
Installation/run instructions:
1) Install [Git](https://www.atlassian.com/git/tutorials/install-git) (use the page's navigation to pick your operating system)
2) Install [Ruby](https://rails.devcamp.com/trails/ruby-programming/campsites/introduction-to-the-ruby-programming-lanuage/guides/how-to-install-ruby-on-a-computer)
3) Download or clone this repository
4) In the project folder, run the following commands
   * `gem update --system`
   * `bundle install`
   * `ruby org_init.rb` 
   
Organization initializer instructions (required steps in bold, all credentials requested will be prompted to create new/sign up for if you don't have):
1) **Provide your organization's name & description**
2) Provide your organization's colors
3) Provide your organization's logo or use one of our presets
4) **Provide your organization's email credentials to power the app's email capabilities**
5) **Provide your Twilio credentials to power the app's phone capabilities**
6) Create an FAQ for your organization
7) Create a score form for your organization
8) **Provide details to set your organization's admin user login for the app**
9) **Provide your Heroku credentials to deploy the app**

## Development
Want to develop the Perlmutter App?
1) Install [Git](https://www.atlassian.com/git/tutorials/install-git) (use the page's navigation to pick your operating system)
2) Download or clone this repository
3) Install [Ruby on Rails](https://gorails.com/setup/osx) (use the page's navigation to pick your operating system)
4) In the project folder, run the following commands
   * `gem update --system`
   * `bundle install`
   * `yarn install --check-files`
   * `rake webpacker:compile`
   * `rake db:create`
   * `rake db:migrate`
5) If running in development, install ngrok ([Link here](https://ngrok.com/download), or `brew cask install ngrok` on OSX with Homebrew) for receiving calls/texts when running on your local environment

## Team
### Developers
[Mitchell Dodell](https://github.com/mdodell)

[Adam Fleishaker](https://github.com/afleishaker)

### Project Manager
[Daniel Khudyak](https://www.linkedin.com/in/daniel-khudyak/)

### Advisors
[Prof. Gene Miller](https://www.brandeis.edu/facultyguide/person.html?emplid=a17250782cc27b6ced397bc3c9310b5f32e03d34)

[Prof. Ian Roy](https://www.brandeis.edu/facultyguide/person.html?emplid=e1b21496896ddff81d7249e1bc6d95387a2c72e5)

### Special Thanks
[Louis and Barbara Perlmutter](https://www.brandeis.edu/global/about/centers/perlmutter/index.html)

[Beth Marshdoyle](https://www.linkedin.com/in/bethmarshdoyle)

[The Haven Project](https://havenproject.net/)

[Twemoji](https://twemoji.twitter.com/)

## Workflow
To better understand our workflow and progression, please install the Zenhub extension and look at our Zenhub project board for this repository.
