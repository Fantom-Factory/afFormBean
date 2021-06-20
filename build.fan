using build

class Build : BuildPod {

	new make() {
		podName = "afFormBean"
		summary = "Renders Fantom objects as HTML forms complete with client and server side validation"
		version = Version("1.2.9")

		meta = [
			"pod.dis"			: "Form Bean",	
			"afIoc.module"		: "afFormBean::FormBeanModule",
			"repo.tags"			: "web",
			"repo.public"		: "true"
		]

		depends = [
			"sys          1.0.72 - 1.0",	// 1.0.69 because we make use of in-memory Files
			"concurrent   1.0.72 - 1.0",

			// ---- Core ------------------------
			"afBeanUtils  1.0.12 - 1.0",
			"afConcurrent 1.0.26 - 1.0",	// for Messages.AtomicMap
			"afIoc        3.0.8  - 3.0",

			// ---- Web -------------------------
			// removed the hard dependency on BedSheet and web so FormBean may be used to validate Domain objects
			// we pretty much only needed the ValueEncoders service anyway!
//			"afBedSheet   1.5.8  - 1.5"
		]

		srcDirs = [`fan/`, `fan/advanced/`, `fan/internal/`, `fan/internal/bedsheet/`, `fan/internal/inspectors/`, `fan/public/`]
		resDirs = [`doc/`, `res/`]
	}
}

