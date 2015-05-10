using afBedSheet

** Holds all the meta data required to convert a field on a Fantom object to HTML and back again.
class FormField {
	// TODO: have this hold services and push all the render / validate methods down on to this - make it more OO.
	
	** The Fantom field this 'FormField' represents.
	Field				field

	** The 'Str' value that will be rendered in the HTML form. 
	** You may set this value before the form is rendered to set a default value.
	** 
	** If the 'formValue' is 'null' then the field value is used instead and converted by 'valueEncoder'.
	** 
	** This 'formValue' is also set during form validation so any user entered values are re-rendered should the form be re-displayed.   
	Str?				formValue

	** The 'ValueEncoder' used to convert the field value to and from a 'Str'.
	** 
	** If 'null' then a default 'ValueEncoder' based on the field type is chosen from BedSheet's 'ValueEncoders' service. 
	ValueEncoder?		valueEncoder
	
	** The 'InputSkin' used to render the field to HTML.
	**  
	** If 'null' then a default 'InputSkin' is chosen based on the '@HtmlInput.type' attribute. 
	InputSkin?			inputSkin
	
	** The 'OptionsProvider' used to supply option values when rendering '<select>' tags.
	**  
	** If 'null' then a default 'OptionsProvider' is chosen based on the field type. 
	OptionsProvider?	optionsProvider
	
	** Setting this to a non-null value also invalidates the form field. 
	Str?				errMsg	{ set { if (it != null) invalid = true; &errMsg = it } }
	
	** Is this form field invalid?
	** 
	** Setting this to 'false' also clears any error message. 
	Bool				invalid { set { if (it == false) errMsg = null; &invalid = it } }

	@NoDoc // Boring!
	new make(|This| in) { in(this) }
	
	** Returns the '@HtmlInput' from the Fantom field. 
	HtmlInput input() {
		Slot#.method("facet").callOn(field, [HtmlInput#])	// Stoopid F4
	}
}
