# README #

Requirements:

* CentOS7 Box.
* Salt-Minion installed.

### What is this repository for? ###

* This will host our jenkins formula for Salt.

### How do I get set up? ###

* Build a CentOS7 box, either on OpenStack or manually.
* Connect it to a salt master.
* Configure your /srv/pillar/wildcard.sls with our wildcard certificate / key in the following format;

`wildcard_key: |

-----BEGIN RSA PRIVATE KEY-----

{KEY}

-----END RSA PRIVATE KEY-----

wildcard_cert: |


-----BEGIN CERTIFICATE-----

{CERT}

-----END CERTIFICATE-----`

### Who do I talk to? ###

* Craig Simpson +44-2920020386 x386
* craig.simpson@thevoicefactory.co.uk
