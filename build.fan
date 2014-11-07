using build

class Build : BuildPod {

	new make() {
		podName = "afFormBean"
		summary = "A library to render Fantom objects as HTML forms complete with client and server side validation"
		version = Version("0.0.2")

		meta = [
			"proj.name"		: "FormBean",	
			"afIoc.module"	: "afFormBean::FormBeanModule",
			"internal"		: "true",			
			"tags"			: "web",
			"repo.private"	: "false"
		]

		index	= [	
			"afIoc.module"	: "afFormBean::FormBeanModule",
		]

		depends = [
			"sys 1.0",
			"web 1.0",

			// ---- Core ------------------------
			"afBeanUtils  1.0.4  - 1.0",
			"afPlastic    1.0.16 - 1.0",	// for EfanXtra FormBean provider
			"afConcurrent 1.0.6  - 1.0",	// for CachingTypeLookup / OptionsProviders
			"afIoc        2.0.0  - 2.0",
			
			// ---- Web -------------------------
			"afBedSheet   1.4.0  - 1.4",			
			"afEfanXtra   1.1.18 - 1.1",

			// ---- Test ------------------------
//			"afBounce     1.0.18 - 1.0",
//			"afSizzle     1.0.2  - 1.0"
		]

		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/advanced/`]
		resDirs = [`res/`]
	}
	
//	override Void compile() {
//		// remove test pods from final build
//		testPods := "afBounce afSizzle".split
//		depends = depends.exclude { testPods.contains(it.split.first) }
//		super.compile
//	}
}
