#charset "us-ascii"
//
// memoryEngineDebug.t
//
//	Implements a few debugging actions.
//
//	>MA [actor]		shows all the memories for the given actor
//	>MA [actor] [object]	shows the actor's memory for the object
//	>MO [object]		shows the player's memory for the object
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
			if(k.hideFromAll(LookAction))
				return;
			"\nobject:  <<k.name>>\n ";
			v._debugMemory('\t');
			"\n<.p> ";
		});
	}
;

modify Memory
	_output(str, prefix?) { "\n<<(prefix ? prefix : '')>><<str>>\n "; }
	_outputProp(prop, prefix?) {
		local v;

		v = (self).(prop);
		if((v == nil) || (v == 0)) return;

		_output('<<toString(prop)>> = <<toString(v)>>', prefix);
	}
_foozle = 'foo'
	_debugMemory(prefix?) {
		_output(' <.p> ');
		_outputProp(&described, prefix);
		_outputProp(&known, prefix);
		_outputProp(&revealed, prefix);
		_outputProp(&seen, prefix);
#ifndef MEMORY_ENGINE_NO_SENSES
		_outputProp(&heard, prefix);
		_outputProp(&smelled, prefix);
		_outputProp(&touched, prefix);
		_outputProp(&tasted, prefix);
#endif // MEMORY_ENGINE_NO_SENSES
		_output(' <.p> ');
	}
;

#ifndef MEMORY_ENGINE_SIMPLE
modify Memory
	_debugMemory(prefix?) {
		inherited(prefix);

		_outputProp(&createTime, prefix);
		_outputProp(&writeTime, prefix);
		_outputProp(&writeCount, prefix);
		_outputProp(&readTime, prefix);
		_outputProp(&readCount, prefix);
		_outputProp(&age, prefix);
		_output('<.p>');
	}
;
#endif // MEMORY_ENGINE_SIMPLE

#endif // __DEBUG_MEMORY_ENGINE
