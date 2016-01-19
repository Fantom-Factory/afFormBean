
** [IocConfig]`pod:afIocConfig` values as provided by FormBean. 
** To change their value, override them in your 'AppModule'. 
** Example:
** 
** pre>
** syntax: fantom 
** @Contribute { serviceType=ApplicationDefaults# } 
** Void configureApplicationDefaults(Configuration config) {
**     config[FormBeanConfigIds.defaultMaxLength] = 512
** }
** <pre
class FormBeanConfigIds {
	
	** The default value for 'HtmlInput.maxLength' should none be specified.
	** 
	** It is good practice to always give text fields a max length but,
	** if you wish disable 'maxLength' altogether, contribute a default value of 'null'.
	** 
	** Defaults to '512'.
	static const Str defaultMaxLength	:= "afFormBean.defaultMaxLength"
	
}
