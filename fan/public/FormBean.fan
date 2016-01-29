using afIoc
using afIocConfig::Config
using afBedSheet
using afBeanUtils
using web

** Represents a Fantom type that can be rendered as a HTML form, and reconstituted back to a Fantom instance.  
class FormBean {	
	@Inject private const	|->Scope|		_scope
	@Inject private const	ValueEncoders 	_valueEncoders
	@Inject private const	InputSkins		_inputSkins
	@Inject private const	ObjCache		_objCache
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
		in(this)	// IoC Injection

		this.beanType = beanType
		this.messages = _messages.getMessages(beanType)
		
		// create formfields with default values
		beanType.fields.findAll { it.hasFacet(HtmlInput#) }.each |field| {
			input := (HtmlInput) field.facet(HtmlInput#)

			// populate formField objects with any non-null values, minus any default values
			// 'null' is a useful indicator of where a default will be applied, 
			// meaning we can infer when to use semi-default values such as 'required' for non-nullable fields
			&formFields[field] = ((FormField) _scope().build(FormField#, null, [
				FormField#field	 	: field,
				FormField#formBean	: this
			])) {
				it.valueEncoder		= fromObjCache(input.valueEncoder	 ?: fieldMsg(it, "valueEncoder"))
				it.inputSkin		= fromObjCache(input.inputSkin 		 ?: fieldMsg(it, "inputSkin"))
				it.optionsProvider	= fromObjCache(input.optionsProvider ?: fieldMsg(it, "optionsProvider"))
				it.type				= input.type		?: fieldMsg(it, "type"			)
				it.label			= input.label		?: fieldMsg(it, "label"			)
				it.placeholder		= input.placeholder	?: fieldMsg(it, "placeholder"	)
				it.hint				= input.hint		?: fieldMsg(it, "hint"			)
				it.css				= input.css			?: fieldMsg(it, "css"			)
				it.attributes		= input.attributes	?: fieldMsg(it, "attributes"	)
				it.viewOnly			= input.viewOnly	?: fieldMsg(it, "viewOnly"		)?.toBool
				it.required			= input.required	?: fieldMsg(it, "required"		)?.toBool
				it.minLength		= input.minLength	?: fieldMsg(it, "minLength"		)?.toInt
				it.maxLength		= input.maxLength	?: fieldMsg(it, "maxLength"		)?.toInt
				it.min				= input.min			?: fieldMsg(it, "min"			)?.toInt
				it.max				= input.max			?: fieldMsg(it, "max"			)?.toInt
				it.pattern			= input.pattern		?: fieldMsg(it, "pattern"		)?.toRegex
				it.step				= input.step		?: fieldMsg(it, "step"			)?.toInt
				it.showBlank		= input.showBlank	?: fieldMsg(it, "showBlank"		)?.toBool
				it.blankLabel		= input.blankLabel	?: fieldMsg(it, "blankLabel"	)

				applySemiDefaults(it)
			}
		}
	}
	
