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
	
	** Returns a rendered string of common attributes to be placed in the <input> HTML tag.
	** Note the string does *not* contain the 'type' or 'value' attributes as these are dependent on the input type.
	** 
	** The given 'extraAttributes' are merged in, allowing you to pass in extra css styles:
	** 
	**   attrs := skinCtx.renderAttributes(["class" : "hot-pink"])
	** 
	** Note that empty string values are rendered as HTML5 empty attributes.     
	Str renderAttributes([Str:Str]? extraAttributes := null) {
		attrs	:= Str:Str?[:] { it.ordered = true }
		attrs["id"]				= name
		attrs["class"]			= input.css
		attrs["name"]			= name
		attrs["placeholder"]	= input.placeholder ?: msg("field.${name}.placeholder")
		attrs["minLength"]		= input.minLength?.toStr
		attrs["maxlength"]		= input.maxLength?.toStr
		attrs["min"]			= input.min?.toStr
		attrs["max"]			= input.max?.toStr
		attrs["step"]			= input.step?.toStr
		attrs["pattern"]		= input.pattern
		attrs["required"]		= input.required ? "" : null
		
		if (input.minLength != null && input.pattern == null)
			attrs["pattern"]	= ".{${input.minLength},}"
		
		extraAttributes?.each |v, k| {
			attrs[k] = (attrs[k] == null) ? v : attrs[k] + " " + v 
		}

		// TODO: merge or override these attributes with what's just been processed
		// - don't blindly render the same attribute twice
		// - use Pegger to parse
		extra := (input.attributes == null) ? "" : " ${input.attributes}"

		return attrs.exclude { it == null }.join(" ") |v, k| { v.isEmpty ? k : "${k}=\"${v.toXml}\"" } + extra
	}
}
