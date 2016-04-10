using build

class Build : BuildPod {

	new make() {
		podName = "afFormBean"
		summary = "Renders Fantom objects as HTML forms complete with client and server side validation"
		version = Version("1.1.1")

		meta = [
			"proj.name"		: "Form Bean",	
			"afIoc.module"	: "afFormBean::FormBeanModule",
			"repo.tags"		: "web",
			"repo.public"	: "false"
		]

		depends = [
			"sys 1.0.68 - 1.0",
			"web 1.0.68 - 1.0",

			// ---- Core ------------------------
			"afBeanUtils  1.0.8  - 1.0",
			"afConcurrent 1.0.12 - 1.0",	// for Messages.AtomicMap
			"afIoc        3.0.0  - 3.0",
			"afIocConfig  1.1.0  - 1.1",

			// ---- Web -------------------------
			"afBedSheet   1.5.0  - 1.5"

			// ---- Test ------------------------
//			"afBounce     1.0.18 - 1.0",
//			"afSizzle     1.0.2  - 1.0"
		]

		srcDirs = [`fan/`, `fan/advanced/`, `fan/internal/`, `fan/internal/inspectors/`, `fan/public/`]
		resDirs = [`doc/`, `res/`]
	}
}

