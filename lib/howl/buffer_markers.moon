-- Copyright 2015 The Howl Developers
-- License: MIT (see LICENSE.md at the top-level directory of the distribution)

import PropertyObject from howl.util.moon
{:copy} = moon

translate = (m, buf) ->
  m = copy m
  m.start_offset = buf\char_offset m.start_offset
  m.end_offset = buf\char_offset m.end_offset
  m

adjust_marker_offsets = (marker, b) ->
  error "Missing field 'name'", 3 unless marker.name

  marker = copy marker
  if marker.byte_start_offset and marker.byte_end_offset
    marker.start_offset = marker.byte_start_offset
    marker.end_offset = marker.byte_end_offset
    marker.byte_start_offset = nil
    marker.byte_end_offset = nil
  else
    for f in *{ 'start_offset', 'end_offset' }
      v = marker[f]
      error "Missing field '#{f}'", 3 unless v
      if v < 1 or v > b.length + 1
        error "Invalid offset '#{v}' (length: #{b.length})"
      marker[f] = b\byte_offset v

  marker

adjust_selector = (selector, b) ->
  -- update start/end offsets to be byte offsets
  return unless selector
  selector = moon.copy selector
  for f in *{ 'start_offset', 'end_offset' }
    v = selector[f]
    continue unless v
    continue if v < 1 or v > b.length + 1
    selector[f] = b\byte_offset v

  selector

class BufferMarkers extends PropertyObject
  new: (@a_buffer) =>
    super!
    @markers = @a_buffer.markers

  @property all: {
    get: =>
      ms = @markers\for_range 1, @a_buffer.size + 1
      [translate(m, @a_buffer) for m in *ms]
  }

  add: (markers) =>
    return if #markers == 0
    markers = [adjust_marker_offsets(m, @a_buffer) for m in *markers]
    @markers\add markers

  at: (offset, selector) =>
    @for_range offset, offset + 1

  for_range: (start_offset, end_offset, selector) =>
    start_offset = @a_buffer\byte_offset start_offset
    end_offset = @a_buffer\byte_offset end_offset
    ms = @markers\for_range start_offset, end_offset, selector
    [translate(m, @a_buffer) for m in *ms]

  remove: (selector) =>
    @markers\remove adjust_selector selector, @a_buffer

  remove_for_range: (start_offset, end_offset, selector) =>
    start_offset = @a_buffer\byte_offset start_offset
    end_offset = @a_buffer\byte_offset end_offset

    @markers\remove_for_range start_offset, end_offset, selector

  find: (selector) =>
    ms = @markers\find adjust_selector selector, @a_buffer
    [translate(m, @a_buffer) for m in *ms]
