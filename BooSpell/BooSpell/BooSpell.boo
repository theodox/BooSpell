"""spelchek
--------

A cheapo spellchecker based on Peter Norvig's python bayes demo at http://norvig.com/spell-correct.html

The interesting external methods are
    * known() filters a list of words and returns only those in the dictionary,
    * correct() returns the best guess for the supplied word
    * guesses() returns all guesses for the supplied word

The dictionary is stored in corpus.txt. It's not very scientific or exact, I kludged it together from a variety of
public domain sources. Values over 5 are from the [GSL word list](http://jbauman.com/aboutgsl.html), the rest are
guesstimated from other word lists.  It's not guaranteed to be error free! If you discover mistakes, feel free to
submit a pull request.

Still, it works as is. Do remember to double check that the result of 'correct' is 'known': the `correct()` will return
the original word unchanged if it finds no candidates!

Installation
============
This Boo version is intended to be compiled into a DLL for use in other programs. The typical commaand line would be:
	
	booc -debug- -embedres:corpus.txt -target:library BooSpell.boo

to generate BooSpell.dll 
"""

import System
import System.IO
import System.Reflection
import System.Collections.Generic

public class SpellChecker:
	
	static _ALPHABET = 'abcdefghijklmnopqrstuvwxyz'


	# this is the bayes dictionary, which is auto-populated using the comma-delimited list in `corpus.txt'
	# this version is hardly scientific; the top 2000 words from the GSL list have good values,
	# everything else is cadged together from random word list sources with an arbitrary values of 4 for
	# 'ordinary' and 3 for 'plurals, adjectives, and participials'
	_DICTIONARY =  Dictionary[of string, int]()
	
	def constructor():	
		_assembly as Assembly = Assembly.GetExecutingAssembly()
		_textStreamReader as StreamReader
		_textStreamReader =  StreamReader(_assembly.GetManifestResourceStream("corpus.txt"));
		_corpus = _textStreamReader.ReadToEnd().Split((Environment.NewLine,), StringSplitOptions.None)
		update_corpus(_corpus)

	def update_corpus(corpus as (string)):
	""" 
	given an iterable of strings in the format <word>,<score> add the words to the dictionary with the corresponding score.  
	"""
	    for line in corpus:
	    	if "," in line:
		        name, val = line.Split((",",), StringSplitOptions.None)
		        intval = int.Parse(val)
		        _DICTIONARY[name] = intval
			

	def first_order_variants(word as string):
	"""
	return the obvious spelling variants of <word> with missing words, transpositions, or misplaced characters
	"""
		_stringList = Boo.Lang.List[of (string)]
		_strings = Boo.Lang.List[of string]
		pair = {w as string, i as int | (w[:i] cast string, w[i:] cast string)}
		splits = _stringList((pair(word, i) for i in range(len(word) + 1)))
		deletes  = _strings((a + b[1:] for a as string, b as string in splits if b))
		transposes  = _strings((a + b[1] + b[0] + b[2:] for a as string, b as string in splits if len(b) > 1))
		replaces  = _strings((a + c + b[1:] for a as string, b as string in splits for c in _ALPHABET if b))
		inserts  = _strings((a + c + b for a as string, b as string in splits for c in _ALPHABET))  
		
		result = HashSet[of string]()
		for chunk in (deletes, transposes, replaces, inserts):
			result.UnionWith(chunk)
				
		return result


	def second_order_variants(word):
	"""
	return second-order candidates
	"""
		result = HashSet[of string]()
		entrants =  (e2 for e1 in first_order_variants(word) for e2 in first_order_variants(e1) if e2 in _DICTIONARY)
		result.UnionWith(entrants)
		return result
		
	def known(word as string):
	"""
	Return this word if it known, or an empy HashSet[of string]
	"""
		return known( (word, ))

	def known(words as IEnumerable[of string]):
	"""
	Return all the words in *words which are in the dictionary
	"""
		result = HashSet[of string]()
		result.UnionWith((w for w in words if w in _DICTIONARY))
		return result

	def correct(word as string):
	"""
	pick the 'best' candidate based on stored score of the possibilities.  If nothing else is close
	returns the original word, so don't assume its always right!
	"""
		candidates = HashSet[of string]()
		candidates.UnionWith(known(word))
		candidates.UnionWith(known(first_order_variants(word)))
		candidates.UnionWith(second_order_variants(word))

		result = word
		score = 0
		tmp = 0
		for c in candidates:
			_DICTIONARY.TryGetValue(c, tmp)
			if tmp > score:
				score = tmp
				result = c
			tmp = 0
		return result
			
	def guesses(word as string):
	"""
	return all of the first  order guesses for this word
	"""
	    result = List[of string](known(first_order_variants(word)))
	    result.Sort()
	    return result


	def add(word as string, pri as int):
	"""
	Adds <word> to the dictionary with the specified priority.  Note that this is a _TEMPORARY_ addition, it is not saved to disk
	"""
	    _DICTIONARY[word.ToLower()] = pri


	def add(word):
	"""
	Adds <word> to the dictionary with the default priority (4)
	"""
		add(word, 4)



