# FirstLogic Template

First Logic Template provides the functionality needed to work import and manipulate
control template that follow First Logic's design structure. That structure is 
a template text file made up instruction blocks.  Instruction blocks contain
instructions that are formatted as "parameter = argument".  As an example block:

```
BEGIN  Template Loader Test ======================================
Job Description (to 80 chars)................ = Template Load Test
Job Owner (to 20 chars)...................... = dvn
Base directory............................... = E:\CLIENT\DATA
END
```

A block always starts with a BEGIN instruction.  The text that follows identifies the blocks  
name (also referred to as its type). The block's name can be followed by 1+ equal signs, which 
provides a convenient break where separating 10's and 100's of blocks. And a block always
ends with and END instruction, which is followed by nothing.

Within the BEGIN/END are the instructions. Each instruction has a free-form parameter and argument 
that are separated by an equal sign. Periods may follow the parameter text between the text and 
the equal sign. This provides convenient visual for lining up all the arguments within a block. 
What the instructions are and how they are interpreted is completely up to your application.

_Naming the framework FirstLogic is a homage to the original developers of the framework, 
FirstLogic (now Satori Software.) FirstLogic evolved from PostalSoft, with FirstLogic being 
later acquired by Business Objects, which was later acquired by SAP, who was not very 
interested in the original PostalSoft software. The products were shriveling on the SAP vine 
when a number of dedicated past employees and investors acquired brand and the software line 
from SAP._

_I have always been a fan of their template framework and how IO of delimited and fixed length files 
is described and handled. Other projects will detail this._

## Revision History
| Version | Description |   
| --- | --- |
| 4.0.0   | Complete refactoring, using sqlite as memory manager and data store |
