using afIoc::Scope
using afIoc::Inject

internal const class HtmlInputInspector : FieldInspector {
	
	@Inject private const	|->Scope|	_scope		// use the 'http-request' active scope

	new make(|This|in) { in(this) }
	
	override FormField? inspect(FormBean formBean, Field field) {
		// guard against someone else creating a bean before us
		existing := formBean.formFields[field]
		if (existing != null)
			return existing

		// no facet, no FormField!
		if (field.hasFacet(HtmlInput#).not)
			return null

		// populate formField objects with any non-null values, minus any default values
		// 'null' is a useful indicator of where a default will be applied, 
		// meaning we can infer when to use semi-default values such as 'required' for non-nullable fields
		return ((FormField) _scope().build(FormField#, [field, formBean])).populate
	}
}
