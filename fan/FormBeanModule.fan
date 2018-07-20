using afIoc

@NoDoc
const class FormBeanModule {
	
	Void defineServices(RegistryBuilder defs) {
		defs.addService(InputSkins#)
		defs.addService(OptionsProviders#)
		defs.addService(Messages#)
		defs.addService(FieldInspectors#)
		defs.addService(WebProxy#)
	}
	
	@Contribute { serviceType=InputSkins# }
	Void contributeInputSkins(Configuration config) {
		textInputSkin		:= TextInputSkin()
		config["text"] 		= textInputSkin
		config["color"]		= textInputSkin
		config["date"] 		= textInputSkin
		config["datetime"]	= textInputSkin
		config["email"]		= textInputSkin
		config["file"]		= textInputSkin
		config["hidden"] 	= textInputSkin
		config["month"]		= textInputSkin
		config["number"] 	= textInputSkin
		config["password"] 	= textInputSkin
		config["range"] 	= textInputSkin
		config["search"] 	= textInputSkin
		config["tel"] 		= textInputSkin
		config["time"] 		= textInputSkin
		config["url"] 		= textInputSkin
		config["week"] 		= textInputSkin
		config["checkbox"]	= CheckboxSkin()
		config["textarea"]	= TextAreaSkin()
		config["select"]	= config.build(SelectSkin#)
		config["radio"]		= config.build(RadioSkin#)
//		config["button"]	= 
//		config["image"]		= 
//		config["reset"]		= 
//		config["submit"]	= 
	}
	
	@Contribute { serviceType=FieldInspectors# }
	Void contributeFieldInspectors(Configuration config) {
		config["afFormBean.htmlInput"] 		= config.build(HtmlInputInspector#)
		config["afFormBean.semiDefaults"]	= config.build(SemiDefaultInspector#)
	}
	
	@Contribute { serviceType=OptionsProviders# }
	Void contributeOptionsProviders(Configuration config) {
		config[Enum#] = EnumOptionsProvider()
	}

	@Contribute { serviceType=DependencyProviders# }
	Void contributeDependencyProviders(Configuration config) {
		config["afFormBean.formBeanProvider"] = config.build(FormBeanProvider#)
	}
}
