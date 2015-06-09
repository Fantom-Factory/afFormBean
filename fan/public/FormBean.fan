using afIoc
using afBedSheet
using afBeanUtils
using web

** Represents a Fantom object that can rendered as a HTML form, and reconstituted back to a Fantom object.  
class FormBean {	
	@Inject private const	Registry		registry
	@Inject private const	ObjCache		objCache
	@Inject private const	InputSkins		inputSkins
	@Inject private const	ValueEncoders 	valueEncoders
	@Inject private const	Messages		_messages
	
	** The bean type this 'FormBean' represents.
					const	Type			beanType
	
	** The message map used to find strings for labels, placeholders, hints, and validation errors.  
	** Messages are read from (and overridden by) the following pod resource files: 
	**  - '<beanType.name>.properties' 
	**  - 'FormBean.properties'
	** Note that property files must be in the same pod as the defining bean. 
							Str:Str 		messages	:= Str:Str[:] { caseInsensitive=true }
	
	** The form fields that make up this form bean.
	** The returned map is read only, but the 'FormFields' themselves may still be manipulated.
							Field:FormField	formFields	:= Field:FormField[:] { ordered=true } { get { &formFields.ro } private set }
	
	** You may set any extra (cross field validation) error messages here. 
	** They will be rendered along with the form field error messages.
							Str[] 			errorMsgs	:= Str[,]
	
	** The 'ErrorSkin' used to render error messages.
	@Inject { optional = true}
							ErrorSkin?		errorSkin
	
