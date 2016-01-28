
** Place on a method of a FormBean to have it take part in server side validation.
** Validate methods should be static and take a single 'FormField' parameter. 
** They should inspect the 'formField.value' and set an 'errMsg' if invalid.
** Example:
** 
** pre>
** syntax: fantom
** 
** class User {
**     Str? name
** 
**     @Validate { field=#name }
**     static Void validateName(FormField formField) {
**         if (formField.value == "Trisha")
**             formField.errMsg = "Ex-girlfriends not allowed!"
**     }
** }
** <pre
** 
** If '@Validate.field' is 'null' then the first parameter should be 'FormBean': 
** 
** pre>
** syntax: fantom
** 
** @Validate
** static Void validateBean(FormBean formBean) { ... }
** <pre
** 
** 'FormBean' validation is performed *after* 'FormField' validation.
** 
** Note that validation methods are called using IoC, so services may be passed in as extra parameters:
**  
** pre>
** syntax: fantom
** 
** @Validate
** static Void validateName(FormField formField, MyService service) { ... }
** <pre
** 
facet class Validate {
	
	** The field this method validates. The validation method will only be called with 'FormFields' that correspond to this field.
	** 
	** If 'null' then the method will be called with a 'FormBean' instance.
	const Field? field
}
