using afBedSheet

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
	
	Str label() {
		input.label?.toXml ?: (msg("field.${field.name}.label") ?: field.name.toDisplayName.toXml)		
	}
	
	Str value() {
		// if bean is null, check the formValue - we may have set a default!
		value := bean == null ? formField?.formValue : field.get(bean)
		// if the bean has *any* errors, always render the formValues
		return inErr ? (formField?.formValue ?: Str.defVal) : toClient(value)
	}
	
	HtmlInput input() {
		Slot#.method("facet").callOn(field, [HtmlInput#])	// Stoopid F4		
	}
	
	Bool fieldInvalid() {
		errMsg != null
	}

	Bool beanInvalid() {
		inErr
	}

	Str? errMsg() {
		formField?.errMsg?.toXml
	}
	
	Str? msg(Str key) {
		formBean.msg(key)?.toXml
	}
	
	Str toClient(Obj? value) {
		strVal := (formField.valueEncoder != null) ? formField.valueEncoder.toClient(value) : valueEncoders.toClient(field.type, value)
		return strVal.toXml
	}
}
