# encoding: UTF-8

# Author::    Akira FUNAI
# Copyright:: Copyright (c) 2011 Akira FUNAI

require "#{::File.dirname __FILE__}/t"

class TC_WTeX < Test::Unit::TestCase

  def setup
    @wt = WTeX.new
  end

  def teardown
  end

  def test_instance
    wt = nil
    assert_nothing_raised(
      'WikiTex.new should return a proper instance'
    ) {
      wt = WTeX.new
    }
    assert_instance_of(
      WTeX,
      wt,
      'WikiTex.new should return a proper instance'
    )
  end

  def test_tex_heading
    [
      '!foo',
      '! foo',
      "! foo\n",
    ].each {|w|
      assert_equal(
        "\\subsection{foo}\n",
        @wt.tex(w.dup),
        "WTeX#tex should convert #{w.inspect} into \\subsection{foo}"
      )
    }

    assert_equal(
      "\\section{bar}\n",
      @wt.tex('!! bar'),
      'WTeX#tex should convert "!! bar" into \\section{bar}'
    )
    assert_equal(
      "\\chapter{baz}\n",
      @wt.tex('!!! baz'),
      'WTeX#tex should convert "!!! baz" into \\chapter{baz}'
    )

    assert_equal(
      "\\chapter{baz}\n",
      @wt.tex('!!!!! baz'),
      'WTeX#tex should convert more than 4 "!"s into \\chapter{}'
    )
  end

  def test_tex_separator
    assert_equal(
      "\\WTseparator{}\n",
      @wt.tex('---'),
      'WTeX#tex should convert "---" into \\WTseparator{}'
    )
  end

  def test_tex_heading_without_number
    assert_equal(
      "\\subsection*{foo}\n",
      @wt.tex('!* foo'),
      'WTeX#tex should convert "!!!" with "*" into \\chapter*{}'
    )
    assert_equal(
      "\\chapter*{baz}\n",
      @wt.tex('!!!* baz'),
      'WTeX#tex should convert "!!!" with "*" into \\chapter*{}'
    )
  end

  def test_tex_heading_combination
    w = <<'_eos'
!!! foo

!! bar

_eos
    assert_equal(
      <<'_eos',
\chapter{foo}

\section{bar}

_eos
      @wt.tex(w),
      'WTeX#tex should deal with multiple headings'
    )

    w = <<'_eos'
!!! foo
!! bar

_eos
    assert_equal(
      <<'_eos',
\chapter{foo}
\section{bar}

_eos
      @wt.tex(w),
      'WTeX#tex should deal with sequence of headings'
    )
  end

  def test_tex_p
    w = <<'_eos'
foo
bar
_eos
    assert_equal(
      <<'_eos',
foo\\
bar
_eos
      @wt.tex(w),
      'WTeX#tex should append new line commands explicitly'
    )
  end

  def test_tex_p_multiple
    w = <<'_eos'
foo
bar

baz
qux

boo
_eos
    assert_equal(
      <<'_eos',
foo\\
bar

baz\\
qux

boo
_eos
      @wt.tex(w),
      'WTeX#tex should deal with multiple paragraphs'
    )

    w = <<'_eos'
foo
bar
baz

qux

boo
_eos
    assert_equal(
      <<'_eos',
foo\\
bar\\
baz

qux

boo
_eos
      @wt.tex(w),
      'WTeX#tex should deal with multiple paragraphs'
    )
  end

  def test_tex_p_combination
    w = <<'_eos'
!!! foo

baz
qux

boo
_eos
    assert_equal(
      <<'_eos',
\chapter{foo}

baz\\
qux

boo
_eos
      @wt.tex(w),
      'WTeX#tex should deal with combination of commands and paragraphs'
    )

    w = <<'_eos'
foo
bar

!! qux

boo
_eos
    assert_equal(
      <<'_eos',
foo\\
bar

\section{qux}

boo
_eos
      @wt.tex(w),
      'WTeX#tex should deal with combination of commands and paragraphs'
    )
  end

  def test_tex_box
    w = <<'_eos'
