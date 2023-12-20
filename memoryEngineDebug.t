#charset "us-ascii"
//
// memoryEngineDebug.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

#ifdef __DEBUG_MEMORY_ENGINE

class MemoryAction: Action
	actionTime = 0
	objInScope(obj) { return(true); }
;
class MemoryTAction: MemoryAction, TAction;
class MemoryTIAction: MemoryAction, TIAction;

DefineTActionSub(DebugMemoryObject, MemoryTAction);
VerbRule(DebugMemoryObject) 'mo' singleDobj: DebugMemoryObjectAction
	verbPhrase = 'memory debug/debugging (what)'
;

DefineTActionSub(DebugMemoryActor, MemoryTAction);
VerbRule(DebugMemoryActor) 'ma' singleDobj: DebugMemoryActorAction
	verbPhrase = 'memory debug/debugging (who)'
;

DefineTIActionSub(DebugMemoryActorObject, MemoryTIAction);
VerbRule(DebugMemoryActorObject) 'ma' singleDobj singleIobj:
	DebugMemoryActorObjectAction
	verbPhrase = 'memory debug/debugging (whom) (about what)'
;

modify Thing
	dobjFor(DebugMemoryObject) { action() { gActor._debugMemory(self); } }
	dobjFor(DebugMemoryActor) {
		verify() { illogical(&cantDebugMemoryNotActor); }
	}
	dobjFor(DebugMemoryActorObject) { verify() {} }
	iobjFor(DebugMemoryActorObject) { verify() {} }
;

modify Actor
	dobjFor(DebugMemoryActor) {
		verify() {
			if(memoryEngine == nil)
				illogical(&cantDebugNoMemoryEngine);
		}
		action() { _debugActorMemory(); }
	}
	dobjFor(DebugMemoryActorObject) {
		verify() {
			if(memoryEngine == nil)
				illogical(&cantDebugNoMemoryEngine);
		}
		action() { _debugMemory(gIobj); }
	}
;

modify Actor
	_debugActorMemory() {
		memoryEngine._debugMemories();
	}
	_debugMemory(id) {
		local m;

		if((id == nil) || !id.ofKind(Thing)) {
			reportFailure(&noMemoryBadArg);
			return;
		}
		if((m = getMemory(id)) == nil) {
			reportFailure(&noMemory, id);
			return;
		}

		m._debugMemory();
/*
		"\n <.p>\n ";
		"\nname = <<toString(obj.name)>>\n ";
		"\nknown = <<toString(getKnown(obj))>>\n ";
		"\nrevealed = <<toString(getRevealed(obj))>>\n ";
		"\nseen = <<toString(getSeen(obj))>>\n ";
		"\n ";
*/
	}
;

modify MemoryEngine
	_debugMemories() {
		"\n<b><<actor.name.toUpper()>> MEMORIES:</b><.p>\n ";
	}
;

modify Memory
	_debugMemory() {
		"\n <.p> ";
		"\nknown = <<toString(known)>>\n ";
		"\nrevealed = <<toString(revealed)>>\n ";
		"\nseen = <<toString(seen)>>\n ";
		"<.p> ";
		"createTime = <<toString(createTime)>>\n ";
		"writeTime = <<toString(writeTime)>>\n ";
		"writeCount = <<toString(writeCount)>>\n ";
		"readTime = <<toString(readTime)>>\n ";
		"readCount = <<toString(readCount)>>\n ";
		"age = <<toString(age())>>\n ";
		"<.p> ";
		"room = <<(room ? room.roomName : 'nowhere')>>\n ";
	}
;

#endif // __DEBUG_MEMORY_ENGINE
