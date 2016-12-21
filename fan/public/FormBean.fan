using afIoc
using afBedSheet
using afBeanUtils
using web

** Represents a Fantom type that can be rendered as a HTML form, and reconstituted back to a Fantom instance.
**   
** FormBean instances should be created by [IoC]`pod:afIoc`.
class FormBean {	
	@Inject private const	|->Scope|		_scope
	@Inject private const	ValueEncoders 	_valueEncoders
	@Inject private const	InputSkins		_inputSkins
	@Inject private const	ObjCache		_objCache
	@Inject private const	Messages		_messages
	@Inject private const	FieldInspectors	_fieldInspectors
	
	** The bean type this 'FormBean' represents.
					const	Type			beanType
	
	** The message map used to find strings for labels, placeholders, hints, and validation errors.  
	** Messages are read from (and overridden by) the following pod resource files: 
	**  - '<beanType.name>.properties' 
	**  - 'FormBean.properties'
	** Note that property files must be in the same pod as the defining bean. 
							Str:Str 		messages	:= Str:Str[:] { caseInsensitive=true }
	
	** The form fields that make up this form bean.
							Field:FormField	formFields	:= Field:FormField[:] { ordered=true } { private set }
	
	** You may set any extra (cross field validation) error messages here. 
	** They will be rendered along with the form field error messages.
							Str[] 			errorMsgs	:= Str[,]
	
	** The 'ErrorSkin' used to render error messages.
	@Inject { optional = true}
							ErrorSkin?		errorSkin

	** Hook for handling file uploads. By default, an in-memory file is returned.
	** In memory files do not require deleting.
	|Str fileName, InStream in -> File|?	fileUploadHook
	
	** Deconstructs the given form bean type to a map of 'FormFields'. 
	** 
	** FormBean instances should be created by [IoC]`pod:afIoc`. Either create manually:
	** 
	**   syntax: fantom
	**   formBean := (FormBean) scope.build(FormBean#, [MyFormModel#])
	** 
	** or inject a field:
	** 
	**   syntax: fantom
	**   @Inject { type=MyFormModel# }
	**   FormBean formBean
	** 
	new make(Type beanType, |This| in) {
		in(this)	// IoC Injection

		this.beanType = beanType
		this.messages = _messages.getMessages(beanType)
		
		_fieldInspectors.inspect(this, &formFields)
	}
	
	** Returns the form field that corresponds to the given field name.
	** 
	**   syntax:fantom
	**   formField := formBean["name"]
	@Operator
	FormField getByName(Str name) {
		&formFields.find { it.field.name.equalsIgnoreCase(name) }
	}
	
	** Re-generates the 'formFields' map. 
	** Useful if you've set new message properties and want them to be picked up.  
	Void reinspectBean() {
		&formFields.clear
		_fieldInspectors.inspect(this, &formFields)
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
	** This method does not handle file uploads - use 'validateRequest()' instead.
	** 
	** Returns 'true' if all the values are valid, 'false' if not.
	**  
	** It is safe to pass in 'HttpRequest.form()' directly.
	** 
	** Note that all form values are trimmed before being stowed and validated.
	virtual Bool validateForm(Str:Str form) {
		&formFields.each |formField, field| {
			if (formField.viewOnly == true)
				return

			formValue := (Str?) form[field.name]?.trim
			formField.formValue = formValue
			formField.validate
		}

		beanType.methods
			.findAll { it.hasFacet(Validate#) && ((Validate) it.facet(Validate#)).field == null }
			.each 	 { _scope().callMethod(it, null, [this]) }

		return !hasErrors
	}

	** Populates the form fields with values from the HTTP Request and performs server side validation.
	** Error messages are saved to the form fields.
	** 
	** This method also handles File uploads and sets any 'Buf' and 'File' fields to an appropriate 
	** value. HTML Forms with file uploads *must* have set the attribute '<form enctype="multipart/form-data" ... >'
	** 
	** If the form content type is *not* 'multipart/form-data' then processing is delegated to 
	** 'validateForm()'. That makes this method safe to use in all situations.
	** 
	** In memory file are returned for file uploads, so the caller does not need to concern themselves with deleting them.
	** 
	** Returns 'true' if all the values are valid, 'false' if not.
	virtual Bool validateRequest(HttpRequest httpReq) {
		if (httpReq.headers.contentType?.noParams != MimeType("multipart/form-data"))
			return validateForm(httpReq.body.form ?: Str:Str[:])

		form	:= Str:Str[:]
		httpReq.parseMultiPartForm |Str inputName, InStream in, Str:Str headers| {
			formField := &formFields.find { it.field.name == inputName }

			// in case of a binary upload, we set the formValue to the filename so it can be 'required' validated
			quoted   := headers["Content-Disposition"]?.split(';')?.find { it.lower.startsWith("filename") }?.split('=')?.getSafe(1)
			filename := quoted != null ? WebUtil.fromQuotedStr(quoted) : "${inputName}.tmp"

			switch (formField?.field?.type?.toNonNullable) {
				case InStream#:
					form[inputName]		= filename
					formField.formData	= in

				case Buf#:
					form[inputName]		= filename
					formField.formData	= in.readAllBuf

				case File#:
					form[inputName]		= filename
					formField.formData	= fileUploadHook?.call(filename, in) ?: in.readAllBuf.toFile(filename.toUri)
			
				default:
					form[inputName]		= in.readAllStr
			}
		}

		return validateForm(form)
	}
	
	** Convenience method to validate a single form field with a given value.
	**
	** Note that validation is skipped for 'viewOnly' fields and that given 'formValues' are *not* trimmed.
	** 
	** Returns any associated 'formField.errMsg'.
	** 
	** See [FormField.validate()]`FormField#validate`. 
	virtual Str? validate(Field field, Str? formValue) {
		formField := formFields[field]
		
		if (formField.viewOnly == true)
			return null

		formField.formValue = formValue
		formField.validate
		
		return formField.errMsg
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
	
	** Returns a message for the given field and key. Messages are looked up in the following order:
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
	** Returns 'null' if a message could not be found. 
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

	** Returns a message for the given key. Messages are looked up in the following order:
	** 
	**   - '<bean>.<key>'
	**   - '<key>'
	** 
	** And the following substitutions are made:
	** 
	**  - '${arg1}  -> arg1.toStr'
	**  - '${arg2}  -> arg2.toStr'
	**  - '${arg3}  -> arg3.toStr'
	** 
	** Returns 'null' if a message could not be found. 
	Str? msg(Str key, Obj? arg1 := null, Obj? arg2 := null, Obj? arg3 := null) {

		// bean messages have already been merged
		msg		:= messages["${key}"]

		return msg
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

			// set binary upload data 
			if (formField.formData != null) {
				beanProps[field.name] = formField.formData
				return
			}

			// fugging checkboxes don't send unchecked data
			if (formField.formValue == null && formField.type.equalsIgnoreCase("checkbox"))
				beanProps[field.name] = false

			// other fields that weren't submitted are also null
			if (formField.formValue != null) {
				value = (formField.valueEncoder != null)
					? formField.valueEncoder.toValue(formField.formValue)
					: _valueEncoders.toValue(field.type, formField.formValue)
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

