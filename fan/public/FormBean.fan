using afIoc
using afBedSheet
using web
using afBeanUtils

** Features:
**  - Renders Fantom objects as editable HTML forms.
**  - Customised Select options.
**  - HTML5 client and server side validation.
**  - Customised error messages.
**  - Entities autobuilt with IoC.
** 
** Current limitations:
**  - Maps, Lists and nested objects are not supported.
**  - XHTML not supported. (Use HTML Parser to test.)
**  - Radioboxes are not supported.
**  - Only static enums supported for <select> options.
// crazy formatting: http://webdesign.tutsplus.com/tutorials/bring-your-forms-up-to-date-with-css3-and-html5-validation--webdesign-4738
class FormBean {	
	@Inject private const	Registry		registry
	@Inject private const	ObjCache		objCache
	@Inject private const	InputSkins		inputSkins
	@Inject private const	ValueEncoders 	valueEncoders
	
					const	Type			beanType
							Str:Str 		messages	:= Str:Str[:] { caseInsensitive=true }
							Field:FormField	formFields	:= Field:FormField[:] { ordered=true }
							Str[] 			errMsgs		:= Str[,]
	
	new make(Type beanType, |This| in) {
		this.beanType = beanType
		
		// set messages
		formMsgs := typeof  .pod.files.find { it.name == "FormBean.properties"         } .readProps
		beanMsgs := beanType.pod.files.find { it.name == "${beanType.name}.properties" }?.readProps
		this.messages.setAll(formMsgs).setAll(beanMsgs ?: [:])

		in(this)	// need the objCache
		
		// create formfields with default values
		beanType.fields.findAll { it.hasFacet(HtmlInput#) }.each |field| {
			input := (HtmlInput) Slot#.method("facet").callOn(field, [HtmlInput#])	// Stoopid F4
			formFields[field] = FormField {
				it.field	 		= field
				it.valueEncoder		= objCache[input.valueEncoder]
				it.inputSkin		= objCache[input.inputSkin]
				it.optionsProvider	= objCache[input.optionsProvider]
			}
		}
	}
	
	Str renderErrs() {
		if (!hasErrors) return Str.defVal
		buf := StrBuf()
		out := WebOutStream(buf.out)

		out.div("class='formBean-errors'")
		out.div("class='formBean-banner'").w(msg("errors.banner")).divEnd
		out.ul
		
		// don't encode err msgs, let the user specify HTML
		errMsgs.each { 
			out.li.w(it).liEnd			
		}
		formFields.vals.each {
			if (it.errMsg != null)
				out.li.w(it.errMsg).liEnd
		}
		out.ulEnd
		out.divEnd
		return buf.toStr 
	}

	** 'bean' may be 'null' if you're re-rendering a form with validation errors.
	Str renderBean(Obj? bean) {
		inErr	:= hasErrors
		html	:= Str.defVal
		formFields.each |formField, field| {
			skinCtx := SkinCtx {
				it.bean			= bean
				it.field		= field
				it.formBean		= this
				it.formField	= formField
				it.inErr		= inErr
				it.valueEncoders= this.valueEncoders
			}
			
			html += formField.inputSkin != null ? formField.inputSkin.render(skinCtx) : inputSkins.render(skinCtx)
		}
		return html
	}

	Str renderSubmit() {
		buf := StrBuf()
		out := WebOutStream(buf.out)

		label := msg("field.submit.label").toXml
		out.div("class='formBean-submitRow'")
		out.submit("name='formBeanSubmit' value='${label}'")
		out.divEnd

		return buf.toStr
	}
	
	Bool validateBean(Str:Str form) {
		formFields.each |formField, field| {
			input 		:= (HtmlInput) Slot#.method("facet").callOn(field, [HtmlInput#])	// Stoopid F4
			formValue 	:= (Str?) form[field.name]?.trim
			hasValue	:= formValue != null && !formValue.isEmpty

			// save the value in-case we have error and have to re-render
			formField.formValue = formValue

			if (input.required)
				if (formValue == null || formValue.isEmpty)
					return addErr(formField, formValue, "required", Str.defVal)
			
			if (hasValue && input.minLength != null)
				if (formValue.size < input.minLength)
					return addErr(formField, formValue, "minLength", input.minLength)

			if (hasValue && input.maxLength != null)
				if (formValue.size > input.maxLength)
					return addErr(formField, formValue, "maxLength", input.maxLength)

			if (hasValue && input.min != null) {
				if (formValue.toInt(10, false) == null)
					return addErr(formField, formValue, "notNum", Str.defVal)
				if (formValue.toInt < input.min)
					return addErr(formField, formValue, "min", input.min)
			}

			if (hasValue && input.max != null) {
				if (formValue.toInt(10, false) == null)
					return addErr(formField, formValue, "notNum", Str.defVal)
				if (formValue.toInt > input.max)
					return addErr(formField, formValue, "max", input.max)
			}

			if (hasValue && input.regex != null)
				if (!"^${input.regex}\$".toRegex.matches(formValue))
					return addErr(formField, formValue, "regex", input.regex)			
		}
		
		return !hasErrors
	}

	Obj createBean([Str:Obj?]? extraProps := null) {
		beanProps := gatherBeanProperties(extraProps)
		return BeanProperties.create(beanType, beanProps, null) { IocBeanFactory(registry, it) }
	}
	
	Obj updateBean(Obj bean, [Str:Obj?]? extraProps := null) {
		beanProps := gatherBeanProperties(extraProps)

		reg := registry
		factory := BeanPropertyFactory {
			it.makeFunc	 = |Type type->Obj| { IocBeanFactory(reg, type).create }.toImmutable
		}
		beanProps.each |value, expression| {
			factory.parse(expression).set(bean, value)
		}
		return bean
	}
	
	Bool hasErrors() {
		!errMsgs.isEmpty || formFields.vals.any { it.invalid }
	}
	
	internal Str? msg(Str key) {
		messages[key]
	}

	private Void addErr(FormField formField, Str? value, Str type, Obj constraint) {
		field	:= formField.field
		input 	:= (HtmlInput) Slot#.method("facet").callOn(field, [HtmlInput#])	// Stoopid F4
		label	:= input.label ?: (msg("field.${field.name}.label") ?: field.name.toDisplayName)
		errMsg 	:= this.msg("field.${field.name}.${type}") ?: this.msg("field.${type}")

		errMsg = errMsg
			.replace("\${label}", label)
			.replace("\${constraint}", constraint.toStr)
			.replace("\${value}", value ?: Str.defVal)

		formField.errMsg = errMsg
	}
	
	private Str:Obj? gatherBeanProperties([Str:Obj?]? extraProps) {
		beanProps := Str:Obj?[:]
		formFields.each |formField, field| {
			value := null

			// fugging checkboxes don't send unchecked data
			if (formField.formValue == null && formField.input.type.equalsIgnoreCase("checkbox"))
				value = false

			// other fields that weren't submitted are also null
			if (formField.formValue != null)
				value = (formField.valueEncoder != null) ? formField.valueEncoder.toValue(formField.formValue) : valueEncoders.toValue(field.type, formField.formValue)

			beanProps[field.name] = value
		}

		if (extraProps != null)
			beanProps.addAll(extraProps)
		
		return beanProps
	}
}

class FormField {
	Field				field
	ValueEncoder?		valueEncoder
	InputSkin?			inputSkin
	OptionsProvider?	optionsProvider
	Str?				errMsg	{ set { if (it != null) invalid = true; &errMsg = it } }
	Str?				formValue
	Bool				invalid { set { if (it == false) errMsg = null; &invalid = it } }

	@NoDoc
	new make(|This| in) { in(this) }
	
	HtmlInput input() {
		Slot#.method("facet").callOn(field, [HtmlInput#])	// Stoopid F4
	}
}