foo:
] ***big***
_eos
    assert_equal(
      <<'_eos',
\begin{WTbox}{foo}
 {\LARGE\bf big}
\end{WTbox}
_eos
      @wt.tex(w),
      "WTeX#tex should convert lines which begin with ']' into boxed block"
    )

    w = <<'_eos'
] ***big***
_eos
    assert_equal(
      <<'_eos',
\begin{WTbox-without-title}
 {\LARGE\bf big}
\end{WTbox-without-title}
_eos
      @wt.tex(w),
      "WTeX#tex should convert lines which begin with ']' into boxed block"
    )
  end

  def test_tex_nested_wiki_in_box
    w = <<'_eos'
]foo
]+ bar
]+ baz
_eos
    assert_equal(
      <<'_eos',
\begin{WTbox-without-title}
foo
\begin{enumerate}
\item bar
\item baz
\end{enumerate}
\end{WTbox-without-title}
_eos
      @wt.tex(w),
      'WTeX#tex should convert blocks inside a boxed block'
    )

    w = <<'_eos'
qux:
]foo
]bar:
]| baz
_eos
    assert_equal(
      <<'_eos',
\begin{WTbox}{qux}
foo
\begin{WTcode}{bar}
 baz
\end{WTcode}
\end{WTbox}
_eos
      @wt.tex(w),
      'WTeX#tex should convert blocks inside a boxed block'
    )
  end

  def test_tex_nested_tex_in_box
    w = <<'_eos'
]foo
]$$
]x^2 + 2y + z
]$$
_eos
    assert_equal(
      <<'_eos',
\begin{WTbox-without-title}
foo\\
$$
x^2 + 2y + z
$$
\end{WTbox-without-title}
_eos
      @wt.tex(w),
      'WTeX#tex should convert multi-line TeX inside a boxed block'
    )
  end

  def test_tex_complex_nesting_in_box
    w = <<'_eos'
]foo
]]$$
]]x^2 + 2y + z
]]$$
]]**boo**
]\begin{huge}
]FOO\end{huge}
_eos
    assert_equal(
      <<'_eos',
\begin{WTbox-without-title}
foo
\begin{WTbox-without-title}
$$
x^2 + 2y + z
$$\\
{\large\bf boo}
\end{WTbox-without-title}
\begin{huge}
FOO\end{huge}
\end{WTbox-without-title}
_eos
      @wt.tex(w),
      'WTeX#tex should not skip complex Wiki/TeX nesting inside a boxed block'
    )
  end

  def test_tex_broken_tex_inside_box
    w = <<'_eos'
]foo
]$$
a$c
_eos
    assert_equal(
      <<'_eos',
\begin{WTbox-without-title}
foo\\
\${}\${}
\end{WTbox-without-title}
a\${}c
_eos
      @wt.tex(w),
      'WTeX#tex should escape broken TeX inside a box'
    )
  end

  def test_tex_code
    w = <<'_eos'
foo.rb:
|a = 123
| b = 456 * 789
_eos
    assert_equal(
      <<'_eos',
\begin{WTcode}{foo.rb}
a = 123
 b = 456 * 789
\end{WTcode}
_eos
      @wt.tex(w),
      "WTeX#tex should convert lines which begin with '|' into code block"
    )

    w = <<'_eos'
foo.rb:
bbb|a = 123
_eos
    assert_equal(
      <<'_eos',
foo.rb:\\
bbb\textbar{}a = 123
_eos
      @wt.tex(w),
      "WTeX#tex should convert lines which begin with '|' into code block"
    )

    w = <<'_eos'
foo_bar.rb:
|a = 123
_eos
    assert_equal(
      <<'_eos',
\begin{WTcode}{foo\_{}bar.rb}
a = 123
\end{WTcode}
_eos
      @wt.tex(w),
      'WTeX#tex should escape title of code blocks'
    )
  end

  def test_tex_code_without_title
    w = <<'_eos'
|a = 123
| b = 456 * 789
_eos
    assert_equal(
      <<'_eos',
\begin{WTcode-without-title}
a = 123
 b = 456 * 789
\end{WTcode-without-title}
_eos
      @wt.tex(w),
      "WTeX#tex should convert lines which begin with '|' into code block"
    )

    w = <<'_eos'
