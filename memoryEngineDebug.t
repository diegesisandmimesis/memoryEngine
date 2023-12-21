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
	}
;

modify MemoryEngine
	_debugMemories() {
		"\n<.p> ";
		if(_memory == nil) {
			reportFailure(&cantDebugNoActorMemories);
			return;
		}
		_memory.forEachAssoc(function(k, v) {
			"\nobject:  <<k.name>>\n ";
			v._debugMemory('\t');
			"\n<.p> ";
		});
	}
;

modify Memory
	_output(str, prefix?) { "\n<<(prefix ? prefix : '')>><<str>>\n "; }
	_debugMemory(prefix?) {
		_output(' <.p> ', prefix);
		_output('known = <<toString(known)>>', prefix);
		_output('revealed = <<toString(revealed)>>', prefix);
		_output('seen = <<toString(seen)>>', prefix);
#ifndef MEMORY_ENGINE_SENSES
		_output('heard = <<toString(heard)>>', prefix);
		_output('smelled = <<toString(smelled)>>', prefix);
		_output('touched = <<toString(touched)>>', prefix);
		_output('tasted = <<toString(tasted)>>', prefix);
#endif // MEMORY_ENGINE_SENSES
		_output(' <.p> ', prefix);
	}
;

#ifndef MEMORY_ENGINE_SIMPLE
modify Memory
	_debugMemory(prefix?) {
		inherited(prefix);

		_output('createTime = <<toString(createTime)>>', prefix);
		_output('writeTime = <<toString(writeTime)>>', prefix);
		_output('writeCount = <<toString(writeCount)>>', prefix);
		_output('readTime = <<toString(readTime)>>', prefix);
		_output('readCount = <<toString(readCount)>>', prefix);
		_output('age = <<toString(age())>>', prefix);
		_output('<.p>', prefix);
		_output('room = <<(room ? room.roomName : 'nowhere')>>', prefix);
	}
;
#endif // MEMORY_ENGINE_SIMPLE

#endif // __DEBUG_MEMORY_ENGINE
