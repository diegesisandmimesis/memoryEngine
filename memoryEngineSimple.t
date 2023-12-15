#charset "us-ascii"
//
// memoryEngineSimple.t
//
//	An alternative to full memory tracking.  Here we more or less
//	replicate the "stock" adv3 seen/known/revealed behavior by
//	just keeping track of a boolean state.
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

#ifdef MEMORY_ENGINE_SIMPLE

modify MemoryEngine
	_setFlag(obj, prop, data?) {
		if(active != true) return(nil);
		if(self.(prop) == nil) self.(prop) = new LookupTable();
		return(self.(prop)[obj] = true);
	}
;

#endif // MEMORY_ENGINE_SIMPLE