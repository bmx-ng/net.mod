' Copyright (c) 2026 Bruce A Henderson
' All rights reserved.
' 
' Redistribution and use in source and binary forms, with or without
' modification, are permitted provided that the following conditions are met:
' 
' * Redistributions of source code must retain the above copyright notice, this
'   list of conditions and the following disclaimer.
' 
' * Redistributions in binary form must reproduce the above copyright notice,
'   this list of conditions and the following disclaimer in the documentation
'   and/or other materials provided with the distribution.
' 
' * Neither the name of the copyright holder nor the names of its
'   contributors may be used to endorse or promote products derived from
'   this software without specific prior written permission.
' 
' THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
' IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
' DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
' FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
' DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
' SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
' CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
' OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
' OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
' 
SuperStrict

Import "litehtml/include/*.h"
Import "litehtml/include/litehtml/*.h"
Import "litehtml/src/gumbo/include/*.h"
Import "litehtml/src/gumbo/include/gumbo/*.h"

Import "litehtml/src/codepoint.cpp"
Import "litehtml/src/css_length.cpp"
Import "litehtml/src/css_selector.cpp"
Import "litehtml/src/css_tokenizer.cpp"
Import "litehtml/src/css_parser.cpp"
Import "litehtml/src/document.cpp"
Import "litehtml/src/document_container.cpp"
Import "litehtml/src/el_anchor.cpp"
Import "litehtml/src/el_base.cpp"
Import "litehtml/src/el_before_after.cpp"
Import "litehtml/src/el_body.cpp"
Import "litehtml/src/el_break.cpp"
Import "litehtml/src/el_cdata.cpp"
Import "litehtml/src/el_comment.cpp"
Import "litehtml/src/el_div.cpp"
Import "litehtml/src/element.cpp"
Import "litehtml/src/el_font.cpp"
Import "litehtml/src/el_image.cpp"
Import "litehtml/src/el_link.cpp"
Import "litehtml/src/el_para.cpp"
Import "litehtml/src/el_script.cpp"
Import "litehtml/src/el_space.cpp"
Import "litehtml/src/el_style.cpp"
Import "litehtml/src/el_table.cpp"
Import "litehtml/src/el_td.cpp"
Import "litehtml/src/el_text.cpp"
Import "litehtml/src/el_title.cpp"
Import "litehtml/src/el_tr.cpp"
Import "litehtml/src/encodings.cpp"
Import "litehtml/src/html.cpp"
Import "litehtml/src/html_tag.cpp"
Import "litehtml/src/html_microsyntaxes.cpp"
Import "litehtml/src/iterators.cpp"
Import "litehtml/src/media_query.cpp"
Import "litehtml/src/style.cpp"
Import "litehtml/src/stylesheet.cpp"
Import "litehtml/src/table.cpp"
Import "litehtml/src/tstring_view.cpp"
Import "litehtml/src/url.cpp"
Import "litehtml/src/url_path.cpp"
Import "litehtml/src/utf8_strings.cpp"
Import "litehtml/src/web_color.cpp"
Import "litehtml/src/num_cvt.cpp"
Import "litehtml/src/strtod.cpp"
Import "litehtml/src/string_id.cpp"
Import "litehtml/src/css_properties.cpp"
Import "litehtml/src/line_box.cpp"
Import "litehtml/src/css_borders.cpp"
Import "litehtml/src/render_item.cpp"
Import "litehtml/src/render_block_context.cpp"
Import "litehtml/src/render_block.cpp"
Import "litehtml/src/render_inline_context.cpp"
Import "litehtml/src/render_table.cpp"
Import "litehtml/src/render_flex.cpp"
Import "litehtml/src/render_image.cpp"
Import "litehtml/src/formatting_context.cpp"
Import "litehtml/src/flex_item.cpp"
Import "litehtml/src/flex_line.cpp"
Import "litehtml/src/background.cpp"
Import "litehtml/src/gradient.cpp"

Import "litehtml/src/gumbo/attribute.c"
Import "litehtml/src/gumbo/char_ref.c"
Import "litehtml/src/gumbo/error.c"
Import "litehtml/src/gumbo/parser.c"
Import "litehtml/src/gumbo/string_buffer.c"
Import "litehtml/src/gumbo/string_piece.c"
Import "litehtml/src/gumbo/tag.c"
Import "litehtml/src/gumbo/tokenizer.c"
Import "litehtml/src/gumbo/utf8.c"
Import "litehtml/src/gumbo/util.c"
Import "litehtml/src/gumbo/vector.c"

