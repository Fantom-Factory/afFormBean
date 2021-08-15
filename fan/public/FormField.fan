using afIoc::Inject
using afIoc::Scope

** Holds all the meta data required to convert a field on a Fantom object to HTML and back again.
class FormField {
	
	** A link back to the owning 'FormBean' instance.
	FormBean	formBean
	
	** The Fantom field this 'FormField' represents.
	Field		field

	** The 'Str' value that will be rendered in the HTML form. 
	** You may set this value before the form is rendered to set a default value.
	** 
	** If the 'formValue' is 'null' then the field value is used instead and converted by 'valueEncoder'.
	** 
	** This 'formValue' is also set during form validation so any user entered values are re-rendered should the form be re-displayed.   
	Str?		formValue

	** Used as temporary store when uploading binary data, such as 'Bufs' and 'Files'. 
	** Contains the value that the form field will be set to.
	Obj?		formData
	
	** The 'afBedSheet::ValueEncoder' used to convert the field value to and from a 'Str'.
	** 
	** If 'null' then a default 'ValueEncoder' based on the field type is chosen from BedSheet's 'ValueEncoders' service. 
	Obj?		valueEncoder
	
	** The 'InputSkin' used to render the field to HTML.
	**  
	** If 'null' then a default 'InputSkin' is chosen based on the 'type' attribute. 
	InputSkin?	inputSkin
	
	** The error message associated with this field.
	** 
	** Setting this to a non-null value invalidate the form field. 
	Str?		errMsg	{ set { if (it != null) invalid = true; &errMsg = it } }
	
	** Is this form field invalid?
	** 
	** Setting this to 'false' also clears any 'errMsg'. 
	Bool		invalid { set { if (it == false) errMsg = null; &invalid = it } }

	** If 'true' then the field is rendered into the HTML form as normal, but no attempt is made 
	** to validate the form value or decode it back to a Fantom value. 
	** 
	** Useful for rendering static, read only, HTML associated with the field.
	Bool? 		viewOnly
	
	** A general stash, handy for passing data to static validate methods. 
	[Str:Obj?]?	stash

	** A static method that performs extra server side validation. 
	Method?		validationMethod



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
	** If true then a disabled attribute is rendered on the '<input>'. 
	Bool	disabled

	** HTML attribute. 
	** The value to render as an 'autocomplete' attribute on the '<input>'.
	** See [autocomplete on whatwg]`https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls%3A-the-autocomplete-attribute` and [MDN]`https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/autocomplete` for valid values. 
	** Example:
	** 
	**   autocomplete = "cc-number"
	Str?	autocomplete

	** HTML attribute. 
	** Any other miscellaneous attributes that should be rendered on the '<input>'. 
	** Example:
	** 
	**   attributes = "data-foo='bar'"
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
	** Sets the maximum value (inclusive). May be an 'Int', 'Date', 'DateTime', or 'Str'.
	Int?	maxLength

	** HTML5 validation attribute.
	** Sets the minimum value (inclusive). May be an 'Int', 'Date', 'DateTime', or 'Str'.
	Obj?	min
	
	** HTML5 validation attribute.
	** Sets the maximum value (inclusive) for numbers ('Int') and dates ('Date').
	Obj?	max
	
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
	
	@Inject private const	|->Scope|	_scope
	@Inject private const	InputSkins	_inputSkins
	@Inject private const	WebProxy	_webProxy

