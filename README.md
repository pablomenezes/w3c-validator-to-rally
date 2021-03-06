#  W3C-Validator-to-Rally #

## Installing the gem ##

To install the gem, is just type the following command in your prompt:
```ruby
gem install w3c-validator-to-rally
```                              
## Using the gem ##

To get started with the gem, first you have to require it.

    require ‘w3c-validator-to-rally’

The gem is divided between to classes: W3CValidator and Rally. First you have to use the class W3CValidator for searching an error. Then is just initiate a new instance from class, look at the following example:

    validateW3C = W3CValidatorToRally.W3CValidator.new

Now you need to define the url to be verified, using the URL and the parameter from the function defineURI.

    validateW3C.defineURI(url)

With the URL already defined, you can start the validation. Create a variable to store the returned errors using the command startValidation.

    errors = validateW3C.startValidation

For searching errors, this function uses mechanize(url). The default “agent” used (recommended) is “Windows Mozilla”, already set as default, in case you prefer another “agent”, you can pass the wanted agent as a parameter.

    errors = validateW3C.startValidation(anotherAgent)

All returned errors are inside the variable “errors”, in other words, an errors array.

With those stored errors, now you can connect to Rally to create defects.
To get started with the class Rally, create another variable and initiate it.

    rally = W3CValidatorToRally::Rally.new

With the started class, connect to Rally, with the propriety “connect”, look at the following example.

    rally.connect(“login”,”pass”)

Now is connected, use the propriety createDefects, passing as parameters the array of returned errors and the id of your project on Rally.

    rally.createDefects(“1234567890”,errors)

Wait for the creation of all defects and then check on Rally the created defects.
