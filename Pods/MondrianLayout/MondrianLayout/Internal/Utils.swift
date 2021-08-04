
func modify<Value>(_ value: inout Value, _ modifier: (inout Value) throws -> Void) rethrows {
  try modifier(&value)
}

func modified<Value>(_ value: Value, _ modifier: (inout Value) throws -> Void) rethrows -> Value {
  var new = value
  try modifier(&new)
  return new
}
