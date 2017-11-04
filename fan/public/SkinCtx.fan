
** Passed to 'InputSkins' to provide all the information they need to render a form field.
class SkinCtx {
	internal	WebProxy		_webProxy

	** The bean instance being rendered.
				Obj?			bean { internal set }
	
	** The corresponding bean field.
	const		Field			field
	
	** The 'FormField' being rendered.
				FormField		formField { internal set }
	
	** The containing 'FormBean' instance.
				FormBean		formBean { internal set }
	
	** Convenience for `FormField.errMsg`.
	** 
	** The error message associated with this field.
	** 
	** Setting this to a non-null value invalidate the form field. 
				Str?			errMsg	{
					get { formField.errMsg }
					set { formField.errMsg = it }
				}

	** Convenience for `FormField.invalid`.
	** 
	** Returns 'true' if the form field is invalid. Note that just because the field is invalid, 
	** it does not mean it has an error message. 
	** 
	** Setting this to 'false' also clears any 'errMsg'. 
				Bool			fieldInvalid {
					get { formField.invalid }
					set { formField.invalid = it }
				}
	
	internal new make(|This|in) { in(this)	}

	
	** Convenience for 'field.name' plus any unique ID suffix defined by the 'FormBean'.
	Str id() {
		field.name + (formBean.uniqueIdSuffix ?: "")
	}
	
	** Convenience for 'field.name' and used as the form name. Also safe for use as a CSS class name.
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
	
	** Returns 'true' if the *bean* is invalid; that is, if *any* field is in error.
	Bool beanInvalid() {
		formBean.hasErrors
	}
	
	** Converts the given value to a string using the preferred 'ValueEncoder'.
	Str toClient(Obj? value) {
		strVal := (Str) ((formField.valueEncoder != null) ? formField.valueEncoder->toClient(value) : _webProxy.toClient(field.type, value))
		return strVal.toXml
	}
	
	** Convenience for `FormField.msg`.
	** 
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
		formField.msg(key, arg1, arg2, arg3)
	}
	
	** Returns a rendered string of common attributes to be placed in the '<input>' HTML tag.
	** This includes 'id', 'name' and any validation attributes defined on the 'HtmlInput' facet.
	** 
	** Note the string does *not* contain the 'type' or 'value' attributes as these are dependent on the input type.
	** 
	** The given 'extraAttributes' are merged in, with any values of the same name being separated with a space.
	** This allows you to pass in extra css class names.
	** 
	**   syntax: fantom
	**   attrs := skinCtx.renderAttributes(["autocomplete" : "off", "css" : "funkStyle"])
	** 
	** Note that empty string values are rendered as HTML5 empty attributes.
	** e.g. '["disabled":""]' would be rendered as just 'disabled'.
	Str renderAttributes([Str:Str]? extraAttributes := null) {
		attrs := Str:Str?[:] { it.ordered = true }
		attrs["id"]				= id
		attrs["class"]			= formField.css
		attrs["name"]			= name
		attrs["placeholder"]	= formField.placeholder
		attrs["minlength"]		= formField.minLength?.toStr
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
