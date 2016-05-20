using afIoc
using afBedSheet
using afFormBean
using afDuvet

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
                 <link rel='stylesheet' href='/styles.css'>
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
        if (!formBean.validateForm(httpRequest.body.form))
            return render

        // create an instance of our form object
        contactDetails := (ContactDetails) formBean.createBean

        echo("Contact made!")
        echo(" - name:    ${contactDetails.name}")
        echo(" - email:   ${contactDetails.email}")
        echo(" - website: ${contactDetails.website}")
        echo(" - dob:     ${contactDetails.dob}")
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

    @HtmlInput { type="date" }
    Date dob

    @HtmlInput { type="textarea"; required=true; attributes="rows='6'"}
    Str message

    new make(|This|in) { in(this) }
}

// @SubModule only needed because this example is run as a script
@SubModule { modules=[FormBeanModule#, DuvetModule#] }
const class AppModule {
    @Contribute { serviceType=Routes# }
    static Void contributeRoutes(Configuration conf) {
        conf.add(Route(`/`, ContactUsPage#render))
        conf.add(Route(`/contact`, ContactUsPage#onContact, "POST"))

        // to save you typing in a stylesheet, we'll just redirect to one I made earlier
        // conf.add(Route(`/styles.css`, `styles.css`.toFile))
        conf.add(Route(`/styles.css`, Redirect.movedTemporarily(`http://static.alienfactory.co.uk/fantom-docs/afFormBean-quickStart.css`)))
    }

    @Contribute { serviceType=ScriptModules# }
    static Void contributeScriptModules(Configuration config) {
        jQuery := ScriptModule("jquery")
            .atUrl(`//code.jquery.com/jquery-1.11.1.min.js`)

        picker := ScriptModule("datepicker")
            .atUrl(`https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.6.1/js/bootstrap-datepicker.min.js`)
            .requires("jquery")

        config.add(jQuery)
        config.add(picker)
    }

    @Contribute { serviceType=InputSkins# }
    static Void contributeInputSkins(Configuration config) {
        config.overrideValue("date", config.build(DateSkin#))
    }

    @Contribute { serviceType=ValueEncoders# }
    static Void contributeValueEncoders(Configuration config) {
        config[Date#] = config.build(DateValueEncoder#)
    }
}

const class DateSkin : DefaultInputSkin {
    @Inject private const HtmlInjector injector

    new make(|This| in) { in(this) }

    override Str renderElement(SkinCtx skinCtx) {
        // Datepicker needs some default Bootstrap styles
        injector.injectStylesheet.fromExternalUrl(`https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.2/css/bootstrap.min.css`)
        // Note you should host the datepicker CSS yourself
        injector.injectStylesheet.fromExternalUrl(`https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.6.1/css/bootstrap-datepicker.min.css`)

        injector.injectRequireScript(
            ["datepicker":"datepicker", "jquery":"\$"],
            "\$('#${skinCtx.name}').datepicker({format:'d M yyyy', autoclose: true });"
        )

        return "<input class='date form-control' type='text' ${skinCtx.renderAttributes} value='${skinCtx.value}'>"
    }
}

const class DateValueEncoder : ValueEncoder {
    const Str datePattern := "D MMM YYYY"

    override Str toClient(Obj? value) {
        if (value == null) return Str.defVal
        return ((Date) value).toLocale(datePattern)
    }

    override Obj? toValue(Str clientValue) {
        if (clientValue.isEmpty) return null
        return Date.fromLocale(clientValue, datePattern)
    }
}

class Main {
    static Void main() {
    	BedSheetBuilder(AppModule#).startWisp(8069)
    }
}
