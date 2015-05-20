spelchek
----------

A cheap-ass, CLR/Mono spellchecker based on [Peter Norvig's Python Bayes demo](http://norvig.com/spell-correct.html) All the interesting work is his.

The interesting external methods are

   * `known()` filters a list of words and returns only those in the dictionary,
   * `correct()` returns the best guess for the supplied word
   * `guesses()` returns all guesses for the supplied word
   * `add()` adds a word to the dictionary, with an optional priority value

So simple uses would be something like

    import spelchek
    print spelchek.correct('eaxmple')
    # 'example'

The current corpus of words includes about 75,000 entries. It does not include punction such as hyphens, apostrophes or spaces.  The module also supports optional user-supplied dictionaries.
   
#Important Caveat
========
The heart of a spell checker is the dictionary, and the dictionary here is cadged together out of a bunch of free online sources.  No really effort has been made to check it for accuracy, and although it's trivially correct with several tens of thousands of words involved errors are pretty much inevitable (if you find one, feel free to submit a pull request and I'll update `corpus.txt` as needed).

Installation
============
This module is written in Boo. You can compile it using the SLN file in MonoDevelop, or from the command line using 

    booc -debug- -embedres:corpus.txt -target:library BooSpell.boo
