Static Website Example
----------------------

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/8bbd00fdb1e249dcbc28f9047a662299)](https://www.codacy.com/gh/Norbitor/static-website-example/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=Norbitor/static-website-example&amp;utm_campaign=Badge_Grade)

Firstly is was meant to be used with Cloud Academy labs. But in my case it is to demo some GitHub Actions and Terraform magic.

## Continous Integration
Initially, code came with pure JS and some SASS files. To make my life easier, I've decided to create a very minimal Node setup.
Just to install Node-Sass and Minify easily. Then I've added some shell scripts to invoke very simple commands to run Sass
compile, JS minify and remove development files.

Secondly, I've set up GitHub Action for that build, which runs it on ubuntu-latest platform and prepares a production package
of this "app". The result is an artifact zip you can download and use (at least if you have some rights for it).

## Infrastructure setup
Then, I've decided to prepare some infrastructure setup. My choice was AWS with S3 and Cloudfront, and a small piece of
Cloudflare because my domain DNS is there. Everything is controlled by Terraform.

S3 is chosen because this example is purely static website, so I don't need a full-featured web server to host this,
neither build any containers. It is also very cheap option for such a small site as this.

I chose Cloudfront to provide simple CDN for this application and to decrease even more number of READ requests on S3.
To be honest, I could just try to use Cloudflare directly (as I already have it) but I wanted to config it for
demo purpose. We can just pretend that there's no Cloudflare here :-). To be honest, I've configured it to bypass
traffic to AWS.

At the end I thought, that it'd be a great idea to put this into a GH Action too, so I did it. With minor issues, like
I still need to put S3 and Cloudfront IDs into Secrets manually, but time for prepare this demo was limited.

## Deployment
The next step was to add deployments, so I used previously created action for building. This gives me an artifact I can upload to
S3. All is done using ready-to-use solution from Marketplace `reggionick/s3-deploy@v3`. And it works!

Additional steps were to implement some quality and security testing:
- `jakejarvis/lighthouse-action@master` to prepare accessibility report,
- free tier of Codacy for code quality measurement,
- `zaproxy/action-baseline@v0.5.0` for basic OWASP security tests.

## Live
Temporarily this site is live under https://statwebsite.norbitor.net.pl.

License
----------------------
My customizations:

All DevOps code is under CC-BY, so use it whenever you need, but just leave a note about me :-)

Original License:

This static website is based on the Dimension template by [HTML5 UP](https://html5up.net/)

Creative Commons License
All of the site templates I create for [HTML5 UP](https://html5up.net/) are licensed under the Creative Commons Attribution 3.0 License, which means you can:
 - use them for personal stuff,
 - use them for commercial stuff,
 - change them however you like.


... all for free, yo. In exchange, just give HTML5 UP credit for the design and tell your friends about it :)

More info [here](https://html5up.net/license).
