using afIoc
using afBedSheet::ValueEncoder
using afBedSheet::ValueEncoders

** Holds all the meta data required to convert a field on a Fantom object to HTML and back again.
class FormField {
	
	** A link back to the owning 'FormBean' instance.
	FormBean		formBean
	
	** The Fantom field this 'FormField' represents.
	Field			field

	** The 'Str' value that will be rendered in the HTML form. 
	** You may set this value before the form is rendered to set a default value.
	** 
	** If the 'formValue' is 'null' then the field value is used instead and converted by 'valueEncoder'.
	** 
	** This 'formValue' is also set during form validation so any user entered values are re-rendered should the form be re-displayed.   
	Str?			formValue

	** The 'ValueEncoder' used to convert the field value to and from a 'Str'.
	** 
	** If 'null' then a default 'ValueEncoder' based on the field type is chosen from BedSheet's 'ValueEncoders' service. 
	ValueEncoder?	valueEncoder
	
	** The 'InputSkin' used to render the field to HTML.
	**  
	** If 'null' then a default 'InputSkin' is chosen based on the 'type' attribute. 
	InputSkin?		inputSkin
	
	** Setting this to a non-null value also invalidates the form field. 
	Str?			errMsg	{ set { if (it != null) invalid = true; &errMsg = it } }
	
	** Is this form field invalid?
	** 
	** Setting this to 'false' also clears any error message. 
	Bool			invalid { set { if (it == false) errMsg = null; &invalid = it } }



	// ---- Html Options ------------------------------------------------------------------------
	
	** HTML attribute. 
	** The type of input to render.
	** 
	** If 'null' then it defaults to 'text'.
	Str?	type
	
	** The label to display next to the '<input>'.
	**  
	** If 'null' then it defaults to a human readable version of the field name. 
	Str?	label

	** HTML attribute. 
	** The value to render as a 'placeholder' attribute on the '<input>'.
	Str?	placeholder

	** If non-null an extra '<div>' is rendered after the '<input>' to supply a helpful hint.
	** The hint is usually rendered with the 'formBean-hint' CSS class.
	Str?	hint
	
	** HTML attribute. 
	** The value to render as a CSS 'class' attribute on the '<input>'. 
	Str?	css
	
	** HTML attribute. 
	** Any other miscellaneous attributes that should be rendered on the '<input>'. 
	** Example:
	** 
	**   attributes = "autocomplete='off'"
	Str?	attributes
	
	
	
	// ---- Validation Options ------------------------------------------------------------------------
	
	** HTML5 validation attribute.
	** Set to 'true' to mark the input as required.
	** If 'null' (the default) then the input is required if the field is non-nullable.
	Bool?	required

	** HTML5 validation attribute.
	** Sets the minimum length (inclusive) a string should be. 
	Int?	minLength
	
	** HTML5 validation attribute.
	** Sets the maximum length (inclusive) a string should be.
	** 
	** If 'null' then (for text types) it defaults to the config value `FormBeanConfigIds.defaultMaxLength`. 
	Int?	maxLength

	** HTML5 validation attribute.
	** Sets the minimum value (inclusive) an 'Int' should have.
	Int?	min
	
	** HTML5 validation attribute.
	** Sets the maximum value (inclusive) an 'Int' should have.
	Int?	max
	
	** HTML5 validation attribute.
	** Sets a regular expression that the (stringified) value should match.
	** Starting '^' and ending '$' characters are implicit and not required.
	Regex?	pattern 
	
	** HTML5 validation attribute.
	** Defines the interval for a numeric input.
	Int?	step

	
	
	// ---- Select Options ------------------------------------------------------------------------
	
	** Used by the '<select>' renderer. 
	** Set to 'true' to show a blank value at the start of the options list.
	** 
	** leave as null to use 'OptionsProvider.showBlank' value.
	Bool?	showBlank
	
	** Used by the '<select>' renderer. 
	** This is the label to display in the blank option.
	** 
	** leave as null to use 'OptionsProvider.blankLabel' value.
	Str?	blankLabel
		
	** Used by the '<select>' renderer. 
	** The 'OptionsProvider' used to supply option values when rendering '<select>' tags.
	**  
	** If 'null' then a default 'OptionsProvider' is chosen based on the field type. 
	OptionsProvider?	optionsProvider
	

	@Inject private const	InputSkins		_inputSkins
	@Inject private const	ValueEncoders 	_valueEncoders
	
	@NoDoc // Boring!
	new make(|This| in) { in(this) }
	
	** Hook to render this field to HTML.
	** By default this defers rendering to an 'InputSkin'.
	** 
	** Override to perform custom field rendering.
	virtual Str render(Obj? bean) {
		skinCtx := SkinCtx() {
			it.bean				= bean
			it.field			= this.field
			it.formBean			= this.formBean
			it.formField		= this
			it._valueEncoders	= this._valueEncoders
		}
		
		inputSkin := inputSkin ?: _inputSkins.find(type ?: "text")
		return inputSkin.render(skinCtx)		
	}
	
	** Hook to validate form field.
	** By default this performs the basic HTML5 validation.
	** 
	** Override to perform custom field validation.
	** Use the given 'addErr' func to report errors; note that 'constraint' is optional.   
	virtual Void validate(|FormField formField, Str type, Obj? constraint| addErr) {
		hasValue := formValue != null && !formValue.isEmpty

		if (required ?: false)
			if (formValue == null || formValue.isEmpty)
				return addErr(this, "required", Str.defVal)
		
		if (hasValue && minLength != null)
			if (formValue.size < minLength)
				return addErr(this, "minLength", minLength)

		if (hasValue && maxLength != null)
			if (formValue.size > maxLength)
				return addErr(this, "maxLength", maxLength)

		if (hasValue && min != null) {
			if (formValue.toInt(10, false) == null)
				return addErr(this, "notNum", Str.defVal)
			if (formValue.toInt < min)
				return addErr(this, "min", min)
		}

		if (hasValue && max != null) {
			if (formValue.toInt(10, false) == null)
				return addErr(this, "notNum", Str.defVal)
			if (formValue.toInt > max)
				return addErr(this, "max", max)
		}

		if (hasValue && pattern != null)
			if (!"^${pattern}\$".toRegex.matches(formValue))
				return addErr(this, "pattern", pattern)			
	}
}