	** Create 'FormField' instances via IoC:
	** 
	**   syntax: fantom
	**   formField := scope.build(FormField#, [field, formBean])
	** 
	new make(Field field, FormBean formBean, |This| in) {
		this.field		= field
		this.formBean	= formBean
		in(this)
	}
	
	** Populates this 'FormField' instance with values from the '@HtmlInput' facet (if any) and 
	** message values.
	This populate() {
		input := (HtmlInput?) field.facet(HtmlInput#, false)
		
		valueEncoder	= _fromObjCache(input?.valueEncoder		?: msg("valueEncoder"))
		inputSkin		= _fromObjCache(input?.inputSkin 		?: msg("inputSkin"))
		optionsProvider	= _fromObjCache(input?.optionsProvider	?: msg("optionsProvider"))
		type			= input?.type			?: msg("type"		)
		label			= input?.label			?: msg("label"		)
		placeholder		= input?.placeholder	?: msg("placeholder")
		hint			= input?.hint			?: msg("hint"		)
		css				= input?.css			?: msg("css"		)
		disabled		= (input?.disabled		?: msg("disabled"	)?.toBool) ?: false
		autocomplete	= input?.autocomplete	?: msg("autocomplete")
		attributes		= input?.attributes		?: msg("attributes"	)
		viewOnly		= input?.viewOnly		?: msg("viewOnly"	)?.toBool
		required		= input?.required		?: msg("required"	)?.toBool
		minLength		= input?.minLength		?: msg("minLength"	)?.toInt
		maxLength		= input?.maxLength		?: msg("maxLength"	)?.toInt
		min				= input?.min			?: msg("min"		)	// don't convert to Int, Date, etc... instead allow values to be passed through to HTML
		max				= input?.max			?: msg("max"		)	// don't convert to Int, Date, etc... instead allow values to be passed through to HTML
		pattern			= input?.pattern		?: msg("pattern"	)?.toRegex
		step			= input?.step			?: msg("step"		)?.toInt
		showBlank		= input?.showBlank		?: msg("showBlank"	)?.toBool
		blankLabel		= input?.blankLabel		?: msg("blankLabel"	)
		validationMethod= input?.validationMethod ?: Method.findMethod(msg("validationMethod") ?: "<pod>::<type>.<slot>", false)
		
		return this
	}
	
	private Obj? _fromObjCache(Obj? what) {
		if (what is Str)
			what = Type.find(what)
		if (what is Type)
			return _webProxy.getObj(what)
		return null
	}
	
	** Returns a message for the given field. Messages are looked up in the following order:
	** 
	**   - '<bean>.<field>.<key>'
	**   - '<field>.<key>'
	**   - '<key>'
	** 
	** And the following substitutions are made:
	** 
	**  - '${label} -> formField.label'
	**  - '${value} -> formField.formValue'
	**  - '${arg1}  -> arg1.toStr'
	**  - '${arg2}  -> arg2.toStr'
	**  - '${arg3}  -> arg3.toStr'
	** 
	** The form value is substituted for '${value}' because it is intended for use by validation msgs. 
	** 
	** Returns 'null' if a msg could not be found.
	Str? msg(Str key, Obj? arg1 := null, Obj? arg2 := null, Obj? arg3 := null) {
		formBean.fieldMsg(this, key, arg1, arg2, arg3)
	}

	** Convenience for 'msg()'. 
	** Returns a message for the given field. Messages are looked up in the following order:
	** 
	**  - '<bean>.<field>.<key>'
	**  - '<field>.<key>'
	**  - '<key>'
	** 
	** And the following substitutions are made:
	** 
	**  - '${label} -> formField.label'
	**  - '${value} -> formField.formValue'
	**  - '${arg1}  -> arg1.toStr'
	**  - '${arg2}  -> arg2.toStr'
	**  - '${arg3}  -> arg3.toStr'
	** 
	** The form value is substituted for '${value}' because it is intended for use by validation msgs. 
	** 
	** Returns 'null' if a msg could not be found.
	@Operator @NoDoc
	Str getMsg(Str key, Obj? arg1 := null, Obj? arg2 := null, Obj? arg3 := null) {
		msg(key, arg1, arg2, arg3)
	}

	** Sets the given form field message. Messages are stored in the FormBean under the key:
	** 
	**  - '<bean>.<field>.<key>'
	** 
	** 'null' values are removed from the messges map.
	@Operator
	Void set(Str key, Obj? val) {
		msgKey := "${formBean.beanType.name}.${field.name}.${key}"
		if (val == null)
			formBean.messages.remove(msgKey)
		else
			formBean.messages.set(msgKey, val.toStr)
	}

	** Hook to render this field to HTML.
	** By default this defers rendering to an 'InputSkin'.
	** 
	** Override to perform custom field rendering.
	virtual Str render(Obj? bean := null) {
		skinCtx := SkinCtx() {
			it.bean			= bean
			it.field		= this.field
			it.formBean		= this.formBean
			it.formField	= this
		}
		
		inputSkin := inputSkin ?: _inputSkins.find(type ?: "text")
		return inputSkin.render(skinCtx)		
	}
	
	** Converts the given value to a string using the preferred 'ValueEncoder'.
	Str toClient(Obj? value) {
		strVal := (Str) ((valueEncoder != null) ? valueEncoder->toClient(value) : _webProxy.toClient(field.type, value))
		return strVal.toXml
	}
	
	** Converts the given client value (string) to a server side object using the preferred 'ValueEncoder'.
	** 
	** 
	Obj? toValue(Str clientValue) {
		((valueEncoder != null) ? valueEncoder->toValue(clientValue) : _webProxy.toValue(field.type, clientValue))
	}
	
	** Validates this form field.
	** Calls 'doHtmlValidation()' and then any static '@Validate' method that corresponds to this field. 
	** 
	** '@Validate' methods may check 'invalid' and 'errMsg' to ascertain if any previous validation failed.
	** 
	** After validation check the value of the 'invalid' and 'errMsg' fields. 
	virtual Void validate() {
		doHtmlValidation

		if (validationMethod != null)
			_scope().callMethod(validationMethod, null, [this])

		// should it be validationMethod AND / OR @Validate methods?
		field.parent.methods
			.findAll { ((Validate?) it.facet(Validate#, false))?.field == field }
			.each 	 { _scope().callMethod(it, null, [this]) }
	}

	** Performs basic HTML5 validation.
	virtual Void doHtmlValidation() {
		// formValue should already be trimmed
		hasValue := formValue != null && !formValue.isEmpty

		if (required ?: false)
			if (formValue == null || formValue.isEmpty)
				return errMsg = msg("required.msg") ?: "[required.msg]"
		
		if (hasValue && minLength != null)
			if (formValue.size < minLength)
				return errMsg = msg("minLength.msg", minLength) ?: "[minLength.msg]"

		if (hasValue && maxLength != null)
			if (formValue.size > maxLength)
				return errMsg = msg("maxLength.msg", maxLength) ?: "[maxLength.msg]"

		if (hasValue && type == "number")
			if (formValue.toInt(10, false) == null)
				return errMsg = msg("notNum.msg") ?: "[notNum.msg]"
	
		if (hasValue && min?.toStr?.toInt(10, false) != null) {
			if (formValue.toInt(10, false) == null)
				return errMsg = msg("notNum.msg") ?: "[notNum.msg]"
			if (formValue.toInt < min.toStr.toInt)
				return errMsg = msg("min.msg", min) ?: "[min.msg]"
		}

		if (hasValue && max?.toStr?.toInt(10, false) != null) {
			if (formValue.toInt(10, false) == null)
				return errMsg = msg("notNum.msg") ?: "[notNum.msg]"
			if (formValue.toInt > max.toStr.toInt)
				return errMsg = msg("max.msg", max) ?: "[max.msg]"
		}

		if (hasValue && pattern != null)
			if (!"^${pattern}\$".toRegex.matches(formValue))
				return errMsg = msg("pattern.msg", pattern) ?: "[pattern.msg]"		
	}
	
	@NoDoc
	override Int hash()				{ field.hash }
	
	@NoDoc
	override Bool equals(Obj? that)	{ (that as FormField)?.field == field }

	@NoDoc
	override Str toStr()			{ "${field} - ${formValue}" }
}
