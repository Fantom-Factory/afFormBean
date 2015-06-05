#FormBean v0.0.4
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v0.0.4](http://img.shields.io/badge/pod-v0.0.4-yellow.svg)](http://www.fantomfactory.org/pods/afFormBean)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

## Overview

*FormBean is a support library that aids Alien-Factory in the development of other libraries, frameworks and applications. Though you are welcome to use it, you may find features are missing and the documentation incomplete.*

FormBean is a means to render Fantom objects as HTML forms, validate submitted values, and reconstitute them back into Fantom objects. Built on top of [IoC](http://pods.fantomfactory.org/pods/afIoc) and [BedSheet](http://pods.fantomfactory.org/pods/afBedSheet) FormBean allows you to customise every aspect of your HTML form generation.

Features:

- Renders Fantom objects as HTML forms.
- HTML5 client and server side validation
- Uses BedSheet `ValueEncoders` for string conversion
- Customise HTML generation with skins
- Versatile means of generating select options
- Customised error messages

Current limitations:

- Maps, Lists and nested objects are not supported.
- Radioboxes are not natively supported.

## Install

Install `FormBean` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afFormBean

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afFormBean 0.0"]

## Documentation

Full API & fandocs are available on the [Fantom Pod Repository](http://pods.fantomfactory.org/pods/afFormBean/).

## Quick Start

1. Create a text file called `Example.fan`

        using afIoc
        using afBedSheet
        using afFormBean
        
        class ContactUsPage  {
            @Inject
            HttpRequest httpRequest
        
            @Inject { type=ContactDetails# }
            FormBean formBean
        
            new make(|This|in) { in(this) }
        
            Text render() {
                Text.fromHtml(
                    "<!DOCTYPE html>
                     <html>
                     <head>
                         <title>FormBean Demo</title>
                         <link rel='stylesheet' href='/styles.css' >
                     </head>
                     <body>
                         <h2>Contact Us</h2>
                         <span class='requiredNotification'>* Denotes Required Field</span>
        
                         <form class='contactForm' action='/contact' method='POST'>
                             ${ formBean.renderErrors()   }
                             ${ formBean.renderBean(null) }
                             ${ formBean.renderSubmit()   }
                         </form>
                     </body>
                     </html>")
            }
        
            Text onContact() {
                // perform server side validation
                // if invalid, re-render the page and show the errors
                if (!formBean.validateForm(httpRequest.form))
                    return render
        
                // create an instance of our form object
                contactDetails := (ContactDetails) formBean.createBean
        
                echo("Contact made!")
                echo(" - name:    ${contactDetails.name}")
                echo(" - email:   ${contactDetails.email}")
                echo(" - website: ${contactDetails.website}")
                echo(" - message: ${contactDetails.message}")
        
                // display a simple message
                return Text.fromPlain("Thank you ${contactDetails.name}, we'll be in touch.")
            }
        }
        
        class ContactDetails {
            @HtmlInput { required=true; attributes="placeholder='Fred Bloggs'" }
            Str name
        
            @HtmlInput { type="email"; required=true; placeholder="fred.bloggs@example.com"; hint="Proper format 'name@something.com'" }
            Uri email
        
            @HtmlInput { type="url"; required=true; placeholder="http://www.example.com"; hint="Proper format 'http://someaddress.com'" }
            Str website
        
            @HtmlInput { type="textarea"; required=true; attributes="rows='6'"}
            Str message
        
            new make(|This|in) { in(this) }
        }
        
        // @SubModule only needed because this example is run as a script
        @SubModule { modules=[FormBeanModule#] }
        class AppModule {
            @Contribute { serviceType=Routes# }
            static Void contributeRoutes(Configuration conf) {
                conf.add(Route(`/`, ContactUsPage#render))
                conf.add(Route(`/contact`, ContactUsPage#onContact, "POST"))
        
                // to save you typing in a stylesheet, we'll just redirect to one I made earlier
                // conf.add(Route(`/styles.css`, `styles.css`.toFile))
                conf.add(Route(`/styles.css`, Redirect.movedTemporarily(`http://pods.fantomfactory.org/pods/afFormBean/doc/quickStart.css`)))
            }
        }
        
        class Main {
            Int main() {
                afBedSheet::Main().main([AppModule#.qname, "8069"])
            }
        }


2. Run `Example.fan` as a Fantom script from the command prompt:

        C:\> fan Example.fan
        
        [info] [afBedSheet] Starting Bed App 'Example_0::AppModule' on port 8069
        [info] [web] WispService started on port 8069
        [info] [afBedSheet] Found mod 'Example_0::AppModule'
        [info] [afIoc] Adding module definitions from pod 'Example_0'
        [info] [afIoc] Adding module definition for Example_0::AppModule
        [info] [afIoc] Adding module definition for afBedSheet::BedSheetModule
        [info] [afIoc] Adding module definition for afIocConfig::ConfigModule
        [info] [afIoc] Adding module definition for afIocEnv::IocEnvModule
        [info] [afIoc]
           ___    __                 _____        _
          / _ |  / /_____  _____    / ___/__  ___/ /_________  __ __
         / _  | / // / -_|/ _  /===/ __// _ \/ _/ __/ _  / __|/ // /
        /_/ |_|/_//_/\__|/_//_/   /_/   \_,_/__/\__/____/_/   \_, /
                       How do I set a laser pointer to stun? /___/
        
        IoC Registry built in 323ms and started up in 39ms
        
        Bed App 'Unknown' listening on http://localhost:8069/


3. Point your web browser to `http://localhost:8069/` and you'll see a basic HTML contact form:

  ![Screenshot of the afFormBean Quick Start example](http://pods.fantomfactory.org/pods/afFormBean/doc/quickStart.png)



*(Note the pretty styling was lifted from [Bring Your Forms Up to Date With CSS3 and HTML5 Validation](http://webdesign.tutsplus.com/tutorials/bring-your-forms-up-to-date-with-css3-and-html5-validation--webdesign-4738) )*

On submitting the HTML form, the form values are validated server side and reconstituted into an instance of `ContactDetails`. The bean is then echo'ed to standard out and a short reply message sent back to the browser.

```
Contact made!
 - name:    Fred Bloggs
 - email:   fred.bloggs@example.com
 - website: http://www.example.com
 - message: Hello Mum!
```

## Usage

### To and From HTML Forms

HTML forms are the backbone of data entry in any web application. It is common practice to model client side HTML forms as objects on the server, with fields on the object representing inputs on the form. We call such objects *form beans*. The [FormBean](http://pods.fantomfactory.org/pods/afFormBean/api/FormBean) class then does the necessary hard work of converting form beans to HTML and back again.

`FormBeans` should be autobuilt by IoC, passing in the type of object it should model.

    formBean := (FormBean) registry.autobuild(FormBean#, [MyFormModel#])

Or, as in the quick start example, you can `@Inject` a `FormBean` instance as a field using the `type` facet attribute:

    @Inject { type=MyFormModel# }
    FormBean formBean

When created, a `FormBean` inspects the given type looking for fields annotated with [@HtmlInput](http://pods.fantomfactory.org/pods/afFormBean/api/HtmlInput). For each field found it creates a [FormField](http://pods.fantomfactory.org/pods/afFormBean/api/FormField) instance. `FormFields` hold all the information required to render the field as HTML, and convert it back again.

To render the HTML form, just call `FormBean.renderBean(...)`. To pre-populate the HTML form with existing data, pass in a form bean instance and its field values will be rendered as the HTML `<input>` values.

Note that the `<form>` tag itself is not rendered, giving you more control over form submission and HTML generation.

The standard template to render a HTML input looks like:

    <div class='formBean-row inputRow #NAME [ERROR]'>
        <label for="#NAME">#LABEL</label>
        <input type='submit' id='#NAME' name="#NAME" ... >
        <div class="formBean-hint">#HINT</div>
    </div>

(Note that the hint `div` is only rendered if hint is non-null.) See [Input Skins](#skins) if you wish to render your own bespoke HTML.

When the HTML form is submitted to the server, use `FormBean.createBean()` to convert the submitted form values into a form bean instance.

Sometimes you don't always want to create a fresh form bean instance. For instance, your beans may be entities in a database and only some of the fields may be editable. In that case, upon form submission, retrieve a bean instance from the database and call `FormBean.updateBean()` to do just that.

### ValueEncoders

Representing values as strings (to be rendered as HTML) is not always as obvious as calling `toStr()`. For instance, what about printing and formatting dates? On form submission, if a user leaves an input blank, should that be converted to `null` or an empty string?

Because there is no right answer for all occasions, FormBean leverages BedSheet's `ValueEncoders` service to convert different types to and from `Str` objects.

A `ValueEncoder` is initially selected based on the type of the form field. This may be overridden by specifying the `ValueEncoder` type on the `@HtmlInput`. (Instances are created and cached by IoC.)

    @HtmlInput { valueEncoder=MyValueEncoder# }
    public MyValue? myValue

Or you can set an instance directly on the `FormField` itself.

    formBean.formFields[MyFormModel#field1].valueEncoder = MyValueEncoder()

Note, FormBean provides a `ValueEncoder` for `Bool` to get around HTML's dodgy `on` / not submitted syntax.

### Validation

HTML Form validation is boring and tedious at best.

Yes, there are hundreds of javascript form validation frameworks out there, but not one is appropriate for everyone in all situations. They're generally a pain to configure, awkward to tweak and don't go anywhere near the fact that validation has to be replicated on the server to double check actual values submitted.

Because life is too short, Alien-Factory takes a no-nonsense approach to HTML form validation and gladly hands it over to the browser. HTML5 form validation is the way of the future.

The `@HtmlInput` facet attributes `required`, `minLength`, `maxLength`, `min`, `max`, `regex`, and `step` map directly HTML5 input attributes and are rendered as such. As far as client side validation goes, this is all FormBean does. It is barebones but browser support for HTML5 validation is getting better every day.

You can, of course, embed and utilise any javascript form validation framework you wish! Using FormBean does not preclude you from using other validation frameworks.

Now, because hackers and testers alike constantly try to break your application, you can not assume that everyone is using a HTML5 enabled browser. That means any old junk may be submitted to the server and you have to guard against this.

Thankfully, FormBean performs some server side validation of its own. Calling `FormBean.validateForm(...)` will perform the same basic HTML5 validation as the browser. Any error messages generated are saved directly on the `FormField` instances.

Calling `FormBean.renderErrors()` will render the errors in a HTML list. The rendering template looks like:

    <div class='formBean-errors'>
        <div class='formBean-banner'>#BANNER</div>
        <ul>
            <li> Error 1 </li>
            <li> Error 2 </li>
        </ul>
    </div>

When rendering a form bean, any fields in error will have the `error` class set on the `inputRow` div.

While listing the errors together in one place may seem old skool (as oppose to displaying the error with the field in question) it does help with gaining a AAA accessibility rating.

To view the server side error messages (for styling) you may wish to switch off client side validation. Fortunately HTML5 gives us an easy way to do this, just add the `novalidate` attribute to the form:

    <form action='/contact' method='POST' novalidate>
        ...
    </form>

### Messages

Labels, placeholders, hints and validation messages are all customisable through messages. Messages boil down to a simple key / value map of strings on `FormBean`.

You may add to this map manually:

    formBean.messages["field.firstName.label"] = "Christian Name:"

Or you may use property files, which is usually easier. FormBean will look in your pod for a property file named after your form bean. Example, if your form bean is called `MyFormModel` then you would create a pod file called `MyFormModel.properies`. In there, you list all the messages specific to that bean.

The advantage of a property file is that it succinctly groups all the messages for a specific bean together in one easily recognisable place.

Note that the properties file may lie anywhere but *must* be declared in a resource directory in the project's `build.fan`.

    resDirs = [`fan/entities/MyFormModel.properies`]

or

    resDirs = [`fan/entities/`]

#### Field Messages

Labels, placeholders and hints all have dedicated attributes on the `@HtmlInput` facet. If these are `null` then the messages map is consulted with the keys:

    field.#NAME.label
    field.#NAME.placeholder
    field.#NAME.hint

where `#NAME` is the name of the field. If label value can not be found then it defaults to `field.name.toDisplayName()`.

#### Validation Messages

Validation messages are looked up with the key:

    field.#NAME.#VALIDATION

where `#NAME` is the name of the field and `#VALIDATION` is the validation type / attribute name. Example:

    field.age.min = "Sorry, but you're not old enough for this ride!"

All occurrences of the strings `${label}`, `${constraint}`, and `${value}` are replaced with appropriate values.

    field.age.min = "Sorry kid, you need to be at least ${constraint} for this ride!"

If a field specific message is not found then the key `field.#VALIDATION` is looked up.

#### Defaults

The default FormBean messages are:

    errors.banner       = There were problems with the form data:
    
    field.required      = ${label} is required
    field.minLength     = ${label} should be at least ${constraint} characters
    field.maxLength     = ${label} should be at most ${constraint} characters
    field.notNum        = ${label} should be a whole number
    field.min           = ${label} should be at least ${constraint}
    field.max           = ${label} should be at most ${constraint}
    field.regex         = ${label} does not match the pattern ${constraint}
    
    field.submit.label  = Submit

### Skins

Because the default HTML template is not suitable for every purpose, you can substitute your own skins for rendering HTML. Just implement [InputSkin](http://pods.fantomfactory.org/pods/afFormBean/api/InputSkin).

Skins may be set on the `FormField` directly for a specific field:

    formBean.formFields[MyFormModel#field1].inputSkin = MySkin()

Or they may be contributed to the `InputSkins` service where they are used by default for that specific type:

    @Contribute { serviceType=InputSkins# }
    static Void contributeInputSkins(Configuration config) {
        config["custom"] = MySkin()
    }
    
    // then on your form bean field:
    @HtmlInput { type="custom" }
    Str myValue

Skins make it easy to render custom markup for date pickers.

> **TIP:** Use [Duvet](http://pods.fantomfactory.org/pods/afDuvet) in your skins to inject field specific javascript.

For dates, I personally like to use [Bootstrap Datepicker](http://bootstrap-datepicker.readthedocs.org/en/release/index.html) - see the [DatePicker for FormBean](http://www.fantomfactory.org/articles/datepicker-for-formbean) article for details.

### Select Boxes

HTML `<select>` elements are notoriously difficult to render. Not only do you have the hassle of rendering and value encoding the field itself, but you have to do it all over again for all the `<option>` tags too! And these options aren't just hardcoded, they're often user specific and / or returned from a database query.

FormBean's default skin for `select` uses [OptionsProviders](http://pods.fantomfactory.org/pods/afFormBean/api/OptionsProvider) to provide the options to be rendered. Like `InputSkins` an `OptionsProvider` may be set on the `FormField` directly for a specific field:

    formBean.formFields[MyFormModel#field1].optionsProvider = MyOptions()

Or they may be contributed to the `OptionsProviders` service where they are used by default for that specific field type:

    @Contribute { serviceType=OptionsProviders# }
    static Void contributeOptionsProviders(Configuration config) {
        config[MyValue#] = MyOptions()
    }
    
    // then on your form bean field:
    @HtmlInput
    MyValue myValue

The method `OptionsProvider.options()` returns a map of option values. The values are converted to strings via the usual `ValueEncoder` service in the same way as the select value. The keys of the map are used as message keys in the format:

    option.#KEY.label

If not found then the key itself is used as the option label.

Note that a default `OptionsProvider` is already given for `Enums`. So to render a Enum field as a select element with custom display labels:

    enum class Colours {
        red, blue
    }
    
    // then on your form bean field:
    @HtmlInput { type="select" }
    Colours colour
    
    // then in your bean.properties:
    option.red.label  = Roses are red
    option.blue.label = Violets are blue

