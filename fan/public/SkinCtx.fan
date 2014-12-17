using afBedSheet

** Passed to 'InputSkins' to provide all the information they need to render a form field.
class SkinCtx {
				Obj?			bean
	const		Field			field
	internal	FormBean		formBean
	internal	FormField?		formField
	internal	Bool			inErr
	internal	ValueEncoders	valueEncoders
	
	internal new make(|This| in) { in(this) }

	** Returns the name of the field. Safe for use as a CSS class name.
	Str name() {
		field.name
	}

	** Returns the preferred display label associated with the field.
	Str label() {
		input.label?.toXml ?: (msg("field.${field.name}.label") ?: field.name.toDisplayName.toXml)		
	}
	
	** Returns the preferred string value to be rendered in the '<input>'. 
	Str value() {
		// if bean is null, check the formValue - we may have set a default!
		value := bean == null ? formField?.formValue : field.get(bean)
		// if the bean has *any* errors, always render the formValues
		return inErr ? (formField?.formValue ?: Str.defVal) : toClient(value)
	}
	
	** Returns the '@HtmlInput' facet on the field.
	HtmlInput input() {
		Slot#.method("facet").callOn(field, [HtmlInput#])	// Stoopid F4		
	}
	
	** Returns 'true' if the field has an error message.
	Bool fieldInvalid() {
		errMsg != null
	}

	** Returns 'true' if the *bean* is invalid; that is, if *any* field is in error.
	Bool beanInvalid() {
		inErr
	}

	** Returns the error message associated with this field.
	Str? errMsg() {
		formField?.errMsg?.toXml
	}
	
	** Returns the message (if any) associated with the given key.
	Str? msg(Str key) {
		formBean._msg(key)?.toXml
	}
	
	** Converts the given value to a string using the preferred 'ValueEncoder'.
	Str toClient(Obj? value) {
		strVal := (formField.valueEncoder != null) ? formField.valueEncoder.toClient(value) : valueEncoders.toClient(field.type, value)
		return strVal.toXml
	}
}
