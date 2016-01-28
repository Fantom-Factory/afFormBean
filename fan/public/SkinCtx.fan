using afIoc
using afIocConfig
using afBedSheet

** Passed to 'InputSkins' to provide all the information they need to render a form field.
class SkinCtx {
	internal	ValueEncoders	_valueEncoders

	** The bean instance being rendered.
				Obj?			bean { internal set }
	
	** The corresponding bean field.
	const		Field			field
	
	
	** The 'FormField' being rendered.
				FormField		formField { internal set }
	
	** The containing 'FormBean' instance.
				FormBean		formBean { internal set }
	
	internal new make(|This|in) { in(this)	}

	** Returns the name of the field. Safe for use as an ID / CSS class name.
	Str name() {
		field.name
	}

	** Returns the preferred display label associated with the field.
	Str label() {
		formField.label ?: field.name.toDisplayName
	}

	** Returns the preferred string value to be rendered in the '<input>'. 
	Str value() {
		// if the bean has *any* errors, always render the formValues
		// bean errors indicate that the form has been validated and we are re-rendering the form with submitted values.
		beanInvalid ? (formField.formValue ?: "") : toClient(fieldValue)
	}
	
	** Returns the field value. 
	Obj? fieldValue() {
		// if bean is null, check the formValue - we may have set a default!
		bean == null ? formField.formValue : field.get(bean)
	}
	
	** Returns 'true' if the field is invalid. Note that if invalid, the field may not have an error msg.
	Bool fieldInvalid() {
		formField.invalid
	}

	** Returns 'true' if the *bean* is invalid; that is, if *any* field is in error.
	Bool beanInvalid() {
		formBean.hasErrors
	}

	** Returns the error message associated with this field.
	Str? errMsg() {
		formField.errMsg
	}
	
	** Converts the given value to a string using the preferred 'ValueEncoder'.
	Str toClient(Obj? value) {
		strVal := (formField.valueEncoder != null) ? formField.valueEncoder.toClient(value) : _valueEncoders.toClient(field.type, value)
		return strVal.toXml
	}
	
	** Returns a rendered string of common attributes to be placed in the '<input>' HTML tag.
	** This includes 'id', 'name' and any validation attributes defined on the 'HtmlInput' facet.
	** 
	** Note the string does *not* contain the 'type' or 'value' attributes as these are dependent on the input type.
	** 
	** The given 'extraAttributes' are merged in, allowing you to pass in extra css styles:
	** 
	**   syntax: fantom
	**   attrs := skinCtx.renderAttributes(["autocomplete" : "off"])
	** 
	** Note that empty string values are rendered as HTML5 empty attributes.
	Str renderAttributes([Str:Str]? extraAttributes := null) {
		attrs := Str:Str?[:] { it.ordered = true }
		attrs["id"]				= name
		attrs["class"]			= formField.css
		attrs["name"]			= name
		attrs["placeholder"]	= formField.placeholder
		attrs["minLength"]		= formField.minLength?.toStr
		attrs["maxlength"]		= formField.maxLength?.toStr
		attrs["min"]			= formField.min?.toStr
		attrs["max"]			= formField.max?.toStr
		attrs["step"]			= formField.step?.toStr
		attrs["pattern"]		= formField.pattern?.toStr
		attrs["required"]		= (formField.required ?: false) ? "" : null

		extraAttributes?.each |v, k| {
			attrs[k] = (attrs[k] == null) ? v : attrs[k] + " " + v 
		}

		// TODO: merge or override these attributes with what's just been processed
		// - don't blindly render the same attribute twice
		// - use Pegger to parse
		extra := (formField.attributes == null) ? "" : " ${formField.attributes}"

		return attrs.exclude { it == null }.join(" ") |v, k| { v.isEmpty ? k : "${k}=\"${v.toXml}\"" } + extra
	}
}
