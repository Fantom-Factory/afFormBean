using afIoc
using afIocConfig
using afBedSheet

@NoDoc
const class FormBeanModule {
	
	Void defineServices(RegistryBuilder defs) {
		defs.addService(InputSkins#)
		defs.addService(OptionsProviders#)
		defs.addService(Messages#)
	}
	
	@Contribute { serviceType=InputSkins# }
	Void contributeInputSkins(Configuration config) {
		textInputSkin		:= TextInputSkin()
		config["text"] 		= textInputSkin
		config["date"] 		= textInputSkin
		config["datetime"]	= textInputSkin
		config["email"]		= textInputSkin
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
//		config["button"]	= 
//		config["color"]		= 
//		config["file"]		= 
//		config["image"]		= 
//		config["radio"]		= 
//		config["reset"]		= 
//		config["submit"]	= 
	}
	
	@Contribute { serviceType=OptionsProviders# }
	Void contributeOptionsProviders(Configuration config) {
		config[Enum#] = EnumOptionsProvider(true, "")
	}

	@Contribute { serviceType=ValueEncoders# }
	Void contributeValueEncoders(Configuration config) {
		config[Bool#] = BoolEncoder()
	}

	@Contribute { serviceType=DependencyProviders# }
	Void contributeDependencyProviders(Configuration config) {
		config["afFormBean.formBeanProvider"] = config.build(FormBeanProvider#)
	}
	
	@Contribute { serviceType=FactoryDefaults# } 
	Void configureFactoryDefaults(Configuration config) {
		config[FormBeanConfigIds.defaultMaxLength] = 512
	}
}
