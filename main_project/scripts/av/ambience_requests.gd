extends RefCounted
## AV owns gain requests. Environmental layer selection remains with IMP-035.
var _requests := {}
var _serial := 0
func acquire(owner: String, scope: String, gain: float) -> int:
	if owner.is_empty() or not is_finite(gain) or gain<0 or gain>1: return 0
	_serial += 1
	_requests[_serial] = {"owner":owner,"scope":scope,"gain":gain}
	return _serial
func release(token: int, owner: String) -> bool:
	if not _requests.has(token) or _requests[token].owner!=owner: return false
	_requests.erase(token)
	return true
func effective(scope: String) -> float:
	var gain := 1.0
	for request: Dictionary in _requests.values():
		if request.scope.is_empty() or request.scope==scope: gain = minf(gain,request.gain)
	return gain
