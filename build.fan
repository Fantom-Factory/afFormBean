using build

class Build : BuildPod {

	new make() {
		podName = "afFormBean"
		summary = "Renders Fantom objects as HTML forms complete with client and server side validation"
		version = Version("1.0.0")

		meta = [
			"proj.name"		: "Form Bean",	
			"afIoc.module"	: "afFormBean::FormBeanModule",
			"repo.tags"		: "web",
			"repo.public"	: "true"
		]

		index	= [	
			"afIoc.module"	: "afFormBean::FormBeanModule",
		]

		depends = [
			"sys 1.0",
			"web 1.0",

			// ---- Core ------------------------
			"afBeanUtils  1.0.4  - 1.0",
			"afConcurrent 1.0.8  - 1.0",	// for CachingTypeLookup / OptionsProviders
			"afIoc        2.0.8  - 2.0",
			
			// ---- Web -------------------------
			"afBedSheet   1.4.2  - 1.4"

			// ---- Test ------------------------
//			"afBounce     1.0.18 - 1.0",
//			"afSizzle     1.0.2  - 1.0"
		]

		srcDirs = [`fan/`, `fan/public/`, `fan/internal/`, `fan/advanced/`]
		resDirs = [`doc/`, `res/`]
	}
	
//	override Void compile() {
//		// remove test pods from final build
//		testPods := "afBounce afSizzle".split
//		depends = depends.exclude { testPods.contains(it.split.first) }
//		super.compile
//	}
}