|foo.rb:
|a = 123
| b = 456 * 789
_eos
    assert_equal(
      <<'_eos',
\begin{WTcode-without-title}
foo.rb:
a = 123
 b = 456 * 789
\end{WTcode-without-title}
_eos
      @wt.tex(w),
      "WTeX#tex should not treat lines which begin with '|' as a title"
    )
  end

  def test_tex_complex_nesting_in_code
    w = <<'_eos'
|]**boo**
|\begin{huge}
|FOO\end{huge}
_eos
    assert_equal(
      <<'_eos',
\begin{WTcode-without-title}
]**boo**
\begin{huge}
FOO\end{huge}
\end{WTcode-without-title}
_eos
      @wt.tex(w),
      'WTeX#tex should treat complex Wiki/TeX nesting inside a code block'
    )
  end

  def test_tex_quote
    w = <<'_eos'
>a = 123
> b = 456 & 789
_eos
    assert_equal(
      <<'_eos',
\begin{quote}
a = 123\\
 b = 456 \&{} 789
\end{quote}
_eos
      @wt.tex(w),
      "WTeX#tex should convert lines which begin with '>' into quote"
    )
  end

  def test_tex_nested_wiki_in_quote
    w = <<'_eos'
>foo
>+ bar
>+ baz
_eos
    assert_equal(
      <<'_eos',
\begin{quote}
foo
\begin{enumerate}
\item bar
\item baz
\end{enumerate}
\end{quote}
_eos
      @wt.tex(w),
      'WTeX#tex should convert nested blocks inside a quote'
    )
  end

  def test_tex_complex_nesting_in_quote
    w = <<'_eos'
>foo
>]$$
>]x^2 + 2y + z
>]$$
>>**boo**
>\begin{huge}
>FOO\end{huge}
_eos
    assert_equal(
      <<'_eos',
\begin{quote}
foo
\begin{WTbox-without-title}
$$
x^2 + 2y + z
$$
\end{WTbox-without-title}
\begin{quote}
{\large\bf boo}
\end{quote}
\begin{huge}
FOO\end{huge}
\end{quote}
_eos
      @wt.tex(w),
      'WTeX#tex should not skip complex Wiki/TeX nesting inside a quote'
    )
  end

  def test_tex_itemize
    w = <<'_eos'
* foo
* bar
_eos
    assert_equal(
      <<'_eos',
\begin{itemize}
\item foo
\item bar
\end{itemize}
_eos
      @wt.tex(w),
      "WTeX#tex should convert lines which begin with '*' into list"
    )

    w = <<'_eos'
* **baz**
_eos
    assert_equal(
      <<'_eos',
\begin{itemize}
\item {\large\bf baz}
\end{itemize}
_eos
      @wt.tex(w),
      "WTeX#tex should convert lines which begin with '*' into list"
    )
  end

  def test_tex_itemize_ambiguous
    w = <<'_eos'
*foo
_eos
    assert_equal(
      <<'_eos',
*foo
_eos
      @wt.tex(w),
      "WTeX#tex should not convert lines with '*' and immidiate strings without spaces"
    )
  end

  def test_tex_enumerate
    w = <<'_eos'
+ foo
+ bar
_eos
    assert_equal(
      <<'_eos',
\begin{enumerate}
\item foo
\item bar
\end{enumerate}
_eos
      @wt.tex(w),
      "WTeX#tex should convert lines which begin with '+' into list"
    )
  end

  def test_tex_nested_list
    w = <<'_eos'
* foo
** bar
** baz
* qux
_eos
    assert_equal(
      <<'_eos',
\begin{itemize}
\item foo\begin{itemize}
\item bar
\item baz
\end{itemize}

\item qux
\end{itemize}
_eos
      @wt.tex(w),
      'WTeX#tex should handle nested lists'
    )
  end

  def test_tex_mixed_list
    w = <<'_eos'
* foo
*+ bar
*+ baz
* qux
_eos
    assert_equal(
      <<'_eos',
\begin{itemize}
\item foo\begin{enumerate}
\item bar
\item baz
\end{enumerate}

\item qux
\end{itemize}
_eos
      @wt.tex(w),
      'WTeX#tex should handle mixed lists'
    )
  end

end
