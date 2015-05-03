using afIoc
using afBedSheet

@NoDoc
const class FormBeanModule {
	
	static Void defineServices(ServiceDefinitions defs) {
		defs.add(InputSkins#)
		defs.add(OptionsProviders#)
	}
	
	@Contribute { serviceType=InputSkins# }
	static Void contributeInputSkins(Configuration config) {
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
		config["select"]	= config.autobuild(SelectSkin#)
//		config["button"]	= 
//		config["color"]		= 
//		config["file"]		= 
//		config["image"]		= 
//		config["radio"]		= 
//		config["reset"]		= 
//		config["submit"]	= 
	}
	
	@Contribute { serviceType=OptionsProviders# }
	static Void contributeOptionsProviders(Configuration config) {
		config[Enum#] = EnumOptionsProvider(true, "")
	}

	@Contribute { serviceType=ValueEncoders# }
	static Void contributeValueEncoders(Configuration config) {
		config[Bool#] = BoolEncoder()
	}

	@Contribute { serviceType=DependencyProviders# }
	static Void contributeDependencyProviders(Configuration config) {
		config["afFormBean.formBeanProvider"] = config.autobuild(FormBeanProvider#)
	}
}
