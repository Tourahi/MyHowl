-- Copyright 2014-2015 The Howl Developers
-- License: MIT (see LICENSE.md at the top-level directory of the distribution)

require 'ljglibs.cdefs.gtk'
core = require 'ljglibs.core'
require 'ljglibs.gtk.widget'

jit.off true, true

core.define 'GtkMisc < GtkWidget', {
  properties: {
    xalign: 'gfloat'
    yalign: 'gfloat'
    xpad: 'gint'
    ypad: 'gint'
  }
}
