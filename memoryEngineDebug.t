#charset "us-ascii"
//
// memoryEngineDebug.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

#ifdef __DEBUG_MEMORY_ENGINE

DefineTAction(MemoryObject);
VerbRule(MemoryObject) 'memory' singleDobj: MemoryObjectAction
	verbPhrase = 'memory debug/debugging (what)'
;

modify Thing
	dobjFor(MemoryObject) {
		action() {
			"object <<gDobj.name>>:\n ";
			"\tseen = <<toString(gActor.getSeen(gDobj))>>\n ";
			"\tknown = <<toString(gActor.getKnown(gDobj))>>\n ";
		}
	}
;

#endif // __DEBUG_MEMORY_ENGINE
