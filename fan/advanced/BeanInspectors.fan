
@NoDoc
const class FieldInspectors {
	
	private const FieldInspector[] inspectors
	
	new make(FieldInspector[] inspectors) {
		this.inspectors = inspectors
	}
	
	Void inspect(FormBean formBean, Field:FormField	formFields) {
		formBean.beanType.fields.each |field| {
			inspectors.each {
				// allow each inspector to create new / delete existing
				formField := it.inspect(formBean, field)
				if (formField == null)
					formFields.remove(field)
				else
					formFields[field] = formField 
			}
		}
	}
}
