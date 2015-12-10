name "other"
description "AN Other Role"

$attrs = Hash.new { |h, k| h[k]=Hash.new(&h.default_proc) }
default_attributes($attrs)

override_attributes({})

run_list []