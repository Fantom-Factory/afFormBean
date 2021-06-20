using afBeanUtils::TypeCoercer
using afConcurrent::AtomicMap

** A 'TypeCoercer' that caches its conversion methods.
internal const class CachingTypeCoercer : TypeCoercer {
	private const AtomicMap cache := AtomicMap()

	** Cache the conversion functions
	override |Obj->Obj|? createCoercionFunc(Type fromType, Type toType) {
		key	:= "${fromType.qname}->${toType.qname}"
		return cache.getOrAdd(key) { doCreateCoercionFunc(fromType, toType) } 
	}

	** Clears the function cache 
	Void clear() {
		cache.clear
	}
}
