=======================
Developer Documentation
=======================

Developers manage the code generated by WupperCodeGen. The output is defined by
Jinja2 template files, usually ending in '.template'.

Template Files
--------------

The template files should be written using `Jinja2 <http://jinja.pocoo.org/>`_
syntax. Jinja2 statements can be either flow control commands such as ``{% for g
in groups %}`` or simple text substitutions such as ``{{ g.name }}``. For a
detailed description of the Jinja2 language, please refer to the `official
documentation <http://jinja.pocoo.org/docs/dev/>`_, but look below for the
special codes to use for LaTeX templates.

The data retrieved from the input file (yaml) is available as variables in the
template. Those variables are listed in the user documentation. Apart from these
variables one may call a number of functions and filters as explained below.

*The following global variables are available:*

metadata
  A dictionary with some metadata, available for the config file and the template.

tree
  The root of all the nodes, e.g. the one named 'Registers'.

registers
  A list of all the registers. All registers are linked into the tree by
  their 'parent' attribute.

nodes
  A lookup table of all nodes, stored by name or full_name. All nodes are linked
  into the tree by their 'parent' attribute.

In case wuppercodegen is called in "diff" mode you also have access to the following global variables:

diff_tree
  The root of all the nodes from the diff file, e.g. the one named 'Registers'.

diff_registers
  A list of all the registers from the diff file. All registers are linked into the diff_tree by
  their 'parent' attribute.

diff_nodes
  A lookup table of all nodes from the diff file, stored by name or full_name. All nodes are linked
  into the diff_tree by their 'parent' attribute.

changed_registers
  A list of changed registers.

Functions
---------
All functions of Node can be called on BitField, Register, Group or Sequence.
These themselves have extra functions available as well.
Functions without arguments can be called as if they were attributes (no parentheses).

.. automodule:: wuppercodegen.classes
    :members: Node, BitField, Entry, Register, Group, Sequence
    :show-inheritance:

Tests
-----
Tests can be called if output is based on some condition.

.. automodule:: wuppercodegen.test
    :members:

Filters
-------
Filters are used to modify input (with or without parameters). They are handy for
formatting and aligning the output.

.. automodule:: wuppercodegen.filter
    :members:

Codes for LaTeX (templates where the output ends in .tex)
---------------------------------------------------------
As LaTeX uses a lot of special characters WupperCodeGen redefines
the standard JinJa2 delimeters to some others. Care must also be
taken in a LaTeX template to escape all texts. An escape_tex filter
is available to handle this.

================= =========== =============
Delimiters        Standard    LaTeX
================= =========== =============
Statements        {% ... %}   ((\* ... \*))
Expressions       {{ ... }}   ((( ... )))
Comments          {# ... #}   ((= ... =))
Line Statements   #  ... ##
================= =========== =============


-------
Example
-------

To iterate through all registers, the following snippet can be used:

.. highlight:: none
.. include:: ../examples/register_list/register_list.txt.template
	:code:
