# This module defines common values used by multiple classes.
module FL_Regex
   @@argloc = 45		# Location where to put argument
   RGX_PARSE = Regexp.new(/\.* *= */)
   RGX_COMMENT = Regexp.new(/^\*.*\n?$/)
   RGX_END = Regexp.new(/^END\s*/)
   RGX_BEGIN = Regexp.new(/^BEGIN */)
   RGX_BEGIN_OR_END = Regexp.new(/^(BEGIN)?(END)?/)
end

