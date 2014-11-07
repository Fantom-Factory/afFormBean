## Overview 

*FormBean is a support library that aids Alien-Factory in the development of other libraries, frameworks and applications. Though you are welcome to use it, you may find features are missing and the documentation incomplete.*

`FormBean` renders and validates HTML forms from Fantom objects in a highly customisable manner.

`FormBean` allows Fantom objects to be rendered as HTML forms, to be validated on the client and the server, and

uses Ioc and BedSheet

Features:

- Renders Fantom objects as editable HTML forms.
- HTML5 client and server side validation.
- Customised Select options.
- Customised error messages.
- Customise HTML inputs.
- Entities autobuilt with IoC.

Current limitations:

- Maps, Lists and nested objects are not supported.
- XHTML not supported. (Use HTML Parser to test.)
- Radioboxes are not supported.

// crazy formatting: http://webdesign.tutsplus.com/tutorials/bring-your-forms-up-to-date-with-css3-and-html5-validation--webdesign-4738

## Install 

Install `FormBean` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afFormBean

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afFormBean 0.0"]

## Documentation 

Full API & fandocs are available on the [Status302 repository](http://repo.status302.com/doc/afFormBean/).

## Quick Start 

1). Create a text file called `Example.fan`

```
using afIoc
using afBedSheet
using afEfanXtra
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
        if (!formBean.validateBean(httpRequest.form))
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
@SubModule { modules=[EfanXtraModule#, FormBeanModule#] }
class AppModule {
    @Contribute { serviceType=Routes# }
    static Void contributeRoutes(Configuration conf) {
        conf.add(Route(`/`, ContactUsPage#render))
        conf.add(Route(`/contact`, ContactUsPage#onContact, "POST"))
        
        // to save you typing in a stylesheet, we'll just redirect to one I made earlier
        // conf.add(Route(`/styles.css`, `styles.css`.toFile))
        conf.add(Route(`/styles.css`, Redirect.movedTemporarily(`http://static.alienfactory.co.uk/fantom-docs/afFormBean-quickStart.css`)))
    }
}

class Main {
    Int main() {
        afBedSheet::Main().main([AppModule#.qname, "8069"])
    }
}
```

2). Run `Example.fan` as a Fantom script from the command prompt:

```
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
```

3). Point your web browser to `http://localhost:8069/` and you'll see a basic HTML contact form:

![Screenshot of the afFormBean Quick Start example](http://static.alienfactory.co.uk/fantom-docs/afFormBean-quickStart.png)

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

HTML forms are the backbone of data entry in any web application. It is common practice to model client side HTML forms as objects on the server, with fields on the object representing inputs on the form. We call such objects *form beans*. The [FormBean](http://repo.status302.com/doc/afFormBean/FormBean.html) class then does the necessary hard work of converting form beans to HTML and back again.

`FormBeans` should be autobuilt by IoC, passing in the type of object it should model.

    formBean := (FormBean) registry.autobuild(FormBean#, [MyFormModel#]) 

Or, as in the quick start example, you can `@Inject` a `FormBean` instance as a field using the `type` facet attribute:

    @Inject { type=MyFormModel# } 
    FormBean formBean

When created, a `FormBean` inspects the given type looking for fields annotated with [@HtmlInput](http://repo.status302.com/doc/afFormBean/HtmlInput.html). For each field found it creates a [FormField](http://repo.status302.com/doc/afFormBean/FormField.html) instance. `FormFields` hold all the information required to render the field as HTML, and back again.

To render the HTML form, just call `FormBean.renderBean(...)`. To pre-populate the HTML form with existing data, pass in a form bean instance and its field values will be rendered as the HTML `<input>` values.

Note that the `<form>` tag itself is not rendered, giving you more control over form submission and HTML generation.

The standard template to render a HTML input looks like:

    <div class='formBean-row inputRow #NAME [ERROR]'>
        <label for="#NAME">#LABEL</label>
        <input type='submit' id='#NAME' name="#NAME" ... >
        <div class="formBean-hint">#HINT</div>
    </div>

(Note that the hint `div` is only rendered if hint is non-null.) See [Input Skins](http://repo.status302.com/doc/afFormBean/#skins.html) if you wish to render your own bespoke HTML.

When the HTML form is submitted to the server, use `FormBean.createBean()` to convert the submitted form values into a form bean instance.

Sometimes you don't always want to create a fresh form bean instance. For instance, your beans may be entities in a database and only some of the fields may be editable. In that case, upon form submission, retrieve a bean instance from the database and call `FormBean.updateBean()` to do just that.

### ValueEncoders 

Representing values as strings (to be rendered as HTML) is not always as obvious as calling `.toStr()`. For instance, what about printing and formatting dates? On form submission, if a user leaves an input blank, should that be converted to `null` or an empty string?

Because there is no right answer for all occasions, FormBean leverages BedSheet's `ValueEncoders` service to convert different types to and from `Str` objects.

A `ValueEncoder` is initially selected based on the type of the form field. This may be overridden by specifying the `ValueEncoder` type on the `@HtmlInput`. (Instances are created and cached by IoC.)

    @HtmlInput { valueEncoder=MyValueEncoder# }
    public MyValue? myValue 

Or you can set an instance directly on the `FormField` itself.

    formBean.formFields[MyFormModel#field1].valueEncoder = MyValueEncoder() 

### Validation 

HTML Form validation is boring and tedious at best.

Yes, there are hundreds of javascript form validation frameworks out there, but not one is appropriate for everyone in all situations. They're a pain to configure, awkward to tweak and don't go anywhere near the fact that validation has to be replicated on the server to double check actual values submitted.

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

To view the server side error messages (for styling) you may wish to switch off client side validation. Fortunately HTML5 gives us an easy way to do this, just add the `novalidate` attribute to the form:

    <form action='/contact' method='POST' novalidate>
        ...
    </form>

### Messages 

Labels, placeholders, hints and validation messages are all customisable.

messages looked for in pod, filename

add dir to res!

form field

@htmlinput facet formbean.msgs properites file defauly toDisplayName

### Skins 

Default skin renders the following:

    <div class='formBean-row submitRow'>
      <input type='submit' name='formBeanSubmit' class='submit' value='label'>
    </div>

### Select Boxes