	** Deconstructs the given form bean type to a map of 'FormFields'. 
	new make(Type beanType, |This| in) {
		this.beanType = beanType
		in(this)	// need the objCache

		this.messages = _messages.getMessages(beanType)
		
		// create formfields with default values
		beanType.fields.findAll { it.hasFacet(HtmlInput#) }.each |field| {
			input := (HtmlInput) Slot#.method("facet").callOn(field, [HtmlInput#])	// Stoopid F4
			&formFields[field] = FormField {
				it.field	 		= field
				it.valueEncoder		= objCache[input.valueEncoder]
				it.inputSkin		= objCache[input.inputSkin]
				it.optionsProvider	= objCache[input.optionsProvider]
			}
		}
	}
	
	** Renders form field errors (if any) to an unordered list.
	** Delegates to a default instance of 'ErrorSkin' which renders the following HTML:
	** 
	**   <div class='formBean-errors'>
	**       <div class='formBean-banner'>#BANNER</div>
	**       <ul>
	**           <li> Error 1 </li>
	**           <li> Error 2 </li>
	**       </ul>
	**   </div>
	** 
	** To change the banner message, set a message with the key 'errors.banner'.
	Str renderErrors() {
		((ErrorSkin) (errorSkin ?: DefaultErrorSkin())).render(this)
	}

	** Renders the form bean to a HTML form.
	** 
	** If the given 'bean' is 'null' then values are taken from the form fields. 
	** Do so if you're re-rendering a form with validation errors.
	Str renderBean(Obj? bean) {
		if (bean != null && !bean.typeof.fits(beanType))
			throw Err("Bean '${bean.typeof.qname}' is not of FormBean type '${beanType.qname}'")
		inErr	:= hasErrors
		html	:= Str.defVal
		&formFields.each |formField, field| {
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

	** Renders a simple submit button.
	** 
	**   <div class='formBean-row submitRow'>
	**     <input type='submit' name='formBeanSubmit' class='submit' value='label'>
	**   </div>
	** 
	** The label is taken from the msg key 'field.submit.label' and defaults to 'Submit'.
	Str renderSubmit() {
		buf := StrBuf()
		out := WebOutStream(buf.out)

		label := _msg("field.submit.label") ?: "Submit"
		out.div("class='formBean-row submitRow'")
		out.submit("name=\"formBeanSubmit\" class=\"submit\" value=\"${label.toXml}\"")
		out.divEnd

		return buf.toStr
	}
	
	** Populates the form fields with values from the given 'form' map and performs server side validation.
	** Error messages are saved to the form fields.
	** 
	** Returns 'true' if all the values are valid, 'false' if not.
	**  
	** It is safe to pass in 'HttpRequest.form()' directly.
	Bool validateForm(Str:Str form) {
		&formFields.each |formField, field| {
			input 		:= formField.input
			formValue 	:= (Str?) form[field.name]?.trim
			hasValue	:= formValue != null && !formValue.isEmpty

			// save the value in-case we have error and have to re-render
			formField.formValue = formValue

			if (input.required)
				if (formValue == null || formValue.isEmpty)
					{ _addErr(formField, formValue, "required", Str.defVal); return }
			
			if (hasValue && input.minLength != null)
				if (formValue.size < input.minLength)
					{ _addErr(formField, formValue, "minLength", input.minLength); return }

			if (hasValue && input.maxLength != null)
				if (formValue.size > input.maxLength)
					{ _addErr(formField, formValue, "maxLength", input.maxLength); return }

			if (hasValue && input.min != null) {
				if (formValue.toInt(10, false) == null)
					{ _addErr(formField, formValue, "notNum", Str.defVal); return }
				if (formValue.toInt < input.min)
					{ _addErr(formField, formValue, "min", input.min); return }
			}

			if (hasValue && input.max != null) {
				if (formValue.toInt(10, false) == null)
					{ _addErr(formField, formValue, "notNum", Str.defVal); return }
				if (formValue.toInt > input.max)
					{ _addErr(formField, formValue, "max", input.max); return }
			}

			if (hasValue && input.pattern != null)
				if (!"^${input.pattern}\$".toRegex.matches(formValue))
					{ _addErr(formField, formValue, "pattern", input.pattern); return }			
		}
		
		return !hasErrors
	}

	** Creates an instance of 'beanType' with all the field values set to the form field values.
	** Uses 'afBeanUtils::BeanProperties.create()'.
	** 
	** This should only be called after 'validateForm()'.
	** 
	** Any extra properties passed in will also be set.
	Obj createBean([Str:Obj?]? extraProps := null) {
		beanProps := _gatherBeanProperties(extraProps)
		return BeanProperties.create(beanType, beanProps, null) { IocBeanFactory(registry, it) }
	}

	** Updates the given bean instance with form field values.
	** Uses 'afBeanUtils::BeanProperties'.
	** 
	** This should only be called after 'validateForm()'.
	** 
	** Any extra properties passed in will also be set.
	Obj updateBean(Obj bean, [Str:Obj?]? extraProps := null) {
		if (!bean.typeof.fits(beanType))
			throw Err("Bean '${bean.typeof.qname}' is not of FormBean type '${beanType.qname}'")
		beanProps := _gatherBeanProperties(extraProps)

		reg := registry
		factory := BeanPropertyFactory {
			it.makeFunc	 = |Type type->Obj| { IocBeanFactory(reg, type).create }.toImmutable
		}
		beanProps.each |value, expression| {
			// if a value wasn't submitted, it's not in the list, therefore set all beanProps
			factory.parse(expression).set(bean, value)
		}
		return bean
	}
	
	** Returns 'true' if any form fields are in error, or if any extra error messages have been added to this
	Bool hasErrors() {
		!errorMsgs.isEmpty || &formFields.vals.any { it.invalid }
	}
	
	internal Str? _msg(Str key) {
		messages[key]
	}

	private Void _addErr(FormField formField, Str? value, Str type, Obj constraint) {
		field	:= formField.field
		input 	:= (HtmlInput) Slot#.method("facet").callOn(field, [HtmlInput#])	// Stoopid F4
		label	:= input.label ?: (_msg("field.${field.name}.label") ?: field.name.toDisplayName)
		errMsg 	:= _msg("field.${field.name}.${type}") ?: _msg("field.${type}")

		errMsg = errMsg
			.replace("\${label}", label)
			.replace("\${constraint}", constraint.toStr)
			.replace("\${value}", value ?: Str.defVal)

		formField.errMsg = errMsg
	}
	
	private Str:Obj? _gatherBeanProperties([Str:Obj?]? extraProps) {
		beanProps := Str:Obj?[:]
		&formFields.each |formField, field| {
			value := null

			// fugging checkboxes don't send unchecked data
			if (formField.formValue == null && formField.input.type.equalsIgnoreCase("checkbox"))
				beanProps[field.name] = false

			// other fields that weren't submitted are also null
			if (formField.formValue != null) {
				value = (formField.valueEncoder != null) ? formField.valueEncoder.toValue(formField.formValue) : valueEncoders.toValue(field.type, formField.formValue)
				beanProps[field.name] = value
			}
		}

		if (extraProps != null)
			beanProps.addAll(extraProps)
		
		return beanProps
	}
}

