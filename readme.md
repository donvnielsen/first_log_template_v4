== FirstLogic Template

Revision History
2.0.4   - Added write method to FL_Format_File.
2.0.5   - Updated delete() function.  instead of calling Array.delete(), it
          loops through the array of blocks an compares object_id's.
2.0.6   - Changed fl_template.delete_block_from_array to use delete_if
          and compare object id's.  previous logic was still engaging the
          Comparable and deleting multiple blocks instead of just one.
2.0.7   - Added block replace logic.  It was sorely missing.
        - Corrected fl_labelstudio.template.outputfile regular expressions.
2.0.8   - Corrected reg expression in FL_Instruction.arg= where parameter is identified.
          Eliminated brackets from expression.
2.0.9   - Update Rakefile for ruby 1.9
        - Noticed bug in FL_Input, eof on last record
2.1.0   - Added ability to write format compatible with dmexpress
2.1.1   - Removed strip from fl_format_file parse_?_record routines
3.0.0   - Updated all the requires to require relatives