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
	_debugMemory(obj) {
		local m;

		if((obj == nil) || !obj.ofKind(Thing)) {
			"Unknown object or bad object type. ";
			return;
		}

		"<<obj.name>>\n ";
		if((m = getSeen(obj)) == nil) {
			"\tnever seen\n ";
		} else {
			"\t";
			if(m == true)
				"seen";
			else if(m.ofKind(Memory))
				m._debugMemory();
			else
				"unknown memory type";
			"\n ";
		}
	}
;

modify MemoryEngine
	_debugMemories() {
		"\n<b><<actor.name.toUpper()>> MEMORIES:</b><.p>\n ";
	}
;

modify Memory
	_debugMemory() {
		"last seen on turn <<toString(turn)>>,
			location = <<(room ? room.roomName : 'nowhere')>>";
	}
;

#endif // __DEBUG_MEMORY_ENGINE