	@NoDoc	// virtual so people can overide and turn off this behaviour 
	virtual Void applySemiDefaults(FormField formField) {
		// TODO add contributions to do this in an inspection hook - that way they can be easily disabled / turned off
		formField {
			// a 'required' checkbox means it *has* to be checked - usually not what we want by default
			if (required == null && field.type.isNullable.not && field.type != Bool#)
				required = true

			if (type == null && field.type == Bool#)
				type = "checkbox"

			if (type == null && field.name.lower.contains("email"))
				type = "email"

			if (type == null && (field.name == "url" || field.name == "uri" || field.name.endsWith("Url") || field.name.endsWith("Uri")))
				type = "url"
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
	virtual Str renderErrors() {
		((ErrorSkin) (errorSkin ?: DefaultErrorSkin())).render(this)
	}

	** Renders the form bean to a HTML form.
	** 
	** If the given 'bean' is 'null' then values are taken from the form fields. 
	** Do so if you're re-rendering a form with validation errors.
	virtual Str renderBean(Obj? bean) {
		if (bean != null && !bean.typeof.fits(beanType))
			throw Err("Bean '${bean.typeof.qname}' is not of FormBean type '${beanType.qname}'")
		inErr	:= hasErrors
		html	:= Str.defVal
		&formFields.each |formField, field| {
			html += formField.render(bean)
		}
		return html
	}

	** Renders a simple submit button.
	** 
	**   <div class='formBean-row submitRow'>
	**     <input type='submit' name='formBeanSubmit' class='submit' value='label'>
	**   </div>
	** 
	** The label is taken from the msg key 'submit.label' and defaults to 'Submit'.
	virtual Str renderSubmit() {
		buf := StrBuf()
		out := WebOutStream(buf.out)

		label := messages["submit.label"] ?: ""
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
	virtual Bool validateForm(Str:Str form) {
		&formFields.each |formField, field| {
			if (formField.viewOnly ?: false)
				return

			// save the value in-case we have error and have to re-render
			formValue := (Str?) form[field.name]?.trim
			formField.formValue = formValue

			formField.validate
		}
		
		beanType.methods
			.findAll { it.hasFacet(Validate#) && ((Validate) it.facet(Validate#)).field == null }
			.each 	 { _scope().callMethod(it, null, [this]) }
		
		return !hasErrors
	}

	** Creates an instance of 'beanType' with all the field values set to the form field values.
	** Uses 'afBeanUtils::BeanProperties.create()'.
	** 
	** This should only be called after 'validateForm()'.
	** 
	** Any extra properties passed in will also be set.
	virtual Obj createBean([Str:Obj?]? extraProps := null) {
		beanProps := _gatherBeanProperties(extraProps)
		return BeanProperties.create(beanType, beanProps, null) { _scope().build(IocBeanFactory#, [it]) }
	}

	** Updates the given bean instance with form field values.
	** Uses 'afBeanUtils::BeanProperties'.
	** 
	** This should only be called after 'validateForm()'.
	** 
	** The given extra properties will also be set on the bean.
	** 
	** Returns the given bean instance.
	virtual Obj updateBean(Obj bean, [Str:Obj?]? extraProps := null) {
		if (!bean.typeof.fits(beanType))
			throw Err("Bean '${bean.typeof.qname}' is not of FormBean type '${beanType.qname}'")
		beanProps := _gatherBeanProperties(extraProps)

		scope	:= _scope()	// for the immutable func
		factory := BeanPropertyFactory {
			it.makeFunc	 = |Type type->Obj| { ((IocBeanFactory) scope.build(IocBeanFactory#, [type])).create }.toImmutable
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
	Str? fieldMsg(FormField formField, Str key, Obj? arg1 := null, Obj? arg2 := null, Obj? arg3 := null) {

		// bean messages have already been merged
		msg		:= messages["${formField.field.name}.${key}"] ?: messages["${key}"]
		label	:= formField.label ?: formField.field.name.toDisplayName
		value	:= formField.formValue ?: ""

		return msg
			?.replace("\${label}", 	label)
			?.replace("\${value}",	value)
			?.replace("\${arg1}",	arg1?.toStr ?: "")
			?.replace("\${arg2}",	arg2?.toStr ?: "")
			?.replace("\${arg3}",	arg3?.toStr ?: "")
	}
	
	private Str:Obj? _gatherBeanProperties([Str:Obj?]? extraProps) {
		beanProps := Str:Obj?[:]
		&formFields.each |formField, field| {
			value := null
			
			if (formField.viewOnly ?: false)
				return

			// fugging checkboxes don't send unchecked data
			if (formField.formValue == null && formField.type.equalsIgnoreCase("checkbox"))
				beanProps[field.name] = false

			// other fields that weren't submitted are also null
			if (formField.formValue != null) {
				value = (formField.valueEncoder != null) ? formField.valueEncoder.toValue(formField.formValue) : _valueEncoders.toValue(field.type, formField.formValue)
				beanProps[field.name] = value
			}
		}

		if (extraProps != null)
			beanProps.addAll(extraProps)
		
		return beanProps
	}
	
	private Obj? fromObjCache(Obj? what) {
		if (what is Str)
			what = Type.find(what)
		if (what is Type)
			return _objCache[what]
		return null
	}
}

